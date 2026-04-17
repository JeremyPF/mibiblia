class Note {
  final String id;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final String noteText;
  final DateTime createdAt;
  // Formato de la nota
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final bool darkBackground;
  final int textColor;

  Note({
    required this.id,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.noteText,
    required this.createdAt,
    this.fontFamily = 'Newsreader',
    this.fontSize = 16.0,
    this.lineHeight = 1.8,
    this.darkBackground = false,
    this.textColor = 0xFF2E342F,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookName': bookName,
        'chapterNumber': chapterNumber,
        'verseNumber': verseNumber,
        'verseText': verseText,
        'noteText': noteText,
        'createdAt': createdAt.toIso8601String(),
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'darkBackground': darkBackground,
        'textColor': textColor,
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        bookName: j['bookName'],
        chapterNumber: j['chapterNumber'],
        verseNumber: j['verseNumber'],
        verseText: j['verseText'],
        noteText: j['noteText'],
        createdAt: DateTime.parse(j['createdAt']),
        fontFamily: j['fontFamily'] ?? 'Newsreader',
        fontSize: (j['fontSize'] ?? 16.0).toDouble(),
        lineHeight: (j['lineHeight'] ?? 1.8).toDouble(),
        darkBackground: j['darkBackground'] ?? false,
        textColor: j['textColor'] ?? 0xFF2E342F,
      );

  Note copyWith({
    String? noteText,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    bool? darkBackground,
    int? textColor,
  }) => Note(
        id: id,
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        noteText: noteText ?? this.noteText,
        createdAt: createdAt,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        darkBackground: darkBackground ?? this.darkBackground,
        textColor: textColor ?? this.textColor,
      );
}
