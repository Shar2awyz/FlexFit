import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class supa {
  final supabase = Supabase.instance.client;
  final supauth = Supabase.instance.client.auth;

  Future<void> signup(
      String email,
      String password,
      String username,
      String fullname,
      String gender,
      ) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) throw Exception("Signup failed");

    await supabase.from('Users').insert({
      'username': username,
      'fullname': fullname,
      'Gender': gender,
      'email': email,
    });
  }


  Future<String?> login(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected authentication error";
    }
  }

  /// Call this ONCE after the OAuth redirect lands (e.g. in your callback route).
  /// signInWithOAuth is a redirect — the session is only available after the
  /// deep-link brings the user back to the app.


  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );

  }


  Future<void> logout() async {
    await supauth.signOut();
  }

  Future<Map<String, dynamic>?> getuserdata(String userid) async {


    final data = await supabase
        .from('Users')
        .select('username, email, image_url') // add whatever columns you need
        .eq('id', userid)
        .single();

    return data; // returns a Map
  }


  // ✅ Now correctly outside getuserdata, and uses 'username' (fixed typo)

  Future<String?> getGoogleProfileImage(String userId) async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;

    if (user == null) return null;

    // Make sure it's the same user (optional safety)
    if (user.id != userId) return null;

    final metadata = user.userMetadata;

    if (metadata == null) return null;

    return metadata['avatar_url']; // Google image URL
  }
Future<dynamic>  getuserphoto(String userid)async{
    final data = await supabase
        .from('Users')
        .select('image_url') // add whatever columns you need
        .eq('id', userid)
        .single();

    return data;




  }




  Future<String?> uploadImage(File file,String userid) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage
          .from('UserImages') // bucket name
          .upload(fileName, file);

      final imageUrl = supabase.storage
          .from('UserImages')
          .getPublicUrl(fileName);
     await Supabase.instance.client.from('Users').update({'image_url':imageUrl}).eq('id', userid);
      return imageUrl;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }

  }
}