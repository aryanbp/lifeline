import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'map.dart';

class AuthPopup extends StatefulWidget {
  const AuthPopup({super.key});

  @override
  State<AuthPopup> createState() => _MyAuthPopup();
}

class _MyAuthPopup extends State<AuthPopup> {
  bool clicked = false;
  bool otp=false;
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
      maxLength: 10,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF6AA3FB) ,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(width: 1, color: Colors.orange),
          ),
          hintText: hint,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(
            color: Colors.white,
          )),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
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
                    if(content.text.length<10){
                      Fluttertoast.showToast(
                          msg: "10 Numbers Needed",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Should Contain Upto 10 Numbers...')));
                    }
                    else if(content.text.contains(new RegExp(r'^[0-9]+$'))){
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+91${content.text}',
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
                    else{
                      Fluttertoast.showToast(
                          msg: "Only Numbers Allowed",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Should Only Contain Numbers...')));
                    }
                  }
                },
                child:const Text('Submit')),
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
