import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/models/ui_models/chat_card.dart';
import 'package:waternudge/models/ui_models/chat_message.dart';
import 'package:waternudge/services/application/ai_chat_service.dart';
import 'package:waternudge/services/application/chat_quota_service.dart';

/// State for the "Hỏi AI" screen.
///
/// Holds the transcript, talks to [AiChatService] and turns a failed request
/// into an error bubble the user can retry — the history itself is never
/// written to the database, so leaving the screen starts a fresh conversation.
class ChatController extends GetxController {
  static ChatController get to => Get.find();

  ChatController({AiChatService? service, ChatQuotaService? quota})
    : _service = service ?? AiChatService(),
      _quota = quota ?? ChatQuotaService();

  final AiChatService _service;
  final ChatQuotaService _quota;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// True while a reply is in flight: the input is disabled and the typing
  /// bubble is shown.
  final RxBool isSending = false.obs;

  /// True once the first card snapshot has landed, so the typing bubble gives
  /// way to the card filling in live.
  final RxBool isStreaming = false.obs;

  /// The message whose send failed, kept so "retry" can resend it without the
  /// user retyping. Cleared on success or when a new message is sent.
  ChatMessage? _pendingRetry;

  /// Free questions left for today on this device. Seeded optimistically with
  /// the full allowance so the first frame doesn't read as "out of questions"
  /// while prefs are still loading.
  final RxInt freeRemaining = ChatQuotaService.perDay.obs;

  /// How many free questions a device gets each day — for the UI's "3/5" line.
  int get freePerDay => ChatQuotaService.perDay;

  bool get hasMessages => messages.isNotEmpty;
  bool get canRetry => _pendingRetry != null && !isSending.value;

  /// False once today's free questions are spent; the input bar locks and the
  /// screen shows the "come back tomorrow" notice.
  bool get hasFreeQuestions => freeRemaining.value > 0;

  @override
  void onInit() {
    super.onInit();
    refreshQuota();
  }

  /// Re-reads today's allowance. Called on open and when the app comes back to
  /// the foreground, so a device left on the screen past midnight picks up its
  /// new day without a restart.
  Future<void> refreshQuota() async {
    freeRemaining.value = await _quota.remainingToday();
  }

  @override
  void onClose() {
    _service.dispose();
    super.onClose();
  }

  /// Empties the transcript. The gateway keeps no session, so forgetting the
  /// turns here is all a "new chat" is — and it drops what would otherwise be
  /// re-billed as input on the next message.
  void newChat() {
    if (isSending.value) return;
    messages.clear();
    _pendingRetry = null;
  }

  /// Appends [raw] as a user turn and asks the gateway for a reply.
  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || isSending.value) return;

    // Out of free questions: refuse before the message is appended, so nothing
    // is sent and the transcript doesn't gain a turn that never got an answer.
    // Re-read first — the day may have rolled over while the screen sat open.
    if (!hasFreeQuestions) {
      await refreshQuota();
      if (!hasFreeQuestions) return;
    }

    // Matches the gateway's MAX_PROMPT_CHARS, so an over-long message is cut
    // here rather than coming back as a 400 the user cannot act on.
    final capped = text.length > AiGatewayConfig.maxPromptChars
        ? text.substring(0, AiGatewayConfig.maxPromptChars)
        : text;

    _pendingRetry = null;
    messages.add(ChatMessage.user(capped));
    await _request();
  }

  /// Resends the last message that failed, dropping its error bubble first.
  Future<void> retry() async {
    final pending = _pendingRetry;
    if (pending == null || isSending.value) return;

    _pendingRetry = null;
    if (messages.isNotEmpty && messages.last.isError) messages.removeLast();
    await _request();
  }

  Future<void> _request() async {
    isSending.value = true;
    isStreaming.value = false;

    // The card streams in: each snapshot is the answer so far. The bubble is
    // added on the first snapshot (until then the typing indicator stands in),
    // then reassigned as the card grows — reassigning the slot is what makes the
    // RxList notify and repaint.
    int? index;
    String lastText = '';

    void render(ChatCard card, {String? text}) {
      if (text != null && text.isNotEmpty) lastText = text;
      final bubble = ChatMessage.assistant(lastText, card: card);
      if (index == null) {
        index = messages.length;
        messages.add(bubble);
        isStreaming.value = true;
      } else {
        messages[index!] = bubble;
      }
    }

    try {
      await for (final event in _service.sendStream(messages)) {
        if (event.done) {
          final card = event.card;
          if (card != null) {
            render(
              card,
              text: event.reply.isNotEmpty ? event.reply : card.toPlainText(),
            );
          }
          if (kDebugMode) {
            debugPrint(
              'ChatController: ${event.model} '
              'in=${event.inputTokens} out=${event.outputTokens} '
              'card=${card != null}',
            );
          }
        } else if (event.card != null) {
          render(event.card!);
        }
      }

      // A stream that closed without a single card is a gateway version
      // mismatch — surface it as a retryable error rather than an empty bubble.
      if (index == null) {
        throw const AiChatException(
          AiChatException.codeBadResponse,
          retryable: true,
          detail: 'stream closed with no card',
        );
      }
      _pendingRetry = null;
      // Only an answered question costs a free slot — a failed send (and the
      // retry that follows it) is charged once, when it finally succeeds.
      freeRemaining.value = await _quota.consume();
    } on AiChatException catch (e) {
      debugPrint('ChatController: $e');
      // Only offer a retry when the gateway said the failure was transient —
      // resending a rejected request just spends another call from the quota.
      if (e.retryable) _pendingRetry = _lastUserMessage();
      final errorBubble = ChatMessage.assistant(_messageFor(e), errorCode: e.code);
      // Replace the partial answer with the error, or append one if nothing
      // had streamed yet.
      if (index == null) {
        messages.add(errorBubble);
      } else {
        messages[index!] = errorBubble;
      }
    } finally {
      isStreaming.value = false;
      isSending.value = false;
    }
  }

  ChatMessage? _lastUserMessage() {
    for (final m in messages.reversed) {
      if (m.isUser) return m;
    }
    return null;
  }

  /// Maps an error code to a localized line. The gateway's own detail stays in
  /// its log — it can name the model or the key — so the user gets the one
  /// thing that helps: whether to wait, retry, or check the connection.
  String _messageFor(AiChatException e) {
    if (e.isRateLimited) {
      if (e.rateScope == 'day') return 'chat_error_quota_day'.tr;
      final seconds = e.retryAfterSeconds ?? 60;
      return 'chat_error_quota_minute'.trParams({'args1': '$seconds'});
    }

    return switch (e.code) {
      AiChatException.codeNetwork => 'chat_error_offline'.tr,
      AiChatException.codeAuth ||
      'missing_token' ||
      'invalid_token' => 'chat_error_auth'.tr,
      'content_too_long' => 'chat_error_too_long'.tr,
      _ => 'chat_error_generic'.tr,
    };
  }
}
