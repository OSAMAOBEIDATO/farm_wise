import 'package:farm_wise/Screen/SearchCropScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/Authentication.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = "HomeScreen";
  final String userId;
  const SignUpScreen({super.key, required this.userId});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for loading indicator
  bool isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String res = await AuthService().signupUser(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
      );

      print('Sign-up result: $res'); // Debug log to confirm result

      setState(() {
        isLoading = false;
      });

      if (res == "Successfully") {
        print('Navigating to HomeScreen'); // Debug log
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchCropScreen(userId: widget.userId,)),
        );
      } else {
        print('Showing error SnackBar: $res'); // Debug log

      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Sign-up error: $e'); // Log the error for debugging
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'An unexpected error occurred: $e',
      );
    }
  }

  //OSamaObeidat@gmail.com
//OSamaa@789
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
                hintText: 'Password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'PhoneNumber',
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
                    if (_firstNameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _phoneNumberController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _lastNameController.text.isEmpty) {
                      CustomSnackBar().ShowSnackBar(
                        context: context,
                        text: "Please fill in all fields",
                      );
                    } else {
                      _signUpUser();
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
                        MaterialPageRoute(builder: (context) => LoginScreen(userId: widget.userId,)),
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