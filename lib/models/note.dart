class Note {
  final String id;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final String noteText;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.noteText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'noteText': noteText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      bookName: json['bookName'],
      chapterNumber: json['chapterNumber'],
      verseNumber: json['verseNumber'],
      verseText: json['verseText'],
      noteText: json['noteText'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
