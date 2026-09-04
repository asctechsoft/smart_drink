/// Where the chat screen sends its messages.
///
/// The app holds no provider key: it talks to `server_gateway_ai`, which
/// verifies the Firebase ID token, enforces the per-user quota and forwards
/// the conversation to OpenAI or Gemini. Swapping providers is a change on the
/// server, so nothing here needs to know which one answers.
class AiGatewayConfig {
  /// Base URL of the gateway, without a trailing slash.
  ///
  /// Override per build without touching the source:
  /// `flutter run --dart-define=AI_GATEWAY_URL=https://gateway.example.com`.
  /// The default points at a desktop-hosted dev server as seen from the
  /// Android emulator (`10.0.2.2` is the host's loopback); an iOS simulator or
  /// Flutter web build wants `http://localhost:8080`.
  static const String baseUrl = String.fromEnvironment(
    'AI_GATEWAY_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static Uri get chatEndpoint => Uri.parse('$baseUrl/v1/chat');

  /// Client-side deadline. Deliberately longer than the gateway's own
  /// `UPSTREAM_TIMEOUT_MS` (30s by default) so a slow provider surfaces as the
  /// server's 504 — which says whether retrying is worthwhile — rather than as
  /// a local timeout that cannot tell.
  static const Duration requestTimeout = Duration(seconds: 40);

  /// Turns kept on screen and replayed to the model. The gateway trims to its
  /// own `MAX_HISTORY_TURNS` regardless; matching it here means the user's
  /// scrollback and what the model actually sees do not silently diverge.
  static const int maxHistoryTurns = 12;

  /// Mirrors the gateway's `MAX_PROMPT_CHARS`, so an over-long message is
  /// caught in the text field instead of coming back as a 400.
  static const int maxPromptChars = 1000;
}
