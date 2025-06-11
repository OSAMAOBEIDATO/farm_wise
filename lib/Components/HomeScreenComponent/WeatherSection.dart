import 'package:farm_wise/Components/HomeScreenComponent/WeatherCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherSection extends StatelessWidget {

  const WeatherSection({
    super.key,
    required this.isLoading,
    required this.weather,
    required this.onRetry
  });

  final bool isLoading;
  final Map<String, dynamic>? weather;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.wb_cloudy, color: Colors.blue[600], size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Weather Today',
              style: GoogleFonts.adamina(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
        else if (weather == null)
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Unable to load weather data',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.refresh, color: Colors.red[600]),
                  ],
                ],
              ),
            ),
          )
        else
          GridView.count(
            crossAxisCount:2 ,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              WeatherCard(
                icon: Icons.wb_sunny,
                value: '${weather!['main']['temp']?.toStringAsFixed(0)}°C',
                label: 'Temperature',
                iconColor: Colors.orange,
              ),
              WeatherCard(
                icon: Icons.opacity,
                value: '${weather!['main']['humidity']}%',
                label: 'Humidity',
                iconColor: Colors.blue,
              ),
              WeatherCard(
                icon: Icons.air,
                value: '${weather!['wind']['speed']?.toStringAsFixed(1)} m/s',
                label: 'Wind Speed',
                iconColor: Colors.grey,
              ),
              WeatherCard(
                icon: Icons.cloud,
                value: '${(weather!['rain']?['3h'] ?? 0).toStringAsFixed(1)} mm',
                label: 'Precipitation',
                iconColor: Colors.indigo,
              ),
            ],
          ),
      ],
    );
  }
}