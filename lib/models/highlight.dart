class Highlight {
  final String id;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final DateTime createdAt;
  final String category;   // nombre de la categoría
  final int color;         // Color.value (ARGB int)

  Highlight({
    required this.id,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.createdAt,
    this.category = 'General',
    this.color = 0xFFFFD54F, // amarillo por defecto
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookName': bookName,
        'chapterNumber': chapterNumber,
        'verseNumber': verseNumber,
        'verseText': verseText,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        'color': color,
      };

  factory Highlight.fromJson(Map<String, dynamic> j) => Highlight(
        id: j['id'],
        bookName: j['bookName'],
        chapterNumber: j['chapterNumber'],
        verseNumber: j['verseNumber'],
        verseText: j['verseText'],
        createdAt: DateTime.parse(j['createdAt']),
        category: j['category'] ?? 'General',
        color: j['color'] ?? 0xFFFFD54F,
      );
}
