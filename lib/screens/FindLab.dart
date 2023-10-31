import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Lab {
  final String name;
  final String phone;
  final String address;
  final String tests;
  final String id;
  Lab({
    required this.name,
    required this.phone,
    required this.address,
    required this.tests,
    required this.id,
  });
}

class LabSearch extends StatefulWidget {
  @override
  _LabSearchAppState createState() => _LabSearchAppState();
}

class _LabSearchAppState extends State<LabSearch> {
  String api = 'http://192.168.29.13:3000/service/labs';
  String api1 = 'http://192.168.29.13:3000/bookLab';
  List res = [];
  TextEditingController tests = TextEditingController();
  late SharedPreferences prefs;
  int id = 0;
  final List<Lab> labs = [
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

  List<Lab> filteredLabs = [];

  void filterLabs(String query) {
    setState(() {
      filteredLabs = labs.where((lab) {
        final lowerQuery = query.toLowerCase();
        return lab.name.toLowerCase().contains(lowerQuery) ||
            lab.phone.toLowerCase().contains(lowerQuery) ||
            lab.address.toLowerCase().contains(lowerQuery) ||
            lab.tests.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> getlabs() async {
    prefs = await SharedPreferences.getInstance();
    id = await prefs.getInt('id')!;
    var url = Uri.parse(api);
    var response = await http.get(url);
    setState(() {
      if (response.statusCode == 200) {
        res = json.decode(response.body);
        print(res);
        for (var i = 0; i < res.length; i++) {
          labs.add(Lab(
            name: res[i]['lab_name'],
            phone: res[i]['lab_phone'],
            address: res[i]['lab_address'],
            tests: res[i]['lab_tests'],
            id: '${res[i]['lab_id']}',
          ));
        }
        filteredLabs = labs;
      } else {
        print('Not Found');
      }
    });
  }

  labInfo(lab) {
    List availableTests = lab.tests.split(',');
    List<bool> checked = List.generate(availableTests.length, (index) => false);
    print(checked);
    return showDialog(
        context: context,
        builder: (context) =>
            Stack(alignment: AlignmentDirectional.center, children: [
              Center(
                child: AlertDialog(
                  title: Center(
                    child: Text(
                      'Want to Book an Appointment',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: SizedBox(
                    height: 180,
                    child: Column(
                      children: [
                        Text(lab.name),
                        Text(lab.phone, style: TextStyle(fontSize: 10)),
                        Text('Available Tests: \n ${lab.tests}',style: TextStyle(fontSize: 12),textAlign: TextAlign.center,),
                        TextField(
                          controller: tests,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            label: Center(child: Text('Enter tests')),
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
                                  var url1 = Uri.parse(api1);
                                  var res1 = await http.post(url1,headers: {
                                    'Content-Type':'application/json'
                                  },
                                      body:jsonEncode({
                                        'lab_id':'${lab.id}',
                                        'user_id':'$id',
                                        'tests':'${tests.text}',
                                      })
                                  ).then((value) => {
                                    Navigator.pop(context),
                                    tests.clear(),
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
                                  tests.clear();
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
    getlabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF1FF),
        foregroundColor: Colors.black,
        title: Text('Lab Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterLabs,
              decoration: InputDecoration(
                hintText: 'Search for labs, types, locations, tests',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLabs.length,
              itemBuilder: (context, index) {
                final lab = filteredLabs[index];
                return ListTile(
                  onTap: () => labInfo(lab),
                  title: Text(lab.name),
                  subtitle: Text('${lab.name}, ${lab.address}, ${lab.tests}'),
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
