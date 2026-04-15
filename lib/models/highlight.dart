class Highlight {
  final String id;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'],
      bookName: json['bookName'],
      chapterNumber: json['chapterNumber'],
      verseNumber: json['verseNumber'],
      verseText: json['verseText'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
