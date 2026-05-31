import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final supabase = Supabase.instance.client;

  Future<String> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user == null) {
      throw Exception("Login failed");
    }

    return user.id;
  }

  Future<void> loginWithGoogle() async {
    await supabase.auth.signOut();
    await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Stream<String?> authChanges() {
    return supabase.auth.onAuthStateChange.map((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        return null;
      }
      final session = data.session;
      return session?.user.id;
    });
  }
}