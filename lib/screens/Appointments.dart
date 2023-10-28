import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class Appointments extends StatefulWidget {
  final id;
  const Appointments({super.key, required this.id});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  bool _isVisible = false;
  List<bool> isExpandedList = List.generate(3, (index) => false);
  String api = 'http://192.168.29.13:3000/appointments/';
  Map<String, dynamic> res = {};
  List doctor = [];
  List lab = [];

  void toggleExpand(int index) {
    setState(() {
      isExpandedList[index] = !isExpandedList[index];
    });
  }

  Future<void> getAppointments() async {
    var url = Uri.parse(api + '${widget.id}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      res = json.decode(response.body);
      doctor = res['DoctorAppointment'];
      lab=res['labAppointment'];
      setState(() {});
    } else {
      print('Not Found');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppointments();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
        child:res.isEmpty?Center(child: Lottie.network('https://lottie.host/a6bef712-7968-4429-ab6c-e19cffe656ee/hgeQXhow44.json')):SingleChildScrollView(
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(150),
                          bottomRight: Radius.circular(150)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom:220,
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: 100,
                            child: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              bottom: TabBar(
                                labelColor: Colors.black,
                                dividerColor: Colors.black,
                                indicatorColor: Colors.black,
                                splashFactory: NoSplash.splashFactory,
                                tabs: [
                                  Tab(text: 'Doctor'),
                                  Tab(text: 'Lab'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 100,
                            child: Image.asset('assets/images/logo.png', width: 200)),
                        Positioned(
                          bottom: 80,
                          child: Text('Your Appointments',
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        children: [
                          ListView.builder(
                          itemCount: doctor.length,
                          itemBuilder: (context, index) {
                            return InfoBox(
                              isExpanded: isExpandedList[index],
                              toggleExpand: () => toggleExpand(index),
                              data: doctor[index],
                            );
                          },
                        ),
                          lab.length>0?ListView.builder(
                            itemCount: doctor.length,
                            itemBuilder: (context, index) {
                              return InfoBox(
                                isExpanded: isExpandedList[index],
                                toggleExpand: () => toggleExpand(index),
                                data: lab[index],
                              );
                            },
                          ):Center(child: Container(child: Text('No Appointments'),)),
                        ],
                      ),
                    ),
              ],
          ),
        ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final toggleExpand;
  final isExpanded;
  final data;

  const InfoBox(
      {super.key, this.toggleExpand, this.isExpanded, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: toggleExpand,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.95,
          height: isExpanded ? 200 : 100,
          decoration: BoxDecoration(
            color: Color(0xFFEEF1FF),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isExpanded
                      ? MediaQuery.of(context).size.width * 0.9
                      : 0, // Set to 0 when not expanded
                  height: isExpanded ? 200 : 0, // Set to 0 when not expanded
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(color: Color(0xFFEEF1FF),)),
                  child: Visibility(
                    visible: isExpanded, // Only show when expanded
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Dr.Navmi Sulaker',
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                          ),Text(
                            'Appointment no: 5',
                            style: TextStyle(fontSize: 16),
                          ),Text(
                            'Reason for visit: Cold',
                            style: TextStyle(fontSize: 16),
                          ),Text(
                            'Timing: 4:00 PM',
                            style: TextStyle(fontSize: 16),
                          ),Text(
                            'Date: Today',
                            style: TextStyle(fontSize: 16),
                          ),
                          // Add more data here
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              isExpanded == false
                  ? Center(
                      child: Text(
                        '${data['clinic_name']}',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
