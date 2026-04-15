import 'verse.dart';

class Chapter {
  final int bookId;
  final int chapterNumber;
  final List<Verse> verses;

  Chapter({
    required this.bookId,
    required this.chapterNumber,
    required this.verses,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'chapterNumber': chapterNumber,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      bookId: json['bookId'],
      chapterNumber: json['chapterNumber'],
      verses: (json['verses'] as List)
          .map((v) => Verse.fromJson(v))
          .toList(),
    );
  }
}
