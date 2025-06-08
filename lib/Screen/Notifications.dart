import 'package:farm_wise/Components/SnakBar.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';

class NotificationsCard extends StatefulWidget {
  const NotificationsCard({super.key});

  @override
  State<NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<NotificationsCard> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _userId;
  String? _errorMessage;
  bool _isNavigatingBack = false;

  static const fruitColor = Color.fromRGBO(200, 80, 80, 1.0);
  static const vegetableColor = Colors.green;
  static const grainColor = Color.fromRGBO(161, 136, 127, 1.0);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;
      if (_userId == null) {
        throw Exception('User is not authenticated.');
      }

      final now = DateTime.now();
      final oneWeekLater = now.add(const Duration(days: 7));

      final cropsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .get();

      final notifications = <Map<String, dynamic>>[];

      for (var doc in cropsSnapshot.docs) {
        final data = doc.data();
        final plantDate = (data['PlantDate'] as Timestamp?)?.toDate();
        final harvestDate = (data['HarvestDate'] as Timestamp?)?.toDate();
        final cropName = data['CropName'] as String? ?? 'Unknown Crop';
        final cropType = data['PlantType'] as String?;
        final isCompleted = data['isCompleted'] == true;

        // Skip if essential data is missing
        if (cropName.isEmpty) continue;

        // Skip completed tasks
        if (isCompleted) continue;

        // Check for overdue planting
        if (plantDate != null && plantDate.isBefore(now)) {
          final daysOverdue = now.difference(plantDate).inDays;
          notifications.add({
            'title': 'Planting $cropName',
            'message': 'Overdue by $daysOverdue ${daysOverdue == 1 ? 'day' : 'days'}',
            'date': plantDate,
            'type': 'plant',
            'cropType': cropType,
            'cropName': cropName,
            'isOverdue': true,
            'docId': doc.id,
          });
        }
        // Check for upcoming planting
        else if (plantDate != null &&
            plantDate.isAfter(now) &&
            plantDate.isBefore(oneWeekLater)) {
          final daysUntil = plantDate.difference(now).inDays;
          notifications.add({
            'title': 'Planting $cropName',
            'message':
            'Scheduled in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
            'date': plantDate,
            'type': 'plant',
            'cropType': cropType,
            'cropName': cropName,
            'isOverdue': false,
            'docId': doc.id,
          });
        }

        // Check for overdue harvesting
        if (harvestDate != null && harvestDate.isBefore(now)) {
          final daysOverdue = now.difference(harvestDate).inDays;
          notifications.add({
            'title': 'Harvesting $cropName',
            'message': 'Overdue by $daysOverdue ${daysOverdue == 1 ? 'day' : 'days'}',
            'date': harvestDate,
            'type': 'harvest',
            'cropType': cropType,
            'cropName': cropName,
            'isOverdue': true,
            'docId': doc.id,
          });
        }
        // Check for upcoming harvesting
        else if (harvestDate != null &&
            harvestDate.isAfter(now) &&
            harvestDate.isBefore(oneWeekLater)) {
          final daysUntil = harvestDate.difference(now).inDays;
          notifications.add({
            'title': 'Harvesting $cropName',
            'message':
            'Scheduled in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
            'date': harvestDate,
            'type': 'harvest',
            'cropType': cropType,
            'cropName': cropName,
            'isOverdue': false,
            'docId': doc.id,
          });
        }
      }

      // Sort overdue items first, then by date
      notifications.sort((a, b) {
        if (a['isOverdue'] && !b['isOverdue']) return -1;
        if (!a['isOverdue'] && b['isOverdue']) return 1;
        return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
      });

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (_errorMessage!.contains('authenticated')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        CustomSnackBar().ShowSnackBar(context: context, text: _errorMessage!);
      }
    }
  }

  Color _getCropColor(String? cropType, bool isOverdue) {
    if (isOverdue) return Colors.red;

    switch (cropType?.toLowerCase()) {
      case 'fruit':
        return fruitColor;
      case 'vegetable':
        return vegetableColor;
      case 'grain':
        return grainColor;
      default:
        return Colors.green;
    }
  }

  Future<void> _markAsCompleted(String docId, int index) async {
    // Prevent multiple navigation attempts
    if (_isNavigatingBack) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .doc(docId)
          .update({'isCompleted': true});

      setState(() {
        _notifications.removeAt(index);
      });

      // Check if this was the last notification
      if (_notifications.isEmpty) {
        _isNavigatingBack = true;

        // Show success message
        CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'All tasks completed!'
        );

        // Navigate back with proper context check
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          } else if (mounted) {
            // If can't pop, replace with MainScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          }
        });
      } else {
        CustomSnackBar().ShowSnackBar(
            context: context,
            text: 'Task marked as completed'
        );
      }
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Error updating task: ${e.toString()}'
      );
    }
  }

  IconData _getEventIcon(String eventType) {
    return eventType == 'plant' ? Icons.agriculture : Icons.grass;
  }
//obeidatosama388@gmail.com
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        leading: IconButton(
            onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );

            },
            icon: const Icon(Icons.arrow_back)
        ),
        backgroundColor: Colors.green[600],
      ),
      body: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: _isLoading
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
              : _errorMessage != null
              ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red))))
              : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green[300]),
          const SizedBox(height: 16),
          Text('No upcoming events for the next 7 days',
              style: GoogleFonts.adamina(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final isOverdue = notification['isOverdue'] ?? false;
              final eventColor = _getCropColor(notification['cropType'], isOverdue);
              final eventIcon = _getEventIcon(notification['type']);
              final date = notification['date'] as DateTime;
              final docId = notification['docId'] as String;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: eventColor.withOpacity(0.5),
                    width: isOverdue ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: eventColor.withOpacity(0.8),
                    child: Icon(eventIcon, color: Colors.white, size: 20),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? 'Unknown Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isOverdue ? Colors.red[800] : null,
                          ),
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['message'] ?? 'No details available',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red[700] : Colors.grey[700],
                          fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 60,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _isNavigatingBack ? null : () => _markAsCompleted(docId, index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}