import 'package:farm_wise/Components/SnakBar.dart';
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
        final cropName = data['CropName'] as String;
        final cropType = data['PlantType'] as String?;

        if (plantDate != null && plantDate.isAfter(now) && plantDate.isBefore(oneWeekLater)) {
          final daysUntil = plantDate.difference(now).inDays;
          notifications.add({
            'title': 'Planting $cropName',
            'message': 'Scheduled in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
            'date': plantDate,
            'type': 'plant',
            'cropType': cropType,
            'cropName': cropName,
          });
        }

        if (harvestDate != null && harvestDate.isAfter(now) && harvestDate.isBefore(oneWeekLater)) {
          final daysUntil = harvestDate.difference(now).inDays;
          notifications.add({
            'title': 'Harvesting $cropName',
            'message': 'Scheduled in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
            'date': harvestDate,
            'type': 'harvest',
            'cropType': cropType,
            'cropName': cropName,
          });
        }
      }

      notifications.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

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

  Color _getCropColor(String? cropType) {
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

  IconData _getEventIcon(String eventType) {
    return eventType == 'plant' ? Icons.agriculture : Icons.grass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.green,
      ),
      body: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: Colors.green)),
            )
                : _errorMessage != null
                ? Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))))
                : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList()
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context); // Go back to Profile screen
    });

    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green[300]),
          const SizedBox(height: 16),
          Text('No upcoming events for the next 7 days',
              style: GoogleFonts.adamina(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final eventColor = _getCropColor(notification['cropType']);
        final eventIcon = _getEventIcon(notification['type']);
        final date = notification['date'] as DateTime;

        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() {
              _notifications.removeAt(index);
              if (_notifications.isEmpty) Navigator.pop(context);
            });
            CustomSnackBar().ShowSnackBar(context: context, text: 'Notification dismissed');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: eventColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: eventColor.withOpacity(0.5)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: eventColor.withOpacity(0.8),
                child: Icon(eventIcon, color: Colors.white, size: 20),
              ),
              title: Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['message'], style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ],
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }
}
