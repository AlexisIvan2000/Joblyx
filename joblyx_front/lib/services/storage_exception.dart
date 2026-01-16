class StorageFailure implements Exception {
  final String code;
  StorageFailure(this.code);

  @override
  String toString() => code;
}
