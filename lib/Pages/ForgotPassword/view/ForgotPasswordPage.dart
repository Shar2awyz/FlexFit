import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/LogInComponents/buildTextField.dart';
import '../../Components/errorsnackbar.dart';
import '../ForgotPasswordRepository.dart';
import '../viewmodel/ForgotPasswordViewModel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
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
                                  Icons.lock_reset,
                                  color: Colors.blue,
                                  size: screenWidth * 0.15,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            Center(
                              child: Text(
                                "Forgot Password?",
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
                                "Enter your email address and we'll send you a link to reset your password.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.038,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),

                            /// 🔹 Email TextField
                            buildTextField(
                              hint: "Enter your email",
                              icon: Icons.email,
                              controller: vm.emailController,
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            /// 🔹 Submit Button
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
                                        vm.sendResetEmail(
                                          onSuccess: () {
                                            _showSuccessDialog(context);
                                          },
                                          onError: (err) {
                                            ErrorSnackBar.show(context, err);
                                          },
                                        );
                                      },
                                child: vm.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Send Recovery Link",
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
                "Email Sent",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            "A password recovery link has been sent to your email. Please check your inbox and follow the instructions.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // dismiss dialog
                Navigator.of(context).pop(); // go back to login page
              },
            ),
          ],
        );
      },
    );
  }
}
