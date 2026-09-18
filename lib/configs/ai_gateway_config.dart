/// Where the chat screen sends its messages.
///
/// The app holds no provider key: it talks to `server_gateway_ai`, which
/// verifies the Firebase ID token, enforces the per-user quota and forwards
/// the conversation to whichever upstream is configured there — OpenAI,
/// Gemini, DeepSeek, Grok, or any OpenAI-compatible proxy. Swapping providers
/// is a change on the server, so nothing here needs to know which one answers.
class AiGatewayConfig {
  /// Base URL of the gateway, without a trailing slash.
  ///
  /// Override per build without touching the source:
  /// `flutter run --dart-define=AI_GATEWAY_URL=https://gateway.example.com`.
  ///
  /// The default is the dev machine on the LAN, which is what a physical
  /// handset needs — but it is a DHCP address, so it goes stale whenever the
  /// router hands out a different one and the app then fails with
  /// `network_unreachable`. Check with `ipconfig` and prefer the
  /// `--dart-define` above over editing this line. An Android emulator wants
  /// `http://10.0.2.2:8080` (the host's loopback as seen from inside);
  /// an iOS simulator or a Flutter web build wants `http://localhost:8080`.
  ///
  /// Plain http reaches the gateway only in a debug build: the cleartext
  /// exception lives in `android/app/src/debug/AndroidManifest.xml`, so a
  /// release build must be pointed at an https deployment.
  static const String baseUrl = String.fromEnvironment(
    'AI_GATEWAY_URL',
    defaultValue: 'http://192.168.1.46:8080',
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
