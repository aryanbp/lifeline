
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthPopup extends StatefulWidget {
  const AuthPopup({super.key});

  @override
  State<AuthPopup> createState() => _MyAuthPopup();
}

class _MyAuthPopup extends State<AuthPopup> {
  bool clicked = false;
  String verification_Id = '';
  TextEditingController content = TextEditingController();
  String api = 'http://192.168.29.13:3000';

  Future<int> getUser() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      return 1;
    } else {
      return 0;
    }
  }

  Widget getBox() {
    List hints = ['Phone Number', 'OTP'];
    String hint = hints[0];
    if (clicked) {
      hint = hints[1];
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 1),
          width: 3,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: TextField(
        controller: content,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.800000011920929),
            )),
        textAlign: TextAlign.left,
        style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.800000011920929),
            fontFamily: 'Poppins',
            fontSize: 17,
            letterSpacing: -0.5,
            fontWeight: FontWeight.normal,
            height: 1.7),
      ),
    );
  }

  void checkUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
      } else {
        print('Not Available');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Balckcoffer',
                style: TextStyle(
                    fontFamily: 'Waterfall',
                    fontSize: 80,
                    color: Color(0xFF3B21B5)),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Text(
                      'Sign In',
                      style:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    getBox(),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    ElevatedButton(
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
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Home()));
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
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}