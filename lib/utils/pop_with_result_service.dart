/// PopResult
class PopWithResults<T> {
  /// popped from this page...
  final String fromPage;

  /// pop until this page...
  final String toPage;

  /// results...
  final Map<String,T>? results;

  /// Constructor...
  PopWithResults({required this.fromPage, required this.toPage, this.results});
}
