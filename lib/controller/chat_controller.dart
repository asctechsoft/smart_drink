import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/models/ui_models/chat_message.dart';
import 'package:waternudge/services/application/ai_chat_service.dart';

/// State for the "Hỏi AI" screen.
///
/// Holds the transcript, talks to [AiChatService] and turns a failed request
/// into an error bubble the user can retry — the history itself is never
/// written to the database, so leaving the screen starts a fresh conversation.
class ChatController extends GetxController {
  static ChatController get to => Get.find();

  ChatController({AiChatService? service})
    : _service = service ?? AiChatService();

  final AiChatService _service;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// True while a reply is in flight: the input is disabled and the typing
  /// bubble is shown.
  final RxBool isSending = false.obs;

  /// The message whose send failed, kept so "retry" can resend it without the
  /// user retyping. Cleared on success or when a new message is sent.
  ChatMessage? _pendingRetry;

  bool get hasMessages => messages.isNotEmpty;
  bool get canRetry => _pendingRetry != null && !isSending.value;

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
    try {
      final reply = await _service.send(messages);
      messages.add(ChatMessage.assistant(reply.text));
      if (kDebugMode) {
        debugPrint(
          'ChatController: ${reply.model} '
          'in=${reply.inputTokens} out=${reply.outputTokens}',
        );
      }
    } on AiChatException catch (e) {
      debugPrint('ChatController: $e');
      // Only offer a retry when the gateway said the failure was transient —
      // resending a rejected request just spends another call from the quota.
      if (e.retryable) _pendingRetry = _lastUserMessage();
      messages.add(
        ChatMessage.assistant(_messageFor(e), errorCode: e.code),
      );
    } finally {
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
