import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Please enter your email",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String result = await AuthService().sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _isLoading = false;
      });

      CustomSnackBar().ShowSnackBar(
        context: context,
        text: result,
      );

      if (result.startsWith("Successfully")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "An unexpected error occurred: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: GoogleFonts.adamina(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reset Password",
              style: GoogleFonts.adamina(
                fontSize: 30,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email address to receive a verification code.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ReusableTextField(
              hintText: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.grey[100],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : Text('Send Verification Code', style: KTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}