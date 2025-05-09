import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_wise/Components/SnakBar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Common/Constant.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;
  String? _userId;
  String? _selectedCropType; // For filtering

  // Define colors for crop types
  static const fruitColor = Color.fromRGBO(200, 80, 80, 1.0); // Soft red
  static const vegetableColor = Colors.green; // Green
  static const grainColor = Color.fromRGBO(161, 136, 127, 1.0); // Light brown

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initialize selected day
    _fetchUserCrops();
  }

  Future<void> _fetchUserCrops() async {
    setState(() => _isLoading = true);
    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;
      if (_userId == null) {
        throw Exception('No user is currently authenticated');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .get();

      final events = <DateTime, List<Map<String, dynamic>>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final plantDate = (data['PlantDate'] as Timestamp?)?.toDate();
        final harvestDate = (data['HarvestDate'] as Timestamp?)?.toDate();
        final cropName = data['CropName'] as String;
        final cropType = data['PlantType'] as String?;
        final cropId = doc.id;

        if (plantDate != null) {
          final eventDate = DateTime.utc(plantDate.year, plantDate.month, plantDate.day);
          events[eventDate] = events[eventDate] ?? [];
          events[eventDate]!.add({
            'title': 'Planting $cropName',
            'id': cropId,
            'type': 'plant',
            'cropType': cropType,
          });
        }
        if (harvestDate != null) {
          final eventDate = DateTime.utc(harvestDate.year, harvestDate.month, harvestDate.day);
          events[eventDate] = events[eventDate] ?? [];
          events[eventDate]!.add({
            'title': 'Harvesting $cropName',
            'id': cropId,
            'type': 'harvest',
            'cropType': cropType,
          });
        }
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error fetching crops: $e',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateEventDate(String cropId, DateTime newDate, String eventType) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .doc(cropId)
          .update({
        eventType == 'plant' ? 'PlantDate' : 'HarvestDate': Timestamp.fromDate(newDate),
      });
      if (eventType == 'plant') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('crops')
            .doc(cropId)
            .update({
          'HarvestDate': Timestamp.fromDate(newDate.add(const Duration(days: 30))), // Example harvest delay
        });
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: '${eventType.capitalize()} date updated successfully!',
      );
      _fetchUserCrops(); // Refresh events
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error updating ${eventType} date: $e',
      );
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final eventDate = DateTime.utc(day.year, day.month, day.day);
    final events = _events[eventDate] ?? [];

    if (_selectedCropType == null) return events;
    return events.where((event) => event['cropType'] == _selectedCropType).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Check if device is in portrait mode (mobile)
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.green[700]),
      )
          : isPortrait
          ? _buildMobileLayout()
          : _buildTabletLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Calendar at the top
        Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  titleTextStyle: GoogleFonts.adamina(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Filter dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events for ${DateFormat('yyyy-MM-dd').format(_selectedDay ?? DateTime.now())}',
                style: GoogleFonts.adamina(
                  fontSize: 17,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600
                ),
              ),
              DropdownButton<String>(
                value: _selectedCropType,
                hint: Text(
                  'Filter',
                  style: TextStyle(color: Colors.green[700], fontSize: 14),
                ),
                items:  [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All',style: KTextStyleForType),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Fruit',
                    child: Text('Fruit',style: KTextStyleForType),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Vegetable',
                    child: Text('Vegetable',style: KTextStyleForType),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Grain',
                    child: Text('Grain',style: KTextStyleForType,),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCropType = value;
                  });
                },
              ),
            ],
          ),
        ),

        // Events list
        Expanded(
          child: _selectedDay == null
              ? const Center(
            child: Text(
              'Select a date to see events',
              style: TextStyle(fontSize: 16),
            ),
          )
              : _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Calendar on the left
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Colors.green[400],
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    titleTextStyle: GoogleFonts.adamina(
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Event list on the right
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _selectedDay == null
                ? const Center(
              child: Text(
                'Select a date to see events',
                style: TextStyle(fontSize: 16),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Events on ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                      style: GoogleFonts.adamina(
                        fontSize: 20,
                        color: Colors.green[700],
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedCropType,
                      hint: Text(
                        'Filter by Crop Type',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Fruit',
                          child: Text(
                            'Fruit',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Vegetable',
                          child: Text(
                            'Vegetable',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Grain',
                          child: Text(
                            'Grain',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCropType = value;
                        });
                      },
                      underline: Container(
                        height: 2,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events for this day',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        Color eventColor;
        switch (event['cropType']?.toLowerCase()) {
          case 'fruit':
            eventColor = fruitColor;
            break;
          case 'vegetable':
            eventColor = vegetableColor;
            break;
          case 'grain':
            eventColor = grainColor;
            break;
          default:
            eventColor = Colors.grey[700]!;
        }

        // Create an icon based on the event type
        IconData eventIcon = event['type'] == 'plant'
            ? Icons.agriculture
            : Icons.grass;

        return Card(
          color: eventColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: eventColor, width: 1.5),
          ),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: ListTile(
            leading: Icon(eventIcon, color: eventColor),
            title: Text(
              event['title'],
              style: GoogleFonts.adamina(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              event['cropType'] ?? 'Unknown type',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Colors.green[700]),
              onPressed: () async {
                final newDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDay!,
                  firstDate: DateTime(2025, 1, 1),
                  lastDate: DateTime(2025, 12, 31),
                  barrierColor: Colors.green.withOpacity(0.5),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.green[700]!,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (newDate != null) {
                  await _updateEventDate(event['id'], newDate, event['type']);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}