class Verse {
  final int number;
  final String text;
  final bool isHighlighted;

  Verse({
    required this.number,
    required this.text,
    this.isHighlighted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'isHighlighted': isHighlighted,
    };
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'],
      text: json['text'],
      isHighlighted: json['isHighlighted'] ?? false,
    );
  }
}
