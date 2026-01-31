class HistoryFailure implements Exception {
  final String code;

  HistoryFailure(this.code);

  @override
  String toString() => 'HistoryFailure: $code';
}
