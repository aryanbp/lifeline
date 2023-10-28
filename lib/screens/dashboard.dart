import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lifeline/screens/Appointments.dart';
import 'package:lifeline/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/services.dart';
import 'FindDoctor.dart';
import 'authpopup.dart';
import 'map.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final storage = FirebaseStorage.instance;

  String api = 'http://192.168.29.13:3000/bookingCheck';
  String name = 'User';
  Timer? timer;
  bool? booking;
  Map<String, dynamic> res = {};
  bool display = true;
  var imageUrl = null;
  int _index = 0;

  getPhoto() async {
    var path = await widget.userData['user_pic'];
    final Reference ref = await storage.ref().child(path);
    imageUrl = await ref.getDownloadURL();
    print(imageUrl);
    setState(() {});
  }

  Future<void> checkBooking() async {
    var url = Uri.parse(api);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    booking = prefs.getBool('booking');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      res = body[body.length - 1];
      if (booking == true) {
        setState(() {
          print(res);
          if (res['status'] == 'done' && booking == true) {
            prefs.setBool('booking', false);
            // prefs.clear();
            Fluttertoast.showToast(
                msg: "Ambulance has arrived",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            timer?.cancel();
            timer = null;
          } else if (booking == true) {
            timer = Timer.periodic(
              const Duration(seconds: 10),
              (timer) {
                setState(() {
                  checkBooking();
                });
              },
            );
          } else {
            prefs.setBool('booking', false);
            print('Timer is ${timer?.isActive}');
          }
          print('Checking $booking');
        });
      }
    }
  }

  void getName() {
    setState(() {
      name = FirebaseAuth.instance.currentUser != null &&
              widget.userData['user_name'] != null
          ? widget.userData['user_name']
          : 'User';
    });
  }

  Future<void> getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    booking = prefs.getBool('booking') ?? false;
  }

  authPopup(opt) {
    return showDialog(
        context: context,
        builder: (context) =>
            const Stack(alignment: AlignmentDirectional.topEnd, children: [
              AlertDialog(
                title: Center(
                  child: Text(
                    'Enter Your Phone Number',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                content: SizedBox(
                  height: 180,
                  child: Column(
                    children: [
                      AuthPopup(loggin:false),
                    ],
                  ),
                ),
              ),
            ]));
  }

  Future popup(opt) {
    return showDialog(
        context: context,
        builder: (context) =>
            Stack(alignment: AlignmentDirectional.topEnd, children: [
              AlertDialog(
                title: const Center(
                  child: Text(
                    'Calling an Ambulance for?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                content: SizedBox(
                  height: 180,
                  child: Column(
                    children: [
                      PopUpComp(opt: opt),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () {
                                  print(FirebaseAuth.instance.currentUser?.uid);
                                  print(widget.userData);
                                  // authPopup(opt, len);
                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                      null) {
                                    authPopup(opt);
                                  } else {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoadMap()));
                                  }
                                  // len>0:():();
                                },
                                child: const Text('OK')),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                onPressed: () {
                                  if (display) {
                                    Navigator.pop(context);
                                    popup(['Transport', 'Mortuary']);
                                  } else {
                                    Navigator.pop(context);
                                    popup(['Yourself', 'Others']);
                                  }
                                  display = (!display);
                                },
                                child: display
                                    ? const Text('More')
                                    : const Text('Back')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 225,
                right: 20,
                child: TextButton(
                    onPressed: () {
                      display = true;
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.black,
                      size: 40,
                    )),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.66,
                right: MediaQuery.of(context).size.width * 0.37,
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FlutterPhoneDirectCaller.callNumber('9136220207');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Call 102'),
                      ),
                    )),
              )
            ]));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('Dashtboard');
    print(res);
    getPrefs();
    if (widget.userData.isNotEmpty) {
      getName();
      getPhoto();
      if (widget.userData['user_id'] != null) {
        api += '/${widget.userData['user_id']}';
        checkBooking();
      }
      if (imageUrl != null || widget.userData['user_name'] != null) {
        FlutterNativeSplash.remove();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            height: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(80)),
                              color: Color(0xFFEEF1FF),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset('assets/images/logo.png',
                                    width: 180),
                                Container(
                                    width: 100,
                                    height: 100,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(),
                                    ),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child; // Image is fully loaded, display it
                                              } else {
                                                return CircularProgressIndicator(
                                                  color: Colors.green,
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                      : null,
                                                );
                                              }
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 100,
                                          )),
                              ],
                            ),
                          ),
                          Positioned(
                            child: res.isNotEmpty &&
                                    res['status'] != 'done' &&
                                    booking == true
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 40),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          // transform: GradientRotation(1.5),
                                          colors: res['status'] == 'pending'
                                              ? [
                                                  Colors.red,
                                                  Colors.blue.shade200
                                                ]
                                              : [
                                                  Colors.green,
                                                  Colors.yellow.shade200
                                                ],
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () {
                                          print(res['status']);
                                          setState(() {
                                            checkBooking();
                                          });
                                        },
                                        child:
                                            Text('Ambulance ${res['status']}'),
                                      ),
                                    ),
                                  )
                                : Container(),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 20),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Hello, $name!',
                            style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Box(
                            func: () => popup(['Yourself', 'Others']),
                            side: 'l',
                            color: Color(0xFFEF6969),
                            icon: Icons.emergency_outlined,
                            ic: Color(0xFFEE6463),
                            title: 'Ambulance',
                            sub: 'For Emergency'),
                        Box(
                            func: () => (),
                            side: 'r',
                            color: const Color(0xFF00A3FF),
                            icon: Icons.handshake_outlined,
                            ic: const Color(0xFF0070CA),
                            title: res.isEmpty?'Join Us':'Report Accident',
                            sub: res.isEmpty?'Be Part of Us':'Work With Us'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Box(
                            func: () => Navigator.push(context,MaterialPageRoute(builder: (context) => DoctorSearch()),),
                            side: 'l',
                            color: const Color(0xFFFFEACE),
                            icon: Icons.medical_services_outlined,
                            ic: const Color(0xFFB3827B),
                            title: 'Find Doctor',
                            sub: '200+ Doctors'),
                        Box(
                            func: () => (),
                            side: 'r',
                            color: const Color(0xFFFFEEE1),
                            icon: Icons.science_outlined,
                            ic: const Color(0xFFCB8652),
                            title: 'Lab Test',
                            sub: 'Sample Collection'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Box(
                            func: () => (),
                            side: 'l',
                            color: const Color(0xFFEDF5EB),
                            icon: Icons.email_outlined,
                            ic: const Color(0xFF71A264),
                            title: 'Message',
                            sub: 'Any Query?'),
                        Box(
                            func: () => (),
                            side: 'r',
                            color: const Color(0xFFE7F6F6),
                            icon: Icons.medication_outlined,
                            ic: const Color(0xFF5FAEAE),
                            title: 'Medicines',
                            sub: 'Find/Read'),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     serviceBox(
                    //         context,
                    //         'l',
                    //         const Color(0xFFB3CFF5),
                    //         Icons.help_outline,
                    //         const Color(0xFFA5C3D8),
                    //         'Help',
                    //         'Assistance'),
                    //     serviceBox(
                    //         context,
                    //         'r',
                    //         const Color(0xFFC1D1C8),
                    //         Icons.feedback_outlined,
                    //         const Color(0xFF6F8B8D),
                    //         'FeedBack',
                    //         'Any Suggestions?'),
                    //   ],
                    // ),
                    const SizedBox(
                      height: 90,
                    ),
                  ],
                ),
              ),
              Appointments(id:widget.userData['user_id']),
              Profile(userData: widget.userData),
            ][_index],
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) => setState(() {
          _index = val;
        }),
        currentIndex: _index,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          FloatingNavbarItem(icon: Icons.home_outlined, title: 'Home'),
          FloatingNavbarItem(icon: Icons.paste, title: 'Appointments'),
          FloatingNavbarItem(icon: Icons.person_outline, title: 'Profile'),
        ],
      ),
    );
  }
}

class Who extends StatefulWidget {
  const Who({this.data, this.state, this.city, super.key});
  final data;
  final state;
  final city;

  @override
  State<Who> createState() => _WhoState();
}

class _WhoState extends State<Who> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Column(
        children: [
          Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topEnd,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: widget.state
                        ? Border.all(color: Colors.transparent)
                        : Border.all(),
                    borderRadius: BorderRadius.circular(100),
                    color:
                        widget.state ? const Color(0xFF6AA3FB) : Colors.white,
                  ),
                  child: Icon(Icons.person_outline,
                      color: widget.state ? Colors.white : Colors.black,
                      size: 40),
                ),
                Positioned(
                  bottom: 60,
                  left: 50,
                  child: widget.state
                      ? Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(50)),
                          child: const Icon(
                            Icons.done,
                            color: Colors.black,
                          ),
                        )
                      : Container(),
                ),
              ]),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.data,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
    ;
  }
}

class PopUpComp extends StatefulWidget {
  const PopUpComp({this.opt, super.key});
  final opt;

  @override
  State<PopUpComp> createState() => _PopUpCompState();
}

class _PopUpCompState extends State<PopUpComp> {
  var you = true;
  var oth = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: () {
              setState(() {
                you = (!you);
                oth = (!oth);
              });
            },
            child: Who(data: widget.opt[0], state: you, city: oth)),
        Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(),
          ),
        ),
        TextButton(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: () {
              setState(() {
                you = (!you);
                oth = (!oth);
              });
            },
            child: Who(data: widget.opt[1], state: oth, city: oth)),
      ],
    );
  }
}
