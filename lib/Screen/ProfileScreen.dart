import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Screen/HelpAndSupport.dart';
import 'package:farm_wise/Screen/Notifications.dart';
import 'package:farm_wise/Screen/SecurityScreen.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/Screen/SearchCropScreen.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Models/UserModel.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _fetchError;
  String? _userId;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      // Fetch userId directly from FirebaseAuth
      _userId = FirebaseAuth.instance.currentUser?.uid;
      print('ProfileScreen: Fetched userId from FirebaseAuth = $_userId');
      if (_userId == null) {
        throw Exception('No user is currently authenticated');
      }

      // Fetch user data from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (snapshot.exists) {
        _user = UserModel.fromMap(
            _userId!, snapshot.data() as Map<String, dynamic>);
        print(
            'ProfileScreen: Fetched user data - email: ${_user!.email}, name: ${_user!.firstName} ${_user!.lastName}');
      } else {
        print('ProfileScreen: User document not found, creating new document');
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          throw Exception('Cannot create user document: No authenticated user');
        }

        String firstName = '';
        String lastName = '';
        String email = firebaseUser.email ?? '';
        if (firebaseUser.displayName != null) {
          final nameParts = firebaseUser.displayName!.split(' ');
          firstName = nameParts[0];
          lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        }

        await FirebaseFirestore.instance.collection('users').doc(_userId).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': null, // Will be updated later if needed
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Fetch the newly created document
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (snapshot.exists) {
          _user = UserModel.fromMap(
              _userId!, snapshot.data() as Map<String, dynamic>);
          print(
              'ProfileScreen: Created and fetched user data - email: ${_user!.email}, name: ${_user!.firstName} ${_user!.lastName}');
        } else {
          throw Exception('Failed to create user document');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _fetchError = e.toString();
      });
      print('ProfileScreen: Error fetching user data: $e');
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error fetching user data: $e',
      );
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String result = await _authService.signOut();
      if (result == "Successfully") {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Logged out successfully!',
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        throw Exception(result);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error logging out: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        color: Colors.green,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_fetchError != null) {
      return Center(
        child: Text(
          'Error: $_fetchError',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text(
          'No user data available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      _user!.firstName.isNotEmpty
                          ? _user!.firstName[0].toUpperCase()
                          : 'O',
                      style: const TextStyle(fontSize: 40, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_user!.firstName} ${_user!.lastName}',
                    style: KTextStyle.copyWith(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.phone ?? 'No phone number',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Account Settings',
              style: GoogleFonts.adamina(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_florist, color: Colors.green),
              title: Text(
                'Crop Options',
                style: GoogleFonts.adamina(fontWeight: FontWeight.normal),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchCropScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined,
                  color: Colors.green),
              title: Text('Notifications',
                  style: GoogleFonts.adamina(fontWeight: FontWeight.normal)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsCard(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.green),
              title: Text('Security',
                  style: GoogleFonts.adamina(fontWeight: FontWeight.normal)),
              onTap: () {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>const SecurityScreen()));
              },
            ),

            const SizedBox(height: 24),
            Text(
              'Help and Support',
              style: GoogleFonts.adamina(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: Text('Share App',
                  style: GoogleFonts.adamina(fontWeight: FontWeight.normal)),
              onTap: () {
                // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>const Sharescreen()));
              },
            ),//HelpAndSupportScreen
            ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: Text('Help & Support',
                  style: GoogleFonts.adamina(fontWeight: FontWeight.normal)),
              onTap: () {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('Logout',
                  style: GoogleFonts.adamina(fontWeight: FontWeight.w900)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
