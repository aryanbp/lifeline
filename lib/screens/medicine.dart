import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Medicine {
  final String name;
  final String cat;
  final String side;
  final String use;
  final String price;
  Medicine({
    required this.name,
    required this.cat,
    required this.side,
    required this.use,
    required this.price,
  });
}

class MedicineSearch extends StatefulWidget {
  @override
  _MedicineAppState createState() => _MedicineAppState();
}

class _MedicineAppState extends State<MedicineSearch> {
  String api = 'http://192.168.29.13:3000/service/medicines';
  List res = [];
  final List<Medicine> medicines = [
    // Medicine(
    //     name: 'Dr. John Doe',
    //     type: 'Cardiologist',
    //     location: 'New York',
    //     clinicName: 'HeartCare Clinic'),
    // Medicine(
    //     name: 'Dr. Jane Smith',
    //     type: 'Dermatologist',
    //     location: 'Los Angeles',
    //     clinicName: 'SkinCare Clinic'),
    // Medicine(
    //     name: 'Dr. Alice Johnson',
    //     type: 'Pediatrician',
    //     location: 'Chicago',
    //     clinicName: 'ChildCare Clinic'),
    // Add more medicines here
  ];

  List<Medicine> filteredMedicines = [];

  void filterMedicines(String query) {
    setState(() {
      filteredMedicines = medicines.where((medicine) {
        final lowerQuery = query.toLowerCase();
        return medicine.name.toLowerCase().contains(lowerQuery) ||
            medicine.cat.toLowerCase().contains(lowerQuery) ||
            medicine.side.toLowerCase().contains(lowerQuery) ||
            medicine.use.toLowerCase().contains(lowerQuery) ||
            medicine.price.toLowerCase().contains(lowerQuery);
        ;
      }).toList();
    });
  }

  Future<void> getMedicines() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    setState(() {
      if (response.statusCode == 200) {
        res = json.decode(response.body);
        print(res);
        for (var i = 0; i < res.length; i++) {
          medicines.add(Medicine(
            name: res[i]['med_name'],
            cat: res[i]['cat'],
            side: res[i]['side'],
            use: res[i]['use'],
            price: '${res[i]['price']}',
          ));
        }
        filteredMedicines = medicines;
      } else {
        print('Not Found');
      }
    });
  }

  medicineInfo(medicine) {
    return showDialog(
        context: context,
        builder: (context) =>
            Stack(alignment: AlignmentDirectional.center, children: [
              Center(
                child: AlertDialog(
                  actionsAlignment: MainAxisAlignment.center,
                  title: Center(
                    child: Text(
                      'Medicine Info',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: SizedBox(
                    height: 180,
                    child: Column(
                      children: [
                        Text('${medicine.name}    Rs.${medicine.price}'),
                        Text(medicine.cat,
                            style: TextStyle(fontSize: 12)),
                        Text(medicine.use, style: TextStyle(fontSize: 12)),
                        Text(medicine.side, style: TextStyle(fontSize: 12)),
                        TextButton(
                            style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
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
    getMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF1FF),
        foregroundColor: Colors.black,
        title: Text('Medicine Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterMedicines,
              decoration: InputDecoration(
                hintText:
                    'Search for medicines, category, price, orside effects',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = filteredMedicines[index];
                return ListTile(
                  onTap: () => medicineInfo(medicine),
                  title: Text(medicine.name),
                  subtitle: Text('${medicine.cat}, ${medicine.use}'),
                  // Add more medicine information here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
