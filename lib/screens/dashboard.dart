import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authpopup.dart';
import 'map.dart';

class DashBoard extends StatefulWidget {
   const DashBoard({super.key, this.userData});

  final userData;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  var display=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var len=widget.userData.length;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    Image.asset('assets/images/logo.png', width: 200),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                      ),
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
                  TextButton(
                    onPressed: (){
                      popup(['Yourself','Others'],len);
                    },
                    child: serviceBox(
                        context,
                        'l',
                        const Color(0xFFEF6969),
                        Icons.emergency_outlined,
                        const Color(0xFFEE6463),
                        'Ambulance',
                        'For Emergency'),
                  ),
                  TextButton(
                    onPressed: () {  },
                    child: serviceBox(
                        context,
                        'r',
                        const Color(0xFF00A3FF),
                        Icons.handshake_outlined,
                        const Color(0xFF0070CA),
                        'Join Us',
                        'Be Part of Us'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {  },
                    child: serviceBox(
                        context,
                        'l',
                        const Color(0xFFFFEACE),
                        Icons.medical_services_outlined,
                        const Color(0xFFB3827B),
                        'Find Doctor',
                        '200+ Doctors'),
                  ),
                  TextButton(
                    onPressed: () {  },
                    child: serviceBox(
                        context,
                        'r',
                        const Color(0xFFFFEEE1),
                        Icons.science_outlined,
                        const Color(0xFFCB8652),
                        'Lab Test',
                        'Sample Collection'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {  },
                    child: serviceBox(
                        context,
                        'l',
                        const Color(0xFFEDF5EB),
                        Icons.email_outlined,
                        const Color(0xFF71A264),
                        'Message',
                        'Any Query?'),
                  ),
                  TextButton(
                    onPressed: () {  },
                    child: serviceBox(
                        context,
                        'r',
                        const Color(0xFFE7F6F6),
                        Icons.medication_outlined,
                        const Color(0xFF5FAEAE),
                        'Medicines',
                        'Find/Read'),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  authPopup(opt,len){
    return showDialog(context: context, builder: (context)=>
        const Stack(
      alignment: AlignmentDirectional.topEnd,
        children: [
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
  Future popup(opt,len) {
    return showDialog(
        context: context,
        builder: (context) => Stack(
          alignment: AlignmentDirectional.topEnd,
            children: [
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
                      PopUpComp(opt:opt),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(onPressed: () {
                              Navigator.pop(context);
                              // print(FirebaseAuth.instance.currentUser?.uid);
                              len<0?authPopup(opt, len):Navigator.push(context, MaterialPageRoute(builder: (context)=> LoadMap()));
                                // len>0:():();
                            }, child: const Text('OK')),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                            ),
                            TextButton(onPressed: () {
                              display?popup(['Transfer','Transport'],len):();display=false;}, child: const Text('More')),
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
                      display=true;
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.black,
                      size: 40,
                    )),
              )
            ]));
  }

  Widget serviceBox(context, side, color, icon, ic, title, sub) {
    return Container(
      alignment: side == 'l' ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: side == 'l'
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: side == 'r'
                ? const Radius.circular(20)
                : const Radius.circular(0),
          ),
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: Icon(
                  icon,
                  color: ic,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.black, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class who extends StatefulWidget {
   who({this.data,this.state,this.city,super.key});
  final data;
  var state;
  var city;

  @override
  State<who> createState() => _whoState();
}

class _whoState extends State<who> {

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
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
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(100),
                      color: widget.state?const Color(0xFF6AA3FB):Colors.white,
                    ),
                    child:  Icon(Icons.person_outline,
                        color: widget.state?Colors.white:Colors.black, size: 40),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 50,
                    child: widget.state?Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(
                        Icons.done,
                        color: Colors.black,
                      ),
                    ):Container(),
                  ),
                ]),
            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(
                widget.data,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );;
  }
}

class PopUpComp extends StatefulWidget {
  const PopUpComp({this.opt,super.key});
  final opt;

  @override
  State<PopUpComp> createState() => _PopUpCompState();
}

class _PopUpCompState extends State<PopUpComp> {
  var you=true;
  var oth=false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(onPressed: () { setState(() {
          you=(!you);
          oth=(!oth);
        }); },
        child: who(data:widget.opt[0],state: you,city: oth)),
        Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(),
          ),
        ),
        TextButton(onPressed: () { setState(() {
          you=(!you);
          oth=(!oth);
        }); },
        child: who(data:widget.opt[1],state: oth,city: oth)),
      ],
    );
  }
}



