import 'dart:convert';

import 'package:dsp_base/app_localize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/models/ui_models/chat_message.dart';

/// A chat request that did not produce an answer.
///
/// [code] is the gateway's own `error` value (`rate_limited`,
/// `upstream_failed`, `invalid_token`, ...) or one of the local codes below, so
/// the UI can pick a message without parsing prose.
class AiChatException implements Exception {
  /// No network, or the gateway could not be reached at all.
  static const String codeNetwork = 'network_unreachable';

  /// Firebase would not hand out an ID token, so the call was never made.
  static const String codeAuth = 'auth_failed';

  /// A 2xx body that did not contain a reply — a gateway version mismatch.
  static const String codeBadResponse = 'bad_response';

  final String code;

  /// Whether trying the same message again is likely to work.
  final bool retryable;

  /// Seconds to wait, when the gateway sent a quota verdict.
  final int? retryAfterSeconds;

  /// Which quota tripped: `minute` or `day`.
  final String? rateScope;

  /// Developer-facing detail. Never shown to the user — the gateway keeps
  /// provider errors in its own log precisely so they do not reach the client.
  final String detail;

  const AiChatException(
    this.code, {
    this.retryable = false,
    this.retryAfterSeconds,
    this.rateScope,
    this.detail = '',
  });

  bool get isRateLimited => code == 'rate_limited';

  @override
  String toString() => 'AiChatException($code): $detail';
}

class AiChatReply {
  final String text;
  final String model;
  final int inputTokens;
  final int outputTokens;

  const AiChatReply({
    required this.text,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
  });
}

/// Client for `server_gateway_ai`'s `POST /v1/chat`.
///
/// The provider key lives on the gateway, so this class only ever handles a
/// Firebase ID token — the identity the server's per-user quota is counted
/// against.
/// Supplies the bearer token for one request. [forceRefresh] is set on the
/// single retry after a 401, when the cached token has expired.
typedef IdTokenProvider = Future<String> Function({bool forceRefresh});

/// Supplies the `vi_VN`-shaped tag the gateway puts in its system prompt.
typedef LocaleTagProvider = String Function();

class AiChatService {
  AiChatService({
    http.Client? client,
    IdTokenProvider? tokenProvider,
    LocaleTagProvider? localeTagProvider,
  }) : _client = client ?? http.Client(),
       _tokenProvider = tokenProvider ?? _firebaseIdToken,
       _localeTag = localeTagProvider ?? _appLocaleTag;

  final http.Client _client;
  final IdTokenProvider _tokenProvider;
  final LocaleTagProvider _localeTag;

  void dispose() => _client.close();

  /// Sends [history] (oldest first, last turn from the user) and returns the
  /// assistant's reply.
  ///
  /// Throws [AiChatException] for every failure; the caller never sees a raw
  /// socket or format error.
  Future<AiChatReply> send(List<ChatMessage> history) async {
    // Error bubbles are ours, not the model's: replaying one would tell the
    // model it had already said "the assistant couldn't answer", and bill for
    // the privilege.
    final usable = history
        .where((m) => !m.isError && m.text.trim().isNotEmpty)
        .toList();
    // Trim from the front: the gateway keeps only the most recent turns
    // anyway, and every turn sent is re-billed as input.
    final turns = usable.length > AiGatewayConfig.maxHistoryTurns
        ? usable.sublist(usable.length - AiGatewayConfig.maxHistoryTurns)
        : usable;

    if (turns.isEmpty || !turns.last.isUser) {
      throw const AiChatException(
        'last_not_user',
        detail: 'the last message must be from the user',
      );
    }

    final body = jsonEncode({
      'messages': turns.map((m) => m.toWireJson()).toList(),
      'locale': _localeTag(),
    });

    // An expired ID token is the routine 401 here, and `getIdToken(true)`
    // fixes it — so one forced-refresh retry, then give up rather than loop.
    var forceRefresh = false;
    while (true) {
      final token = await _tokenProvider(forceRefresh: forceRefresh);
      final response = await _post(body, token);

      if (response.statusCode == 401 && !forceRefresh) {
        forceRefresh = true;
        continue;
      }
      return _parse(response);
    }
  }

  Future<http.Response> _post(String body, String token) async {
    try {
      return await _client
          .post(
            AiGatewayConfig.chatEndpoint,
            headers: {
              'content-type': 'application/json',
              'authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(AiGatewayConfig.requestTimeout);
    } catch (e) {
      throw AiChatException(
        AiChatException.codeNetwork,
        retryable: true,
        detail: '${AiGatewayConfig.chatEndpoint}: $e',
      );
    }
  }

  AiChatReply _parse(http.Response response) {
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(response.body);
      json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      json = <String, dynamic>{};
    }

    if (response.statusCode == 200) {
      final reply = json['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const AiChatException(
          AiChatException.codeBadResponse,
          retryable: true,
          detail: '200 without a reply field',
        );
      }
      final usage = json['usage'];
      return AiChatReply(
        text: reply.trim(),
        model: json['model'] as String? ?? '',
        inputTokens: usage is Map ? (usage['input'] as num?)?.toInt() ?? 0 : 0,
        outputTokens: usage is Map
            ? (usage['output'] as num?)?.toInt() ?? 0
            : 0,
      );
    }

    final code = json['error'] as String? ?? 'http_${response.statusCode}';
    // The gateway states `retryable` on every upstream failure and is the
    // authority on it: a 502 means the provider rejected the call, so resending
    // just spends another one, while a 503 or 504 means it was merely busy.
    // The status heuristic is only for a body that carries no verdict — a
    // proxy's own error page, say. A 429 is always retryable once the wait is
    // over; everything else is the request itself being wrong.
    final declared = json['retryable'];
    final retryable = declared is bool
        ? declared
        : response.statusCode == 429 || response.statusCode >= 500;

    throw AiChatException(
      code,
      retryable: retryable,
      retryAfterSeconds:
          (json['retryAfter'] as num?)?.toInt() ??
          int.tryParse(response.headers['retry-after'] ?? ''),
      rateScope: json['scope'] as String?,
      detail: 'http ${response.statusCode} ${response.body}',
    );
  }

  /// A Firebase ID token for the current user, signing in anonymously when
  /// there is nobody signed in.
  ///
  /// An anonymous uid is all the gateway needs: a stable identity to count the
  /// quota against, not proof of an account. Tokens last an hour and
  /// `getIdToken` refreshes them on its own, so this is fetched per request
  /// rather than cached.
  static Future<String> _firebaseIdToken({bool forceRefresh = false}) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user == null) {
        throw const AiChatException(
          AiChatException.codeAuth,
          detail: 'signInAnonymously returned no user',
        );
      }
      final token = await user.getIdToken(forceRefresh);
      if (token == null || token.isEmpty) {
        throw const AiChatException(
          AiChatException.codeAuth,
          detail: 'getIdToken returned nothing',
        );
      }
      return token;
    } on AiChatException {
      rethrow;
    } catch (e) {
      // Anonymous sign-in disabled in the Firebase console, or the device has
      // no network — both land here, and both mean the call cannot be made.
      debugPrint('AiChatService: could not get an ID token: $e');
      throw AiChatException(
        AiChatException.codeAuth,
        retryable: true,
        detail: '$e',
      );
    }
  }

  /// The app's locale as a `vi_VN`-shaped tag, which is what decides the
  /// language the model answers in.
  static String _appLocaleTag() {
    final locale = CommLocalize.getAppLocale();
    final country = locale.countryCode;
    return (country == null || country.isEmpty)
        ? locale.languageCode
        : '${locale.languageCode}_$country';
  }
}
