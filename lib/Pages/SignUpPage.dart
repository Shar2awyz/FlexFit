import 'package:flutter/material.dart';
import 'package:untitled6/Pages/Components/errorsnackbar.dart';
import 'package:untitled6/services/services.dart';
import 'Components/LogInComponents/ContinueWithGoogle.dart';
import 'Components/LogInComponents/buildTextField.dart';

enum errors {
  InvalidEmail,
  PasswordDismatch,
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  supa auth = supa();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController fullname = TextEditingController();

  errors? er;
  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                buildTextField(
                  hint: "Full Name",
                  icon: Icons.person,
                  controller: fullname,
                ),

                const SizedBox(height: 15),

                buildTextField(
                  hint: "Username",
                  icon: Icons.person_outline,
                  controller: username,
                ),

                const SizedBox(height: 15),

                buildTextField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: email,
                ),

                if (er == errors.InvalidEmail)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Invalid email",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 15),

                buildTextField(
                  hint: "Password",
                  icon: Icons.lock,
                  controller: password,
                  obscure: true,
                ),

                const SizedBox(height: 15),

                buildTextField(
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  controller: confirmPassword,
                  obscure: true,
                ),

                if (er == errors.PasswordDismatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Passwords do not match",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 25),

                // Button
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
                    onPressed: isLoading
                        ? null
                        : () async {
                      setState(() => isLoading = true);

                      // Validation
                      if (!isValidEmail(email.text)) {
                        setState(() {
                          er = errors.InvalidEmail;
                          isLoading = false;
                        });

                      }

                      if (password.text != confirmPassword.text) {
                        setState(() {
                          er = errors.PasswordDismatch;
                          isLoading = false;
                        });
                        return;
                      }

                      try {
                        await auth.signup(
                          email.text.trim(),
                          password.text.trim(),
                          username.text.trim(),
                          fullname.text.trim(),
                          "Male",

                        );
                      } on Exception catch (e) {

                         ErrorSnackBar.show(context,e.toString());


                      }

                      setState(() => isLoading = false);

                      Navigator.pop(context);
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Continuewithgoogle(),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap:(){ Navigator.pop(context);},
                  child: const Text(
                    "Already have an account? Log In",
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