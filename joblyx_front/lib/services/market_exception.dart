class MarketFailure implements Exception {
  final String code;
  MarketFailure(this.code);

  @override
  String toString() => code;
}
