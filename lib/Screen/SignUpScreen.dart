import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void signUpUser() async {
    String res = await AuthService().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneNumberController.text
    );

    if (res == "Successfully") {
      setState(() {
        isLoading=true;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Successfully",
      );
    } else {
      setState(() {
        isLoading=false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: res,
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                hintText: 'PhoneNumber',
                controller: _phoneNumberController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              ReusableTextField(
                hintText: 'Password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
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
                      signUpUser;

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text('Sign Up', style: KTextStyle),
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
                          builder: (context) => Loginscreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
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
