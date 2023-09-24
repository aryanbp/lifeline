import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  bool loggedIn = true;
  String id = '2';
  String type = 'user';
  String api = 'http://192.168.29.13:3000';

  Future<void> getUser() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (kDebugMode) {
        type = res[0]['user_type'];
        print(res[0]['user_type']);
      }
    }
  }

  void checkUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        id = user.uid;
        loggedIn = true;
      } else {
        api += '/$id';
        getUser();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: loggedIn ? UserScreen(type: type) : DashBoard(),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key, required this.type,});

  final String type;
  @override
  Widget build(BuildContext context) {
    return type=='user'?DashBoard():const OtherScreens();
  }
}
class OtherScreens extends StatelessWidget {
  const OtherScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Screens'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the second screen when tapped.
          },
          child: const Text('Launch screen'),
        ),
      ),
    );
  }
}

