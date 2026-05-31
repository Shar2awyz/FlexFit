import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  final supabase = Supabase.instance.client;

  Future<void> sendResetEmail(String email) async {
    final String redirectUrl;
    if (kIsWeb) {
      redirectUrl = 'https://vocal-starship-62096d.netlify.app/';
    } else {
      redirectUrl = 'io.supabase.flutter://login-callback';
    }

    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectUrl,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
    await supabase.auth.signOut();
  }
}
