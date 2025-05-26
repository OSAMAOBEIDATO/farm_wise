import 'package:farm_wise/Components/SnakBar.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:provider/provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _cameraPermission = false;
  bool _locationPermission = false;
  bool _notificationPermission = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check permissions on screen load
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    try {
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;

      setState(() {
        _cameraPermission = cameraStatus.isGranted;
        _locationPermission = locationStatus.isGranted;
        _notificationPermission = notificationStatus.isGranted;
        _isLoading = false;
      });
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error checking permissions: $e',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermission(Permission permission, String permissionName) async {
    setState(() => _isLoading = true);
    try {
      final status = await permission.request();

      if (status.isGranted) {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: '$permissionName permission granted',
        );
      } else if (status.isDenied) {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: '$permissionName permission denied',
        );
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog(permissionName);
      }
      await _checkPermissions(); // Refresh permissions state
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error requesting $permissionName permission: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Required',
            style: GoogleFonts.adamina(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          content: Text(
            '$permissionName permission is permanently denied. Please enable it in app settings to use this feature.',
            style: TextStyle(color: Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.adamina(color: Colors.green[700]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: GoogleFonts.adamina(
                    color: Colors.green[900], fontWeight: FontWeight.bold),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Change Password',
                style: GoogleFonts.adamina(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.green[700],
                          ),
                          onPressed: () {
                            setState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.green[700],
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.green[700],
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.adamina(color: Colors.green[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Change Password', style: GoogleFonts.adamina()),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          },
        );
      },
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Please fill all password fields',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'New passwords do not match',
      );
      return;
    }

    if (newPassword.length < 6) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Password must be at least 6 characters long',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Password changed successfully',
      );
    } catch (e) {
      String errorMessage = 'Failed to change password';
      if (e.toString().contains('wrong-password')) {
        errorMessage = 'Current password is incorrect';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'New password is too weak';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log in again to change your password';
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: errorMessage,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Delete Account',
                style: GoogleFonts.adamina(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This action cannot be undone. All your data including crops, notifications, and settings will be permanently deleted.',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Enter your password to confirm',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.green[700],
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.adamina(color: Colors.green[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteAccount(passwordController.text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Delete Account', style: GoogleFonts.adamina()),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(String password) async {
    if (password.isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Please enter your password to confirm deletion',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await _firestore.collection('users').doc(user.uid).delete();

      final cropsQuery = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('crops')
          .get();
      for (var doc in cropsQuery.docs) {
        await doc.reference.delete();
      }

      await user.delete();

      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Account deleted successfully',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      String errorMessage = 'Failed to delete account';
      if (e.toString().contains('wrong-password')) {
        errorMessage = 'Password is incorrect';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log in again to delete your account';
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: errorMessage,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _reloadScreen() {
    setState(() {
      _isLoading = false;
      _cameraPermission = false;
      _locationPermission = false;
      _notificationPermission = false;
    });
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
        ),
        title: Text(
          'Security',
          style: GoogleFonts.adamina(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reloadScreen,
        backgroundColor: Colors.green[700],
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Reload All',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Management'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.green[700]),
                    title: Text('Change Password', style: GoogleFonts.adamina()),
                    subtitle: Text('Update your account password',
                        style: TextStyle(color: Colors.grey[600])),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                    onTap: _showChangePasswordDialog,
                  ),
                  Divider(height: 1, thickness: 1),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red[700]),
                    title: Text('Delete Account',
                        style: GoogleFonts.adamina(color: Colors.red[700])),
                    subtitle: Text('Permanently delete your account and all data',
                        style: TextStyle(color: Colors.grey[600])),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.red[700]),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('App Permissions'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildPermissionTile(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take photos for disease detection',
                    isGranted: _cameraPermission,
                    onTap: () => _requestPermission(Permission.camera, 'Camera'),
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildPermissionTile(
                    icon: Icons.location_on,
                    title: 'Location',
                    subtitle: 'Get weather data for your location',
                    isGranted: _locationPermission,
                    onTap: () => _requestPermission(Permission.location, 'Location'),
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildPermissionTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Receive crop reminders and alerts',
                    isGranted: _notificationPermission,
                    onTap: () => _requestPermission(Permission.notification, 'Notification'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('General'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.green[700]),
                    title: Text('About FarmWise', style: GoogleFonts.adamina()),
                    subtitle: Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600])),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'FarmWise',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 FarmWise Team\nJordan University of Science and Technology',
                        children: [
                          Text(
                            '\nFarmWise is an AI-powered agricultural application designed to help farmers with crop management, disease detection, and weather-based recommendations.',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.adamina(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isGranted ? Colors.green[700] : Colors.grey[600],
      ),
      title: Text(title, style: GoogleFonts.adamina()),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isGranted ? 'Granted' : 'Denied',
              style: TextStyle(
                color: isGranted ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
        ],
      ),
      onTap: onTap,
    );
  }
}