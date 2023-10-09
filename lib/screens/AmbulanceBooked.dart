import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lifeline/screens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbuBookPage extends StatefulWidget {
  const AmbuBookPage(
      {this.hospital_id,
      this.hospital,
      required this.latlng,
      required this.address,
      super.key});
  final hospital;
  final hospital_id;
  final latlng;
  final address;

  @override
  State<AmbuBookPage> createState() => _AmbuBookPageState();
}

class _AmbuBookPageState extends State<AmbuBookPage> {
  String status='being Booked';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ambulance $status',style: TextStyle(fontSize: 18)),
            Text('${widget.hospital}\n'),
            Text('Your Address: \n${widget.address}',textAlign:TextAlign.center,),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('booking',true);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                }, child: Text('SKIP')),
                ElevatedButton(onPressed: (){}, child: Text('FILL DETAILS NOW'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
