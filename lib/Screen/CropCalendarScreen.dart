import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/SnakBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
  String? _selectedCropType;

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
        final data = doc.data() as Map<String, dynamic>;
        final plantDate = (data['PlantDate'] as Timestamp?)?.toDate();
        final harvestDate = (data['HarvestDate'] as Timestamp?)?.toDate();
        final cropName = data['CropName'] as String;
        final PlantType = data['PlantType'] as String? ?? data['type'] as String?;
        final cropId = doc.id;

        if (plantDate != null) {
          final eventDate = DateTime.utc(plantDate.year, plantDate.month, plantDate.day);
          events[eventDate] = events[eventDate] ?? [];
          events[eventDate]!.add({
            'title': 'Planting $cropName',
            'id': cropId,
            'type': 'plant',
            'cropType': PlantType,
          });
        }
        if (harvestDate != null) {
          final eventDate = DateTime.utc(harvestDate.year, harvestDate.month, harvestDate.day);
          events[eventDate] = events[eventDate] ?? [];
          events[eventDate]!.add({
            'title': 'Harvesting $cropName',
            'id': cropId,
            'type': 'harvest',
            'cropType': PlantType,
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
          'HarvestDate': Timestamp.fromDate(newDate.add(Duration(days: 30))), // Example harvest delay
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
    return Scaffold(
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.green[700]),
      )
          : _buildLayout(),
    );
  }

  Widget _buildLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(9),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
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
                  'Events for ${DateFormat('dd-MM-yyyy').format(_selectedDay ?? DateTime.now())}',
                  style: KDropdownMenuItemStyle
              ),
              DropdownButton<String>(
                value: _selectedCropType,
                hint: Text(
                  'Filter',
                  style: TextStyle(color: Colors.green[700], fontSize: 14),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All',style:KDropdownMenuItemStyle),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Fruit',
                    child: Text('Fruit',style:KDropdownMenuItemStyle),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Vegetable',
                    child: Text('Vegetable',style:KDropdownMenuItemStyle),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Grain',
                    child: Text('Grain',style:KDropdownMenuItemStyle),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCropType = value;
                  });
                },
                borderRadius:   BorderRadius.circular(15),
              ),
            ],
          ),
        ),

        // Events list
        Expanded(
          child: _selectedDay == null
              ?  Center(
            child: Text(
              'Select a date to see events',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.green[600],
              ),
            ),
          )
              : _buildEventsList(),
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

        IconData eventIcon = event['type'] == 'plant'
            ? Icons.agriculture
            : Icons.grass;

        return Card(
          color: eventColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: eventColor, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: ListTile(
            leading: Icon(eventIcon, color: eventColor),
            title: Text(
              event['title'],
              style:GoogleFonts.poppins(
                fontSize: 17,
                color: Colors.black,
                fontWeight:FontWeight.w600
              ),
            ),
            subtitle: Text(
              event['cropType'] ?? 'Unknown type',
              style: TextStyle(
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