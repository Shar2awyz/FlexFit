import 'package:flutter/material.dart';
import '../SignUpRepository.dart';
import '../model/SignUpRequest.dart';

enum SignUpError { invalidEmail, passwordMismatch }

class SignUpViewModel extends ChangeNotifier {
  final SignUpRepository _repo;

  SignUpViewModel(this._repo);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();

  bool isLoading = false;
  SignUpError? error;

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  Future<void> signUp({
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    if (!_isValidEmail(emailController.text)) {
      error = SignUpError.invalidEmail;
      notifyListeners();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      error = SignUpError.passwordMismatch;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.signUp(SignUpRequest(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
        fullName: fullNameController.text.trim(),
      ));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    fullNameController.dispose();
    super.dispose();
  }
}
