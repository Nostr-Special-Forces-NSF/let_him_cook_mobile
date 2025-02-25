class Tag {
  final String title;
  final String? emoji;

  Tag({
    required this.title,
    this.emoji,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      title: json['title'] as String,
      emoji: json['emoji'] as String?,
    );
  }

  Tag copyWith({
    String? title,
    String? emoji,
  }) {
    return Tag(
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
    );
  }
}
