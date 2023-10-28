import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final List<Map<String, dynamic>> statistics = [
    {'title': 'Total Ambulances Booked', 'value': 15},
    {'title': 'Total User Registered', 'value': 250},
    {'title': 'Total Doctor Appointments Booked', 'value': 100},
    {'title': 'Total Lab Appointments Booked', 'value': 50},
    {'title': 'Total Users Who Opened the App Today', 'value': 30},
    {'title': 'Total Number of Accidents Reported', 'value': 5},
    {'title': 'Total Number of Drivers', 'value': 10},
    {'title': 'Total Number of Doctors', 'value': 20},
    {'title': 'Total Number of Receptionists', 'value': 15},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Page'),backgroundColor: Color(0xFFEEF1FF),foregroundColor: Colors.black),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
        ),
        itemCount: statistics.length,
        itemBuilder: (context, index) {
          final stat = statistics[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(stat['value'].toString(), style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
