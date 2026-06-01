import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../services/sharedpref.dart';
import '../LoginRepository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository repo;

  LoginViewModel(this.repo);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  StreamSubscription<String?>? _sub;

  /// listen to auth (replaces your initState)
  void startAuthListener(void Function(String userId) onSuccess) {
    _sub = repo.authChanges().listen((userId) async {
      if (userId != null) {
        await sharedprefs().saveUserId(userId);
        onSuccess(userId);
      }
    });
  }

  /// login
  Future<void> login({
    required void Function(String userId) onSuccess,
    required void Function(String message) onError,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userId = await repo.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await sharedprefs().saveUserId(userId);

      onSuccess(userId);
    } on InvalidCredentialsException catch (e) {
      error = e.toString();
      onError(error!);
    } catch (e) {
      error = "An unexpected error occurred";
      onError(error!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// google login
  Future<void> loginWithGoogle() async {
    await repo.loginWithGoogle();
  }

  @override
  void dispose() {
    _sub?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}