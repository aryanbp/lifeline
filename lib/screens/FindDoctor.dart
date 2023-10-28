import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Doctor {
  final String name;
  final String type;
  final String location;
  final String clinicName;

  Doctor({
    required this.name,
    required this.type,
    required this.location,
    required this.clinicName,
  });
}

class DoctorSearch extends StatefulWidget {
  @override
  _DoctorSearchAppState createState() => _DoctorSearchAppState();
}

class _DoctorSearchAppState extends State<DoctorSearch> {
  String api = 'http://192.168.29.13:3000/service/doctors';
  List res = [];

  final List<Doctor> doctors = [
    Doctor(name: 'Dr. John Doe', type: 'Cardiologist', location: 'New York', clinicName: 'HeartCare Clinic'),
    Doctor(name: 'Dr. Jane Smith', type: 'Dermatologist', location: 'Los Angeles', clinicName: 'SkinCare Clinic'),
    Doctor(name: 'Dr. Alice Johnson', type: 'Pediatrician', location: 'Chicago', clinicName: 'ChildCare Clinic'),
    // Add more doctors here
  ];

  List<Doctor> filteredDoctors = [];

  void filterDoctors(String query) {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        final lowerQuery = query.toLowerCase();
        return doctor.name.toLowerCase().contains(lowerQuery) ||
            doctor.type.toLowerCase().contains(lowerQuery) ||
            doctor.location.toLowerCase().contains(lowerQuery) ||
            doctor.clinicName.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  String getClinics(data){
    String info='';
    for(var i=0;i<data.length;i++){
      info+='${data[i]['clinic_name']}, ';
    }
    return info;
  }
  Future<void> getDoctors() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      res = json.decode(response.body);
      print(res);
      for(var i=0;i<res.length;i++){
        doctors.add(
            Doctor(
              name:res[i]['doctor_name'],
              type:res[i]['speciality'],
              location: 'MUMBAI',
              clinicName: getClinics(res[i]['clinic_names_and_addresses']),
            )
        );
      }
      setState(() {});
    } else {
      print('Not Found');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDoctors();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF1FF),

        foregroundColor: Colors.black,
        title: Text('Doctor Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterDoctors,
              decoration: InputDecoration(
                hintText: 'Search for doctors, types, locations, or clinics',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                return ListTile(
                  title: Text(doctor.name),
                  subtitle: Text('${doctor.type}, ${doctor.location}, ${doctor.clinicName}'),
                  // Add more doctor information here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}