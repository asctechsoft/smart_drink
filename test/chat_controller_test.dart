import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/controller/chat_controller.dart';
import 'package:waternudge/services/application/ai_chat_service.dart';

/// Builds a controller whose gateway answers with [responses] in order,
/// repeating the last one once the queue runs dry.
ChatController _controllerFor(
  List<http.Response> responses, {
  List<http.Request>? captured,
}) {
  final queue = List<http.Response>.from(responses);
  return ChatController(
    service: AiChatService(
      client: MockClient((request) async {
        captured?.add(request);
        return queue.length > 1 ? queue.removeAt(0) : queue.last;
      }),
      tokenProvider: ({bool forceRefresh = false}) async => 'token',
      localeTagProvider: () => 'vi_VN',
    ),
  );
}

http.Response _ok(String reply) => http.Response(
  jsonEncode({
    'reply': reply,
    'model': 'gpt-4o-mini',
    'usage': {'input': 10, 'output': 20},
  }),
  200,
);

void main() {
  setUp(() {
    // Stands in for the `chat_error_*` entries in lib/xml_strings. `@args1` is
    // what the XML loader turns `%1$s` into, so the placeholder is substituted
    // here the same way it is in the app.
    Get.locale = const Locale('en', 'US');
    Get.addTranslations({
      'en_US': {
        'chat_error_offline': 'No internet connection.',
        'chat_error_auth': 'Could not verify your device.',
        'chat_error_quota_minute': 'Try again in @args1 seconds.',
        'chat_error_quota_day': 'You have used up today\'s questions.',
        'chat_error_too_long': 'That message is too long.',
        'chat_error_generic': 'The assistant could not answer right now.',
      },
    });
  });

  tearDown(Get.reset);

  test('appends the user turn and then the reply', () async {
    final chat = _controllerFor([_ok('Khoang 2 lit moi ngay.')]);

    await chat.send('Uong bao nhieu nuoc la du?');

    expect(chat.messages, hasLength(2));
    expect(chat.messages.first.isUser, isTrue);
    expect(chat.messages.first.text, 'Uong bao nhieu nuoc la du?');
    expect(chat.messages.last.isUser, isFalse);
    expect(chat.messages.last.text, 'Khoang 2 lit moi ngay.');
    expect(chat.messages.last.isError, isFalse);
    expect(chat.isSending.value, isFalse);
  });

  test('ignores an empty message and a send while one is in flight', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([_ok('ok')], captured: captured);

    await chat.send('   ');
    expect(chat.messages, isEmpty);

    final first = chat.send('hi');
    // The second call lands while `isSending` is still true.
    await chat.send('again');
    await first;

    expect(captured, hasLength(1));
    expect(chat.messages.where((m) => m.isUser).map((m) => m.text), ['hi']);
  });

  test('caps a message at the gateway prompt limit', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([_ok('ok')], captured: captured);

    await chat.send('a' * (AiGatewayConfig.maxPromptChars + 500));

    expect(
      chat.messages.first.text.length,
      AiGatewayConfig.maxPromptChars,
    );
    final sent =
        (jsonDecode(captured.single.body) as Map<String, dynamic>)['messages']
            as List;
    expect(
      (sent.single as Map)['content'],
      hasLength(AiGatewayConfig.maxPromptChars),
    );
  });

  test('adds a retryable error bubble and resends on retry', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([
      http.Response(
        jsonEncode({'error': 'upstream_failed', 'retryable': true}),
        503,
      ),
      _ok('Day roi.'),
    ], captured: captured);

    await chat.send('hi');

    expect(chat.messages, hasLength(2));
    expect(chat.messages.last.isError, isTrue);
    expect(chat.messages.last.errorCode, 'upstream_failed');
    expect(chat.canRetry, isTrue);

    await chat.retry();

    // The error bubble is replaced by the answer, and the question is not
    // duplicated.
    expect(chat.messages.map((m) => m.text), ['hi', 'Day roi.']);
    expect(chat.canRetry, isFalse);
    expect(captured, hasLength(2));
  });

  test('offers no retry when the gateway called the failure permanent', () async {
    final chat = _controllerFor([
      http.Response(
        jsonEncode({'error': 'upstream_failed', 'retryable': false}),
        502,
      ),
    ]);

    await chat.send('hi');

    expect(chat.messages.last.isError, isTrue);
    expect(chat.canRetry, isFalse);

    // A retry that is not on offer must not spend a call either.
    await chat.retry();
    expect(chat.messages, hasLength(2));
  });

  test('picks the quota message matching the scope', () async {
    final minute = _controllerFor([
      http.Response(
        jsonEncode({
          'error': 'rate_limited',
          'scope': 'minute',
          'retryAfter': 42,
        }),
        429,
      ),
    ]);
    await minute.send('hi');
    expect(minute.messages.last.text, contains('42'));

    final day = _controllerFor([
      http.Response(
        jsonEncode({'error': 'rate_limited', 'scope': 'day'}),
        429,
      ),
    ]);
    await day.send('hi');
    expect(day.messages.last.text, "You have used up today's questions.");
  });

  test('reports an unreachable gateway as the offline message', () async {
    final chat = ChatController(
      service: AiChatService(
        client: MockClient((_) => throw Exception('connection refused')),
        tokenProvider: ({bool forceRefresh = false}) async => 'token',
        localeTagProvider: () => 'vi_VN',
      ),
    );

    await chat.send('hi');

    expect(chat.messages.last.text, 'No internet connection.');
    expect(chat.canRetry, isTrue);
  });

  test('newChat clears the transcript and the pending retry', () async {
    final chat = _controllerFor([
      http.Response(
        jsonEncode({'error': 'upstream_failed', 'retryable': true}),
        503,
      ),
    ]);

    await chat.send('hi');
    expect(chat.canRetry, isTrue);

    chat.newChat();

    expect(chat.messages, isEmpty);
    expect(chat.canRetry, isFalse);
    expect(chat.hasMessages, isFalse);
  });

  test('replays earlier turns so the model keeps context', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([
      _ok('Khoang 2 lit.'),
      _ok('Them 500ml khi tap.'),
    ], captured: captured);

    await chat.send('Uong bao nhieu?');
    await chat.send('Con khi tap thi sao?');

    final second =
        (jsonDecode(captured.last.body) as Map<String, dynamic>)['messages']
            as List;
    expect(second, [
      {'role': 'user', 'content': 'Uong bao nhieu?'},
      {'role': 'assistant', 'content': 'Khoang 2 lit.'},
      {'role': 'user', 'content': 'Con khi tap thi sao?'},
    ]);
  });

  test('does not replay an error bubble when the next message is sent', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([
      http.Response(
        jsonEncode({'error': 'upstream_failed', 'retryable': false}),
        502,
      ),
      _ok('Day roi.'),
    ], captured: captured);

    await chat.send('hi');
    // No retry here: the bubble stays on screen, and the user simply asks
    // again. The model must not be told it already gave up once.
    await chat.send('con nua?');

    final sent =
        (jsonDecode(captured.last.body) as Map<String, dynamic>)['messages']
            as List;
    expect(sent, [
      {'role': 'user', 'content': 'hi'},
      {'role': 'user', 'content': 'con nua?'},
    ]);
  });

  test('does not replay an error bubble as an assistant turn', () async {
    final captured = <http.Request>[];
    final chat = _controllerFor([
      http.Response(
        jsonEncode({'error': 'upstream_failed', 'retryable': true}),
        503,
      ),
      _ok('Day roi.'),
    ], captured: captured);

    await chat.send('hi');
    await chat.retry();

    final resent =
        (jsonDecode(captured.last.body) as Map<String, dynamic>)['messages']
            as List;
    expect(resent, [
      {'role': 'user', 'content': 'hi'},
    ]);
  });
}
