import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Doctor {
  final String name;
  final String type;
  final String location;
  final String clinicName;
  final String phone;
  Doctor({
    required this.name,
    required this.type,
    required this.location,
    required this.clinicName,
    required this.phone,
  });
}

class DoctorSearch extends StatefulWidget {
  @override
  _DoctorSearchAppState createState() => _DoctorSearchAppState();
}

class _DoctorSearchAppState extends State<DoctorSearch> {
  String api = 'http://192.168.29.13:3000/service/doctors';
  String api1= 'http://192.168.29.13:3000/bookDoc';
  List res = [];
  TextEditingController reason = TextEditingController();
  late SharedPreferences prefs;
  int id=0;
  final List<Doctor> doctors = [
    // Doctor(
    //     name: 'Dr. John Doe',
    //     type: 'Cardiologist',
    //     location: 'New York',
    //     clinicName: 'HeartCare Clinic'),
    // Doctor(
    //     name: 'Dr. Jane Smith',
    //     type: 'Dermatologist',
    //     location: 'Los Angeles',
    //     clinicName: 'SkinCare Clinic'),
    // Doctor(
    //     name: 'Dr. Alice Johnson',
    //     type: 'Pediatrician',
    //     location: 'Chicago',
    //     clinicName: 'ChildCare Clinic'),
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

  String getClinics(data) {
    String info = '';
    for (var i = 0; i < data.length; i++) {
      info += '${data[i]['clinic_name']}, ';
    }
    return info;
  }
  String getNumber(data) {
    String info = '';
    for (var i = 0; i < data.length; i++) {
      info += '${data[i]['clinic_phone']}, ';
    }
    return info;
  }
  Future<void> getDoctors() async {
    prefs= await SharedPreferences.getInstance();
    id=await prefs.getInt('id')!;
    var url = Uri.parse(api);
    var response = await http.get(url);
    setState(() {
      if (response.statusCode == 200) {
        res = json.decode(response.body);
        print(res);
        for (var i = 0; i < res.length; i++) {
          doctors.add(Doctor(
              name: res[i]['doctor_name'],
              type: res[i]['speciality'],
              location: 'MUMBAI',
              clinicName: getClinics(res[i]['clinic_names_and_addresses']),
              phone: getNumber(res[i]['clinic_names_and_addresses'])
          ));
        }
        filteredDoctors=doctors;
      } else {
        print('Not Found');
      }
    });
  }

  doctorInfo(doctor) {
    return showDialog(
        context: context,
        builder: (context) =>
            Stack(alignment: AlignmentDirectional.center, children: [
              Center(
                child: AlertDialog(
                  title: Center(
                    child: Text(
                      'Want to Book an Appointment',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: SizedBox(
                    height: 180,
                    child: Column(
                      children: [
                        Text(doctor.name),
                        Text(doctor.clinicName,style: TextStyle(fontSize: 10)),
                        Text(doctor.location,style: TextStyle(fontSize: 10)),
                        TextField(
                          controller: reason,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            label: Center(child: Text('Reason for Booking')),
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelAlignment: FloatingLabelAlignment.center,

                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                onPressed: () async {
                                  var docid,cdid;
                                  for (var i = 0; i < res.length; i++) {
                                    if( res[i]['doctor_name']==doctor.name){
                                      cdid=res[i]['clinic_names_and_addresses'][0]['cd_id'];
                                    }
                                  }
                                  var url1 = Uri.parse(api1);
                                  var res1 = await http.post(url1,headers: {
                                    'Content-Type':'application/json'
                                  },
                                      body:jsonEncode({
                                        'cd_id':'$cdid',
                                        'user_id':'$id',
                                        'reason':reason.text,

                                      })
                                  ).then((value) => {
                                    Navigator.pop(context),
                                    reason.clear(),
                                  Fluttertoast.showToast(
                                  msg: "Booking Done",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0)
                                  });
                                },
                                child: const Text('Book')),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),

                              ),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  reason.clear();
                                },
                                child: const Text('Cancel')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]));
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
        centerTitle: true,
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
                  onTap: ()=>doctorInfo(doctor),
                  title: Text(doctor.name),
                  subtitle: Text(
                      '${doctor.type}, ${doctor.location}, ${doctor.clinicName}'),
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
