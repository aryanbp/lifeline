import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:lifeline/firebase_options.dart';
import 'package:lifeline/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OtherScreens.dart';

//Fix Appointment Page and Add Cancellation of Appointment
//Fix api structure and app structure
//Make Proper Search Page in which you can book and check details about it
//Make other user pages functional
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
  bool _isVisible = false;
  bool loggedIn = false;
  String type = '';
  Map<String, dynamic> res = {};
  late SharedPreferences prefs;
  String? id = '1';
  String api = 'http://192.168.29.13:3000/user';

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
    prefs= await SharedPreferences.getInstance();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // id = user.uid;
        api += '/$id';
        prefs.setInt('id', int.parse(id!));
        loggedIn = true;
        getUser();
      } else {
        prefs.setString('id', '$id');
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
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isVisible = true;
      });
    });
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLine',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          child: loggedIn
              ? UserScreen(type: type, res: res)
              : DashBoard(
                  userData: res,
                )),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({
    super.key,
    required this.type,
    required this.res,
  });

  final String type;
  final Map<String, dynamic> res;
  @override
  Widget build(BuildContext context) {
    return type != ''
        ? (type == 'user'
            ? DashBoard(
                userData: res,
              )
            : OtherScreens(data: res))
        : const MyApp();
  }
}
