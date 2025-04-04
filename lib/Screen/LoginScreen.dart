import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/Screen/SignUpScreen.dart';
import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/components/FacebookSignUp.dart';
import 'package:farm_wise/components/ReusableTextField.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _usernameController =
      TextEditingController(); // Renamed for consistency
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
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
            children: [
              const SizedBox(height: 25),
              Image.asset('assets/Image/loginScreen.jpg',
                  errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                );
              }),
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
                hintText: 'Username',
                controller: _usernameController,
                prefixIcon: Icons.person_outline,
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
                    if (_usernameController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      CustomSnackBar().ShowSnackBar(
                        context: context,
                        text: "Please fill in all fields",
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                      print(
                          'Username: ${_usernameController.text}, Password: ${_passwordController.text}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text('Sign In', style: KTextStyle),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.green[100],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                          builder: (context) => const SignUpScreen(),
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
