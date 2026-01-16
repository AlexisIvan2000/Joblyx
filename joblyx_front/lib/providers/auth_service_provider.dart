import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});