// Dart imports
import 'package:flutter/material.dart';

// Package imports
import 'package:google_fonts/google_fonts.dart';

// Project imports
import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/Screen/SignUpScreen.dart';
import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/components/FacebookSignUp.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/Authentication.dart';

/// A screen for users to log in with email and password.
class LoginScreen extends StatefulWidget {
  static const String id = "Loginscreen";
  final String userId;

  const LoginScreen({super.key, required this.userId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for loading indicator
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Signs in the user using Firebase Authentication.
  Future<void> _signInUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String res = await AuthService().signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print('Sign-in result: $res'); // Debug log to confirm result

      setState(() {
        isLoading = false;
      });

      if (res == "Successfully") {
        print('Showing success SnackBar'); // Debug log
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Login successful!',
        );
        print('Navigating to HomeScreen'); // Debug log
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId,)),
        );
      } else {
        print('Showing error SnackBar: $res'); // Debug log
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: res,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Sign-in error: $e'); // Log the error for debugging
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Image.asset(
                'assets/Image/loginScreen.jpg',
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Login',
                style: GoogleFonts.adamina(
                  fontSize: 60,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ReusableTextField(
                hintText: 'Password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      CustomSnackBar().ShowSnackBar(
                        context: context,
                        text: "Please fill in all fields",
                      );
                    } else {
                      _signInUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : Text('Sign In', style: KTextStyle),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.green[100],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Or",
                      style: KTextStyle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.green[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SignInWithFacebook(logInOrSignIn: "Sign Up", onTap: () {}),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
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
                          builder: (context) =>  SignUpScreen(userId: widget.userId,),
                        ),
                      );
                    },
                    child: Text(
                      'SignUp',
                      style: GoogleFonts.adamina(
                        fontSize: 20,
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