class AuthFailure implements Exception {
  final String code;
  AuthFailure(this.code);

  @override
  String toString() => code;
}