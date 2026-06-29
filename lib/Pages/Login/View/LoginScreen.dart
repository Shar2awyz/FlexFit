import 'package:flutter/material.dart';

import '../../Components/LogInComponents/buildTextField.dart';
import '../../Components/errorsnackbar.dart';
import '../../Components/RootNavigationShell.dart';
import '../../SignUp/view/SignUpPage.dart';
import '../LoginRepository.dart';
import '../ViewModel/ViewModel.dart';
import 'package:provider/provider.dart';
import '../../Components/app_route.dart';
import '../../ForgotPassword/view/ForgotPasswordPage.dart';
import 'package:lottie/lottie.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = LoginViewModel(LoginRepository());

    /// 🔹 listen to auth state (replaces your old initState logic)
    vm.startAuthListener((userId) {
      Navigator.pushReplacement(
        context,
        appRoute( (_) => RootNavigationShell(userid: userId),
        ),
      );
    });
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1B2B34),
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: vm.isLoading
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
                      child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.05),

                            /// 🔹 Logo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fitness_center,
                                    color: Colors.blue,
                                    size: screenWidth * 0.07),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  "Flex Fit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.055,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            /// 🔹 Welcome
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Welcome Back!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            /// 🔹 Email
                            buildTextField(
                              hint: "Email / Username",
                              icon: Icons.email,
                              controller: vm.emailController,
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            /// 🔹 Password
                            buildTextField(
                              hint: "Password",
                              icon: Icons.lock,
                              controller: vm.passwordController,
                              obscure: true,
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            /// 🔹 Forgot
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    appRoute( (_) => const ForgotPasswordPage()),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            /// 🔹 Login Button
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.065,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF36D1DC),
                                    Color(0xFF5B86E5)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: vm.isLoading
                                    ? null
                                    : () {
                                  vm.login(
                                    onSuccess: (userId) {
                                      Navigator.pushReplacement(
                                        context,
                                        appRoute( (_) =>
                                              RootNavigationShell(userid: userId),
                                        ),
                                      );
                                    },
                                    onError: (message) {
                                      ErrorSnackBar.show(context, message);
                                    },
                                  );
                                },
                                child: vm.isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            /// 🔹 Divider
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Colors.grey)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03),
                                  child: Text(
                                    "or",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: Colors.grey)),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            /// 🔹 Google Button
                            GestureDetector(
                              onTap: () {
                                vm.loginWithGoogle();
                              },
                              child: Container(
                                width: double.infinity,
                                height: screenHeight * 0.065,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding:
                                  EdgeInsets.all(screenWidth * 0.02),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "images/google.png",
                                        width: screenWidth * 0.12,
                                        height: screenWidth * 0.12,
                                      ),
                                      SizedBox(width: screenWidth * 0.08),
                                      const Expanded(
                                        child: Center(
                                          child: Text(
                                            "Continue with Google",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            /// 🔹 Sign Up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      appRoute( (_) => SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}