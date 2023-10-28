import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:lifeline/firebase_options.dart';
import 'package:lifeline/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'OtherScreens.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? prefs;
  bool loggedIn = false;
  String id = '2';
  String type = '';
  String api = 'http://192.168.29.13:3000/user';
  Map<String,dynamic> res={};

  Future<void> getUser() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      res = json.decode(response.body)[0];
      type = res['user_type'];
      setState(() {});
      if (kDebugMode) {
        print('main');
        print(res);
      }
    }
  }

  Future<void> checkUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // id = user.uid;
        api += '/$id';
        loggedIn = true;
        getUser();
      } else {
        api += '/$id';
      }
      setState(() {
        FlutterNativeSplash.remove();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLine',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: loggedIn ? UserScreen(type: type,res: res) : DashBoard(userData:res,),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key, required this.type, required this.res,});

  final String type;
  final Map<String,dynamic> res;
  @override
  Widget build(BuildContext context) {
    return type!=''?(type=='user'?DashBoard(userData:res,):OtherScreens(data:res)):const MyApp();
  }
}


