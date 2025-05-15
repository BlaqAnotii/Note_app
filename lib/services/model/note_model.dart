class Note {
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
    final bool isPinned;  // add this property


  Note({
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
        this.isPinned = false,

  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
              'isPinned': isPinned,

      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        title: json['title'],
        content: json['content'],
        category: json['category'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
              isPinned: json['isPinned'] ?? false,

      );
}