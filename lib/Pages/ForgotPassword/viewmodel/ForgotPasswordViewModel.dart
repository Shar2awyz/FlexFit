import 'package:flutter/material.dart';
import '../ForgotPasswordRepository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordRepository _repo;

  ForgotPasswordViewModel(this._repo);

  // Forgot Password Phase
  final emailController = TextEditingController();
  bool isLoading = false;
  String? error;
  bool isEmailSent = false;

  // Reset Password Phase
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isResetLoading = false;
  String? resetError;
  bool isPasswordReset = false;

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  Future<void> sendResetEmail({
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      error = "Email cannot be empty";
      notifyListeners();
      return;
    }
    if (!_isValidEmail(email)) {
      error = "Invalid email format";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    isEmailSent = false;
    notifyListeners();

    try {
      await _repo.sendResetEmail(email);
      isEmailSent = true;
      notifyListeners();
      onSuccess();
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      onError(error!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      resetError = "Password cannot be empty";
      notifyListeners();
      return;
    }

    if (password.length < 6) {
      resetError = "Password must be at least 6 characters long";
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      resetError = "Passwords do not match";
      notifyListeners();
      return;
    }

    isResetLoading = true;
    resetError = null;
    isPasswordReset = false;
    notifyListeners();

    try {
      await _repo.updatePassword(password);
      isPasswordReset = true;
      notifyListeners();
      onSuccess();
    } catch (e) {
      resetError = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      onError(resetError!);
    } finally {
      isResetLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
