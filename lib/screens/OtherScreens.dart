import 'dart:convert';

import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtherScreens extends StatefulWidget {
  final Map<String, dynamic> data;
  const OtherScreens({super.key, required this.data});

  @override
  State<OtherScreens> createState() => _OtherScreensState();
}

class _OtherScreensState extends State<OtherScreens> {
  int _index = 0;
  var imageUrl = null;
  bool clicked = false;
  List res=[];


  Future<void> getRequests() async {
    var url = Uri.parse('http://192.168.29.13:3000/ambuRequests');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      res = json.decode(response.body);
      setState(() {});
    } else {
      print('Not Found');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.data.isNotEmpty) {
      imageUrl = widget.data['user_pic'];
      getRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(80)),
                    color: Color(0xFFEEF1FF),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset('assets/images/logo.png', width: 180),
                      Container(
                          width: 100,
                          height: 100,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(),
                          ),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child; // Image is fully loaded, display it
                                    } else {
                                      return CircularProgressIndicator(
                                        color: Colors.green,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      );
                                    }
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 100,
                                )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: res.isNotEmpty?ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: res.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        clicked = true;
                      });
                    },
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child:Column(
                        children: [
                          Text('${res[index]["user"]["user_id"]}'),
                          Text('${res[index]["user"]["user_name"]}'),
                          Text('${res[index]["hospitals"]?["hospital_name"]}'),
                        ],
                      ),
                    )),
                  ),
                );
              },
            ):CircularProgressIndicator(),
          ),
          if (clicked)
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(
                  child: Text('Hello'),
                ),
              ),
            )
          else
            Container(),
        ],
      ),
      bottomNavigationBar: FloatingNavbar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
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
