import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? validPassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    } else if (!RegExp(r'[1-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  String? validateEmailDomain(String email) {
    const allowedDomains = ['@gmail.com', '@hotmail.com', '@yahoo.com','@cit.just.edu.jo','outlook.com',];
    if (!allowedDomains.any((domain) => email.toLowerCase().endsWith(domain))) {
      return 'Only Gmail or Hotmail addresses are allowed (e.g., user@gmail.com or user@hotmail.com).';
    }
    return null;
  }

  String? validatePhoneNumber(String phoneNumber) {
    final trimmed = phoneNumber.trim();

    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Phone number must contain only digits (0-9).';
    }

    if (!(trimmed.startsWith('07') || trimmed.startsWith('962'))) {
      return 'Phone number must start with 07 or 962.';
    }

    if (trimmed.startsWith('07') && trimmed.length != 10) {
      return 'Phone number starting with 07 must be exactly 10 digits.';
    }

    if (trimmed.startsWith('962') && trimmed.length != 12) {
      return 'Phone number starting with 962 must be exactly 12 digits.';
    }
    return null;
  }

  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Name cannot be empty.';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces.';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  Future<String> signupUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty) {
        return 'Please fill in all fields.';
      }

      final passwordError = validPassword(password);
      if (passwordError != null) {
        return passwordError;
      }

      final emailError = validateEmailDomain(email);
      if (emailError != null) {
        return emailError;
      }

      final phoneError = validatePhoneNumber(phoneNumber);
      if (phoneError != null) {
        return phoneError;
      }
      final firstNameError = validateName(firstName);
      if (firstNameError != null) {
        return firstNameError;
      }
      final lastNameError = validateName(firstName);
      if (lastNameError != null) {
        return lastNameError;
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection("users").doc(cred.user?.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "Successfully";
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account';
        case 'invalid-email':
          return 'Hmm, that doesn’t look like a valid email. ';
        case 'weak-password':
          return 'The password must be at least 8 characters long.';
        case 'operation-not-allowed':
          return 'Oops! Sign-ups using email and password are currently disabled.';
        default:
          return err.message ?? 'An error occurred during sign-up: ${err.code}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }



  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return "Successfully";
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error during sign-in: ${e.code} - ${e.message}'); // Debug log
      switch (e.code) {
        case 'user-not-found':
          return 'No account exists with this email. Please sign up.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid. Please check and try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        default:
          return 'An error occurred during sign-in. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String> signOut() async {
    try {
      await _auth.signOut();
      return "Successfully";
    } catch (e) {
      return 'Error signing out: $e';
    }
  }

  String? getCurrentUserId() {
    final String? userId = _auth.currentUser?.uid;
    return userId;
  }

  Future<UserModel?> getUserData() async {
    final String? uid = getCurrentUserId();
    if (uid == null) {
      return null;
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return "Successfully sent password reset email. Please check your inbox.";
    } catch (e) {
      return "Error sending password reset email: $e";
    }
  }

  Future<String> signUpWithFacebook() async {
    String firstName = '';
    String lastName = '';

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          return 'Facebook sign-up cancelled by user.';
        }
        return 'Facebook sign-up failed: ${result.message}';
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        return 'Failed to retrieve Facebook access token.';
      }

      final OAuthCredential facebookCredential = FacebookAuthProvider.credential(accessToken.tokenString);
      final UserCredential userCredential = await _auth.signInWithCredential(facebookCredential);
      final User? user = userCredential.user;

      if (user == null) {
        return 'Failed to sign in to Firebase with Facebook.';
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        String? email = user.email;

        if (email == null) {
          final userData = await FacebookAuth.instance.getUserData(fields: "email,name");
          email = userData['email'];
        }

        if (email == null) {
          return 'PromptForEmail:${user.uid}:${user.displayName ?? ''}';
        }

        // Validate email domain before proceeding
        final emailError = validateEmailDomain(email);
        if (emailError != null) {
          await _auth.signOut();
          return emailError;
        }

        if (user.displayName != null) {
          final nameParts = user.displayName!.split(' ');
          firstName = nameParts[0];
          lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        }

        await _firestore.collection("users").doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': null,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('User already exists in Firestore');
      }

      return "Successfully";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return 'This email is already associated with another account. Please use a different sign-in method.';
        case 'invalid-credential':
          return 'Invalid Facebook credentials. Please try again.';
        case 'operation-not-allowed':
          return 'Facebook sign-up is currently disabled.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        default:
          return 'An error occurred during Facebook sign-up: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}