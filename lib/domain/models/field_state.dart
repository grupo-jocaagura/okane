class FieldState {
  const FieldState(
    this.value, {
    this.errorText,
    this.suggestions = const <String>[],
  });
  final String value;
  final String? errorText;
  final List<String> suggestions;

  FieldState copyWith({
    String? value,
    String? errorText,
    List<String>? suggestions,
  }) {
    return FieldState(
      value ?? this.value,
      errorText: errorText,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}
