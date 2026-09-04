/// One bubble in the AI chat screen.
///
/// [ChatRole] mirrors the roles the gateway accepts — there is deliberately no
/// `system` role: the instructions live on the server and are not negotiable
/// from the client.
enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime sentAt;

  /// Set on an assistant bubble that stands in for a failed request, so the UI
  /// can offer a retry instead of styling it as a real answer.
  final String? errorCode;

  ChatMessage({
    required this.role,
    required this.text,
    DateTime? sentAt,
    this.errorCode,
  }) : sentAt = sentAt ?? DateTime.now();

  ChatMessage.user(String text) : this(role: ChatRole.user, text: text);

  ChatMessage.assistant(String text, {String? errorCode})
    : this(role: ChatRole.assistant, text: text, errorCode: errorCode);

  bool get isUser => role == ChatRole.user;
  bool get isError => errorCode != null;

  /// `HH:mm`, the only form the bubbles show.
  String get timeLabel =>
      '${sentAt.hour.toString().padLeft(2, '0')}:'
      '${sentAt.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toWireJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': text,
  };
}
