class Bookmark {
  final String reference;
  final String text;
  final String dateAdded;

  Bookmark({
    required this.reference,
    required this.text,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'text': text,
      'dateAdded': dateAdded,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      reference: json['reference'],
      text: json['text'],
      dateAdded: json['dateAdded'],
    );
  }
}
