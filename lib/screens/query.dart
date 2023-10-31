import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class query extends StatefulWidget {
  const query({super.key});

  @override
  State<query> createState() => _queryState();
}

class _queryState extends State<query> {
  @override

  final email=TextEditingController();
  final sub=TextEditingController();
  final msg=TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF1FF),
        foregroundColor: Colors.black,
        title: Text('Query?'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(title:'Subject',controller:sub),
            SizedBox(height: 16,),
            buildTextField(title:'Message',controller:msg,maxLines:8),
            SizedBox(height: 32,),
            ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEEF1FF),
                foregroundColor: Colors.black,
                minimumSize: Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 20),
              ),
              child:Text('SEND'),
              onPressed: ()=>launchEmail(
                toEmail:"aryapanikar9@gmail.com",
                subject:sub.text,
                message:msg.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future launchEmail({
    required String toEmail,
    required String subject,
    required String message,
})async{
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': message,
      }),
    );
    // final url='mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}';
      await launchUrl(emailLaunchUri,mode: LaunchMode.externalApplication);
  }
  Widget buildTextField({
    required String title,
    required TextEditingController controller,
    int maxLines=1,
})=>Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8,),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      )
    ],
  );
}
