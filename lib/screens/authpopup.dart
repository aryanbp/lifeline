import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'map.dart';

class AuthPopup extends StatefulWidget {
  const AuthPopup({super.key});

  @override
  State<AuthPopup> createState() => _MyAuthPopup();
}

class _MyAuthPopup extends State<AuthPopup> {
  bool clicked = false;
  String verification_Id = '';
  TextEditingController content = TextEditingController();

  Widget getBox() {
    List hints = ['Phone Number', 'OTP'];
    String hint = hints[0];
    if (clicked) {
      hint = hints[1];
    }
    return TextField(
      controller: content,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          hintText: hint,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(
            color: Colors.black,
          )),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        letterSpacing: -0.5,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        SizedBox(height: 20,),
        getBox(),
        SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(50)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  if (clicked) {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verification_Id,
                            smsCode: content.text);
                    FirebaseAuth.instance
                        .signInWithCredential(credential);
                    if (kDebugMode) {
                      print(FirebaseAuth.instance
                          .signInWithCredential(credential));
                    }
                    setState(() {
                      clicked = false;
                      content.clear();
                      FirebaseAuth.instance
                          .authStateChanges()
                          .listen((User? user) {
                        if (user != null) {
                          print(user.uid);
                        }
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoadMap()));
                    });
                  } else {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+91' + content.text,
                      verificationCompleted:
                          ((PhoneAuthCredential credential) {}),
                      verificationFailed: (FirebaseAuthException e) {},
                      codeSent: (String verificationId,
                          int? forceResendingToken) {
                        verification_Id = verificationId;
                      },
                      codeAutoRetrievalTimeout:
                          (String verificationId) {},
                    );
                    setState(() {
                      clicked = true;
                      content.clear();
                    });
                  }
                },
                child:
                    TextButton(
                        onPressed: () {}, child: const Text('Submit')),),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                  ],
                ),
              ),
            ],
          );
  }
}
