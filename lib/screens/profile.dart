import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifeline/screens/authpopup.dart';
import 'package:lifeline/screens/main.dart';

class Profile extends StatefulWidget {
  Profile({super.key, required this.userData});
  final userData;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final storageRef = FirebaseStorage.instance.ref();
  final storage = FirebaseStorage.instance;
  late final profileRef;
  var imageUrl = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoto();
    widget.userData.length > 0 ? loggedIn = true : loggedIn = false;
  }

  var option = '';
  var loggedIn = false;

  XFile? image;

  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  Widget PicButton(id, text, icon, func) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .90,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            elevation: 6,
            side: BorderSide(
              width: 2,
              color: (option.contains(id)) ? Colors.black : Colors.transparent,
            ),
          ),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
              getImage(func);
              option = id;
            });
          },
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.black),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 20),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Button(content,icon,func){
    return ElevatedButton(
          onPressed: ()=>func,
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.all(16),
          ),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon, // Prefix icon
              Text(content,style: TextStyle(color:Colors.black,fontSize: 16),),
              Icon(Icons.arrow_forward_ios_outlined,color:Colors.black,), // Suffix icon
            ],
          ) );
  }

  getPhoto() async {
    var path = await widget.userData['user_pic'];
    final Reference ref = await storage.ref().child(path);
    imageUrl = await ref.getDownloadURL();
    setState(() {});
  }

  void modelBottomCam(context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Picture',
                    style: TextStyle(fontSize: 25),
                  ),
                  Column(children: [
                    PicButton('t', 'Take a Picture', Icons.camera_alt_outlined,
                        ImageSource.camera),
                    PicButton('g', 'Upload from Gallery',
                        Icons.file_copy_outlined, ImageSource.gallery),
                  ]),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 150, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        elevation: 6,
                        side: const BorderSide(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35.0),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height*0.4,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEF1FF),
                    borderRadius: BorderRadius.circular(25)
                  ),
                  child: Column(
                    children: [
                      loggedIn && image!=null
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 6,
                              side: BorderSide(
                                width: 1,
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: () {
                              var file = File(image!.path);
                              if (image != null) {
                                profileRef = storageRef
                                    .child('user/${widget.userData['user_id']}')
                                    .putFile(file)
                                    .whenComplete(() {
                                  image = null;
                                  setState(() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                    Fluttertoast.showToast(
                                        msg: 'Changes Saved',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  });
                                });
                              }
                            },
                            child: Text('Save Changes',
                                style: TextStyle(color: Colors.lightBlue)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 6,
                              side: BorderSide(
                                width: 1,
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: () {
                              setState(() {
                                print(image?.path);
                                image = null;
                              });
                            },
                            child: Text('Undo Changes',
                                style: TextStyle(color: Colors.lightBlue)),
                          ),
                        ],
                      )
                          : Container(),
                      ElevatedButton(
                          clipBehavior: Clip.antiAlias,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.only(top: 20),
                            shape: CircleBorder(),
                          ),
                          onPressed: () {
                            modelBottomCam(context);
                            setState(() {});
                          },
                          child: image == null && imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width * .5,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                              : image != null
                              ? Image.file(
                            //to show image, you type like this.
                            File(image!.path),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * .5,
                            height: 200,
                          )
                              :Icon(Icons.person,size:MediaQuery.of(context).size.width * .5 ,color:Colors.black)),
                      Text('${widget.userData['user_name']??'User'}',style: TextStyle(fontSize: 25)),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                loggedIn?Column(
                  children: [
                    Button('Edit Profile',Icon(Icons.person,color:Colors.black,),()),
                    Button('Add Family Member',Icon(Icons.family_restroom,color:Colors.black,),()),
                    Button('Previous Bookings',Icon(Icons.medical_services_outlined,color:Colors.black,),()),
                    Button('Previous Appointments',Icon(Icons.paste,color:Colors.black,),()),
                  ],
                ):Container(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 6,
                      side: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      padding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      loggedIn
                          ? setState(() {
                              loggedIn = !loggedIn;
                              FirebaseAuth.instance.signOut().then((value) {
                                Fluttertoast.showToast(
                                    msg: 'Logged Out Successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              });
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyApp()));
                            })
                          : setState(() {
                              AuthPopup();
                            });
                    },
                    child: Text(
                      loggedIn ? 'LogOut' : 'LogIn',
                      style: TextStyle(color: Colors.lightBlue),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
