import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_exception.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Champs autorisés pour la mise à jour du profil
  static const _allowedProfileFields = ['first_name', 'last_name'];

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
      throw AuthFailure('unknown_error');
    }
  }

  // User Login
  Future<AuthResponse> loginUser(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // User Logout
  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthFailure('logout_failed');
    }
  }

  // Update first name or last name
  Future<void> updateUserProfile(String field, String value) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthFailure('user_not_logged_in');
    }

    if (!_allowedProfileFields.contains(field)) {
      throw AuthFailure('invalid_field');
    }

    try {
      await _supabase.from('profiles').update({field: value}).eq('id', user.id);
    } catch (e) {
      throw AuthFailure('update_failed');
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String email, String token, OtpType type) async {
    try {
      await _supabase.auth.verifyOTP(email: email, token: token, type: type);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // Resend confirmation email (signup)
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('resend_failed');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // Update password (after OTP verification)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // Reset password with OTP
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
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // Change email with password verification
  Future<void> changeEmail(String password, String newEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) {
      throw AuthFailure('user_not_logged_in');
    }
    if (user.email == newEmail) {
      throw AuthFailure('same_email');
    }

    try {
      // Verify password
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );
      // Update email
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));    
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('unknown_error');
    }
  }

  // Resend email change confirmation
  Future<void> resendEmailChangeConfirmation(String newEmail) async {
    try {
      await _supabase.auth.resend(type: OtpType.emailChange, email: newEmail);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e.code));
    } catch (e) {
      throw AuthFailure('resend_failed');
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
      case 'email_exists':
        return 'email_exists';
      case 'email_conflict_identity_not_deletable':
        return 'email_conflict';
      default:
        return 'unknown_error';
    }
  }
}
