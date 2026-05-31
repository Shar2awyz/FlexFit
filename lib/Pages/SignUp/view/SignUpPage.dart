import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled6/Pages/Components/errorsnackbar.dart';
import 'package:untitled6/Pages/Components/LogInComponents/buildTextField.dart';
import 'package:untitled6/Pages/Components/LogInComponents/ContinueWithGoogle.dart';
import '../SignUpRepository.dart';
import '../viewmodel/SignUpViewModel.dart';
import 'package:lottie/lottie.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(SignUpRepository()),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: vm.isLoading
          ? Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'animation/Icon gym for Sporttler.json',
                  fit: BoxFit.contain,
                ),
              ),
            )
          : SafeArea(
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                buildTextField(
                  hint: 'Full Name',
                  icon: Icons.person,
                  controller: vm.fullNameController,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  hint: 'Username',
                  icon: Icons.person_outline,
                  controller: vm.usernameController,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  hint: 'Email',
                  icon: Icons.email,
                  controller: vm.emailController,
                ),
                if (vm.error == SignUpError.invalidEmail)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Invalid email',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 15),
                buildTextField(
                  hint: 'Password',
                  icon: Icons.lock,
                  controller: vm.passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  controller: vm.confirmPasswordController,
                  obscure: true,
                ),
                if (vm.error == SignUpError.passwordMismatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Passwords do not match',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: vm.isLoading
                        ? null
                        : () => vm.signUp(
                              onSuccess: () => Navigator.pop(context),
                              onError: (msg) =>
                                  ErrorSnackBar.show(context, msg),
                            ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Continuewithgoogle(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
