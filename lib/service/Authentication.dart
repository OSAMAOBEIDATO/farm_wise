import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ensure Firebase is initialized
  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  // Sign up a user with email and password
  Future<String> signUpUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      // Ensure Firebase is initialized
      await _ensureFirebaseInitialized();

      // Create user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user was created successfully
      User? user = credential.user;
      if (user == null) {
        return 'Failed to create user: User credential is null';
      }

      // Save user data to Firestore
      await _firestore.collection("users").doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), // Add timestamp
      });

      return "Successfully";
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'weak-password':
          return 'The password must be at least 6 characters long.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled in Firebase Authentication.';
        default:
          return e.message ?? 'An error occurred during sign-up: ${e.code}';
      }
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      return 'Firestore error: ${e.message}';
    } catch (e) {
      // Handle other errors
      return 'An unexpected error occurred: $e';
    }
  }

  // Get the current user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Sign in a user with email and password
  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure Firebase is initialized
      await _ensureFirebaseInitialized();

      // Sign in user
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Successfully";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An error occurred during sign-in: ${e.code}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign out the current user
  Future<String> signOut() async {
    try {
      await _auth.signOut();
      return "Successfully";
    } catch (e) {
      return 'Error signing out: $e';
    }
  }
}