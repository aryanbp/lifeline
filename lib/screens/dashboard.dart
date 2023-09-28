import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../components/services.dart';
import 'authpopup.dart';
import 'map.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool display = true;
  int _index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(80)),
                  color: Color(0xFFEEF1FF),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset('assets/images/logo.png', width: 180),
                    Container(
                      width: 100,
                      height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                      ),
                      child:Image.asset('assets/images/profile.png'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('Hello, User!',
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
                      title: 'Join Us',
                      sub: 'Be Part of Us'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Box(
                      func: () => (),
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
      ),
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) => setState(() => _index = val),
        currentIndex: _index,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          FloatingNavbarItem(icon: Icons.home_outlined, title: 'Home'),
          FloatingNavbarItem(icon: Icons.search, title: 'Search'),
          FloatingNavbarItem(icon: Icons.chat_bubble_outline, title: 'Messages'),
          FloatingNavbarItem(icon: Icons.person_outline, title: 'Profile'),
        ],
      ),
    );
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
                      AuthPopup(),
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
                    border: widget.state?Border.all(color: Colors.transparent):Border.all(),
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
