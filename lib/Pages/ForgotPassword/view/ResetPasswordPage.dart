import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/LogInComponents/buildTextField.dart';
import '../../Components/errorsnackbar.dart';
import '../../Components/app_route.dart';
import '../../Login/View/LoginScreen.dart';
import '../ForgotPasswordRepository.dart';
import '../viewmodel/ForgotPasswordViewModel.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late ForgotPasswordViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ForgotPasswordViewModel(ForgotPasswordRepository());
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            extendBodyBehindAppBar: true,
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
              child: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - MediaQuery.of(context).padding.top - AppBar().preferredSize.height,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.03),

                            /// 🔹 Icon & Header
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_open,
                                  color: Colors.blue,
                                  size: screenWidth * 0.15,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            Center(
                              child: Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.075,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            Center(
                              child: Text(
                                "Please enter your new password below.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),

                            /// 🔹 New Password TextField
                            buildTextField(
                              hint: "New Password",
                              icon: Icons.lock,
                              controller: vm.passwordController,
                              obscure: true,
                            ),

                            SizedBox(height: screenHeight * 0.025),

                            /// 🔹 Confirm New Password TextField
                            buildTextField(
                              hint: "Confirm Password",
                              icon: Icons.lock_outline,
                              controller: vm.confirmPasswordController,
                              obscure: true,
                            ),

                            SizedBox(height: screenHeight * 0.045),

                            /// 🔹 Reset Button
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
                                onPressed: vm.isResetLoading
                                    ? null
                                    : () {
                                        vm.resetPassword(
                                          onSuccess: () {
                                            _showSuccessDialog(context);
                                          },
                                          onError: (err) {
                                            ErrorSnackBar.show(context, err);
                                          },
                                        );
                                      },
                                child: vm.isResetLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Update Password",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const Spacer(),
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A8A),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text(
                "Success",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            "Your password has been successfully updated. You can now log in with your new password.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Log In",
                style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // dismiss dialog
                Navigator.of(context).pushAndRemoveUntil(
                  appRoute((_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
