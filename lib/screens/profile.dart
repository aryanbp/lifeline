import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lifeline/screens/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.userData});
  final userData;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userData);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.userData.toString()),
        TextButton(onPressed: (){
          setState(() {
          FirebaseAuth.instance.signOut().then((value){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
            Fluttertoast.showToast(
              msg: 'Logged Out Successfully',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          });
          });
        }, child: Text('LogOut'))
      ],
    );
  }
}
