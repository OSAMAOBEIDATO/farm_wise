import 'package:farm_wise/Components/SnakBar.dart';
import 'package:farm_wise/Screen/SearchCropScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/service/Authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signUpUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String res = await AuthService().signupUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (res == "Successfully") {
        print(
            "Sign-up successful, navigating to SearchCropScreen"); // Debug log
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchCropScreen(),
          ),
        );
      } else {
        print("Sign-up failed with response: $res"); // Debug log
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: res,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Sign-up error: $e"); // Debug log
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage =
            'The email address is already in use by another account.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'The email address is not valid.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage =
            'The password is too weak. Please use a stronger password.';
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: errorMessage,
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Image.asset(
                'assets/Image/SignUpScreen.png',
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  );
                },
              ),
              const SizedBox(height: 5),
              Text(
                'Sign Up',
                style: GoogleFonts.adamina(
                  fontSize: 60,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'First Name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Last Name',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Password ',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Phone Number ',
                controller: _phoneNumberController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _signUpUser();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : Text('Sign Up', style: KTextStyle),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.adamina(
                      fontSize: 20,
                      color: Colors.green[500],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.adamina(
                        fontSize: 25,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
