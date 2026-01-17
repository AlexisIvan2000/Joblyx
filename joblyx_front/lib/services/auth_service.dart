import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_exception.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User Registration
  Future<AuthResponse> registerUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'profile_picture':
              'https://ui-avatars.com/api/?name=$firstName+$lastName&background=random',
        },
      );

    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw Exception('Unknown error');
    }
  }

  // User Login
  Future<AuthResponse> loginUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw Exception('Unknown error');
    }
  }

  // User Logout
  Future<void> logoutUser() async {
    await _supabase.auth.signOut();
  }
  
  // Update first name or last name
  Future<void> updateUserProfile(String field, String value) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase
          .from('profiles')
          .update({field: value})
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update user profile');
    }
  }

  Future<void> verifyOTP(String email, String token, OtpType type) async{
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw Exception('Unknown error');
      
    }
  }

  Future<void> resendConfirmationEmail(String email) async{
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Error resending confirmation email: $e');
    }
  }
  Future<void> resendResetPasswordEmail(String email) async {
    try {
      // Utiliser resetPasswordForEmail au lieu de resend pour le recovery
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw Exception('Unknown error');
    }
  }
  
  // Mettre à jour le mot de passe (après vérification OTP)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    }on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw Exception('Unknown error');
    }
  }

  String _mapAuthException(String? code) {
    switch (code) {
      case 'weak_password':
        return 'weak_password';
      case 'user_already_exists':
        return 'user_already_exists';
      case 'session_not_found':
        return 'no_session_found';
      case 'session_expired':
        return 'session_expired';
      case 'same_password':
        return 'same_password';
      case 'invalid_credentials':
        return 'invalid_credentials';
      case 'email_not_confirmed':
        return 'email_not_confirmed';
      case 'over_email_send_rate_limit':
        return 'over_email_send_rate_limit';
      case 'user_not_found':
        return 'user_not_found';
      case 'bad_code_verifier':
        return 'bad_code';
      case 'otp_expired':
        return 'otp_expired';
      default:
        return 'unknown_error';
    }
  }
}
