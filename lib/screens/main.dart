import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lifeline/firebase_options.dart';
import 'package:lifeline/screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool loggedIn = false;
  String id = '1';
  String type = '';
  // String api='http://192.168.64.167:3000';
  String api = 'http://192.168.29.13:3000';
  // String api='http://192.168.0.111:3000';
  // String api='http://192.168.208.167:3000';
  Map<String,dynamic> res={};

  Future<void> getUser() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      res = json.decode(response.body)[0];
      type = res['user_type'];
      if (kDebugMode) {
        print('main');
        print(res);
      }
    }
  }

  void checkUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // id = user.uid;
        if (kDebugMode) {
          print(user.uid);
        }
        api += '/$id';
        loggedIn = true;
      } else {
        if (kDebugMode) {
          print(id);
        }
        api += '/$id';
      }
        getUser();
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
    return type!=''?(type=='user'?DashBoard(userData:res,):const OtherScreens()):const MyApp();
  }
}
class OtherScreens extends StatefulWidget {
  const OtherScreens({super.key});

  @override
  State<OtherScreens> createState() => _OtherScreensState();
}

class _OtherScreensState extends State<OtherScreens> {
  int _index=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Screens'),
      ),
      extendBody: true,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the second screen when tapped.
          },
          child:  Text('$_index screen'),
        ),
      ),
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) => setState(() => _index = val),
        currentIndex: _index,
        items: [
          FloatingNavbarItem(icon: Icons.home, title: 'Home'),
          FloatingNavbarItem(icon: Icons.explore, title: 'Explore'),
          FloatingNavbarItem(icon: Icons.chat_bubble_outline, title: 'Chats'),
          FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
        ],
      ),
    );
  }
}


