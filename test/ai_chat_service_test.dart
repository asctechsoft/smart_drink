import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/models/ui_models/chat_message.dart';
import 'package:waternudge/services/application/ai_chat_service.dart';

/// A stand-in for Firebase, so the gateway contract can be tested without a
/// live project. Records how many times a fresh token was demanded.
class _FakeTokens {
  int calls = 0;
  int refreshes = 0;

  Future<String> provide({bool forceRefresh = false}) async {
    calls++;
    if (forceRefresh) refreshes++;
    return forceRefresh ? 'fresh-token' : 'cached-token';
  }
}

AiChatService _serviceReturning(
  List<http.Response> responses, {
  _FakeTokens? tokens,
  List<http.Request>? captured,
}) {
  final queue = List<http.Response>.from(responses);
  final client = MockClient((request) async {
    captured?.add(request);
    return queue.isEmpty ? responses.last : queue.removeAt(0);
  });
  return AiChatService(
    client: client,
    tokenProvider: (tokens ?? _FakeTokens()).provide,
    localeTagProvider: () => 'vi_VN',
  );
}

http.Response _ok({String reply = 'Uong khoang 2 lit moi ngay.'}) =>
    http.Response(
      jsonEncode({
        'reply': reply,
        'model': 'gpt-4o-mini',
        'usage': {'input': 210, 'output': 88},
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _err(
  int status,
  Map<String, dynamic> body, {
  Map<String, String> headers = const {},
}) => http.Response(jsonEncode(body), status, headers: headers);

void main() {
  group('AiChatService.send', () {
    test('parses a gateway reply', () async {
      final service = _serviceReturning([_ok()]);

      final reply = await service.send([ChatMessage.user('Hoi gi day?')]);

      expect(reply.text, 'Uong khoang 2 lit moi ngay.');
      expect(reply.model, 'gpt-4o-mini');
      expect(reply.inputTokens, 210);
      expect(reply.outputTokens, 88);
    });

    test('sends the bearer token, the turns and a locale', () async {
      final captured = <http.Request>[];
      final service = _serviceReturning([_ok()], captured: captured);

      await service.send([
        ChatMessage.user('Uong bao nhieu?'),
        ChatMessage.assistant('Khoang 2 lit.'),
        ChatMessage.user('Con khi tap thi sao?'),
      ]);

      expect(captured, hasLength(1));
      final request = captured.single;
      expect(request.url, AiGatewayConfig.chatEndpoint);
      expect(request.headers['authorization'], 'Bearer cached-token');

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['locale'], isA<String>());
      expect(body['messages'], [
        {'role': 'user', 'content': 'Uong bao nhieu?'},
        {'role': 'assistant', 'content': 'Khoang 2 lit.'},
        {'role': 'user', 'content': 'Con khi tap thi sao?'},
      ]);
    });

    test('trims history to the gateway cap, keeping the newest turns', () async {
      final captured = <http.Request>[];
      final service = _serviceReturning([_ok()], captured: captured);

      // One more than the cap, and an odd count so the last turn stays a user
      // turn once the front is dropped.
      final history = [
        for (var i = 0; i < AiGatewayConfig.maxHistoryTurns + 1; i++)
          i.isEven ? ChatMessage.user('u$i') : ChatMessage.assistant('a$i'),
        ChatMessage.user('newest'),
      ];

      await service.send(history);

      final messages =
          (jsonDecode(captured.single.body) as Map<String, dynamic>)['messages']
              as List;
      expect(messages, hasLength(AiGatewayConfig.maxHistoryTurns));
      expect(messages.last, {'role': 'user', 'content': 'newest'});
      // The oldest turns are the ones dropped.
      expect(messages.first, isNot({'role': 'user', 'content': 'u0'}));
    });

    test('rejects a history whose last turn is not the user', () async {
      final service = _serviceReturning([_ok()]);

      expect(
        () => service.send([
          ChatMessage.user('hi'),
          ChatMessage.assistant('hello'),
        ]),
        throwsA(
          isA<AiChatException>().having((e) => e.code, 'code', 'last_not_user'),
        ),
      );
    });

    test('retries once with a refreshed token after a 401', () async {
      final tokens = _FakeTokens();
      final captured = <http.Request>[];
      final service = _serviceReturning(
        [_err(401, {'error': 'invalid_token'}), _ok()],
        tokens: tokens,
        captured: captured,
      );

      final reply = await service.send([ChatMessage.user('hi')]);

      expect(reply.text, isNotEmpty);
      expect(tokens.refreshes, 1);
      expect(captured, hasLength(2));
      expect(captured.last.headers['authorization'], 'Bearer fresh-token');
    });

    test('gives up after one refresh rather than looping on 401', () async {
      final tokens = _FakeTokens();
      final service = _serviceReturning([
        _err(401, {'error': 'invalid_token'}),
        _err(401, {'error': 'invalid_token'}),
      ], tokens: tokens);

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>()
              .having((e) => e.code, 'code', 'invalid_token')
              .having((e) => e.retryable, 'retryable', false),
        ),
      );
      expect(tokens.calls, 2);
    });

    test('surfaces the quota verdict from a 429', () async {
      final service = _serviceReturning([
        _err(429, {
          'error': 'rate_limited',
          'scope': 'day',
          'retryAfter': 3600,
        }, headers: {'retry-after': '3600'}),
      ]);

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>()
              .having((e) => e.isRateLimited, 'isRateLimited', true)
              .having((e) => e.rateScope, 'rateScope', 'day')
              .having((e) => e.retryAfterSeconds, 'retryAfter', 3600)
              .having((e) => e.retryable, 'retryable', true),
        ),
      );
    });

    test('marks a provider 503 retryable and a 502 not', () async {
      final transient = _serviceReturning([
        _err(503, {'error': 'upstream_failed', 'retryable': true}),
      ]);
      await expectLater(
        transient.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>()
              .having((e) => e.code, 'code', 'upstream_failed')
              .having((e) => e.retryable, 'retryable', true),
        ),
      );

      final permanent = _serviceReturning([
        _err(502, {'error': 'upstream_failed', 'retryable': false}),
      ]);
      await expectLater(
        permanent.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>().having((e) => e.retryable, 'retryable', false),
        ),
      );
    });

    test('reports a validation rejection under the gateway code', () async {
      final service = _serviceReturning([
        _err(400, {'error': 'content_too_long', 'message': 'too long'}),
      ]);

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>()
              .having((e) => e.code, 'code', 'content_too_long')
              .having((e) => e.retryable, 'retryable', false),
        ),
      );
    });

    test('turns an unreachable gateway into a retryable network error', () async {
      final service = AiChatService(
        client: MockClient((_) => throw const _SocketFailure()),
        tokenProvider: _FakeTokens().provide,
        localeTagProvider: () => 'vi_VN',
      );

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>()
              .having((e) => e.code, 'code', AiChatException.codeNetwork)
              .having((e) => e.retryable, 'retryable', true),
        ),
      );
    });

    test('treats a 200 without a reply as a bad response', () async {
      final service = _serviceReturning([
        http.Response(jsonEncode({'model': 'gpt-4o-mini'}), 200),
      ]);

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>().having(
            (e) => e.code,
            'code',
            AiChatException.codeBadResponse,
          ),
        ),
      );
    });

    test('does not choke on a non-JSON error body', () async {
      final service = _serviceReturning([
        http.Response('<html>502 Bad Gateway</html>', 502),
      ]);

      await expectLater(
        service.send([ChatMessage.user('hi')]),
        throwsA(
          isA<AiChatException>().having((e) => e.code, 'code', 'http_502'),
        ),
      );
    });
  });

  group('ChatMessage', () {
    test('wire form carries only role and content', () {
      expect(ChatMessage.user('hi').toWireJson(), {
        'role': 'user',
        'content': 'hi',
      });
      expect(ChatMessage.assistant('yo').toWireJson(), {
        'role': 'assistant',
        'content': 'yo',
      });
    });

    test('timeLabel is zero-padded HH:mm', () {
      final message = ChatMessage(
        role: ChatRole.user,
        text: 'hi',
        sentAt: DateTime(2026, 9, 4, 9, 5),
      );
      expect(message.timeLabel, '09:05');
    });
  });
}

class _SocketFailure implements Exception {
  const _SocketFailure();
  @override
  String toString() => 'connection refused';
}
