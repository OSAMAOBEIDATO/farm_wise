import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Screen/ForgetPasswordScreen.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:farm_wise/Screen/SearchCropScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Screen/SignUpScreen.dart';
import 'package:farm_wise/components/FacebookSignUp.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/Authentication.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInUser() async {

    setState(() {
      isLoading = true;
    });

    try {
      final String res = await AuthService().signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        isLoading = false;
      });

      if (res == "Successfully") {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Login Successful',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen()
          ),
        );
      } else {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: res,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> _signUpWithFacebook() async {
    final String? userId = AuthService().getCurrentUserId();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userId == null) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Failed to retrieve user ID after sign-up.');
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String result = await AuthService().signUpWithFacebook();

      setState(() {
        isLoading = false;
      });

      if (result.startsWith('PromptForEmail')) {
        final String? userId = AuthService().getCurrentUserId();
        if (userId == null) {
          await AuthService().signOut();
          CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'Facebook login failed: Unable to retrieve user ID.',
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchCropScreen(),
          ),
        );
        return;
      }

      if (result == "Successfully") {
        final String? userId = AuthService().getCurrentUserId();
        if (userId == null) {
          CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'Failed to retrieve user ID after sign-up.',
          );
          return;
        }


        if (userData != null && userData['phoneNumber'] == null) {
          CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'Please add your phone number to continue.',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchCropScreen(),
            ),
          );
        } else {
          CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'Signed up with Facebook successfully!',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SearchCropScreen(),
            ),
          );
        }
      } else {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: result,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'An unexpected error occurred: $e',
      );
    }
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
                keyboardType: TextInputType.visiblePassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },//TODO: Add forgot password screen
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(color: Colors.green[500]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              SignInWithFacebook(
                logInOrSignIn: "Sign Up",
                onTap: _signUpWithFacebook,
              ),
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
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'SignUp',
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