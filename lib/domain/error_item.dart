class ErrorItem {
  const ErrorItem({
    required this.title,
    required this.code,
    required this.description,
    this.meta = const <String, dynamic>{},
  });
  final String title;
  final String code;
  final String description;
  final Map<String, dynamic> meta;

  @override
  String toString() {
    return '$title ($code): $description${meta.isNotEmpty ? " | Meta: $meta" : ""}';
  }
}
