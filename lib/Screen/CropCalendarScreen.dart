import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Simple Event model for display only
class CropEvent {
  final String id;
  final String title;

  const CropEvent({
    required this.id,
    required this.title,
  });
}

class CropCalendarScreen extends StatelessWidget {
  static const String id = "CropCalendarScreen";
  final String userId; // Kept for consistency, but not used
  CropCalendarScreen({required this.userId,super.key});

  // Hardcoded events mapped to dates
  final Map<DateTime, List<CropEvent>> _events = {
    DateTime.utc(2025, 3, 1): [
      const CropEvent(id: '1', title: 'Planting Corn'),
    ],
    DateTime.utc(2025, 4, 15): [
      const CropEvent(id: '2', title: 'Fertilizing Wheat'),
    ],
    DateTime.utc(2025, 6, 1): [
      const CropEvent(id: '3', title: 'Harvesting Corn'),
    ],
    DateTime.utc(2025, 7, 1): [
      const CropEvent(id: '4', title: 'Harvesting Wheat'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Crop Calendar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: DateTime.utc(2025, 3, 1),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                // Show events for the selected day (for display purposes only)
                final events = _events[DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day)] ?? [];
                if (events.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Events on ${selectedDay.toString().split(' ')[0]}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: events.map((event) => Text(event.title)).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}