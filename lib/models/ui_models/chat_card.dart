/// The structured form of an assistant answer: a lead-in, a list of points each
/// with its own icon, an optional closing line, and follow-up questions the user
/// can tap. The gateway parses the model's JSON into this shape, so a bubble
/// either has a [ChatCard] (render the rich layout) or falls back to plain text.
class ChatCard {
  final String intro;
  final List<ChatCardPoint> points;
  final String outro;
  final List<String> suggestions;

  const ChatCard({
    required this.intro,
    required this.points,
    required this.outro,
    required this.suggestions,
  });

  bool get hasOutro => outro.trim().isNotEmpty;

  /// A plain-text flattening, used as the history turn replayed to the model
  /// (and the retry text) when the gateway's own `reply` field is absent.
  String toPlainText() {
    final b = StringBuffer();
    if (intro.isNotEmpty) b.writeln(intro);
    for (final p in points) {
      b.writeln(p.title.isEmpty ? p.body : '${p.title}: ${p.body}');
    }
    if (hasOutro) b.writeln(outro);
    return b.toString().trim();
  }

  static ChatCard? fromJson(Object? raw) {
    if (raw is! Map) return null;

    final points = (raw['points'] as List? ?? const [])
        .map(ChatCardPoint.fromJson)
        .whereType<ChatCardPoint>()
        .toList();

    final suggestions = (raw['suggestions'] as List? ?? const [])
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final intro = (raw['intro'] as String? ?? '').trim();
    if (intro.isEmpty && points.isEmpty) return null;

    return ChatCard(
      intro: intro,
      points: points,
      outro: (raw['outro'] as String? ?? '').trim(),
      suggestions: suggestions,
    );
  }
}

class ChatCardPoint {
  /// One of the gateway's icon keywords (`water`, `heart`, `moon`, ...). The
  /// screen maps it to a Material icon and colour; an unknown value renders as
  /// a neutral info icon.
  final String icon;
  final String title;
  final String body;

  const ChatCardPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  static ChatCardPoint? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final title = (raw['title'] as String? ?? '').trim();
    final body = (raw['body'] as String? ?? '').trim();
    if (title.isEmpty && body.isEmpty) return null;
    return ChatCardPoint(
      icon: (raw['icon'] as String? ?? 'info').trim().toLowerCase(),
      title: title,
      body: body,
    );
  }
}
