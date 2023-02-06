class NoteObject {
  String title;
  final double ID;
  final String date;
  String category;

  NoteObject({
    required this.title,
    required this.ID,
    required this.category,
    required this.date
  });
  NoteObject.fromJson(Map<String, Object?> json)
      : this(
    title: json['title']! as String,
    category: json['category']! as String,
    date: json['date']! as String,
    ID: json['ID']! as double,
  );
  Map<String, Object?> toJson() {
    return {
      'ID': ID,
      'title': title,
      'category': category,
      'date': date,
    };
  }
}