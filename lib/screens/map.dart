import 'dart:async';
import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:http/http.dart' as http;
import 'package:lifeline/screens/main.dart';

class LoadMap extends StatefulWidget {
  const LoadMap({super.key});

  @override
  State<StatefulWidget> createState() => _MyLoadMapState();
}

class _MyLoadMapState extends State<LoadMap> {
  final Completer<GoogleMapController> _mapcontroller = Completer();

  // String api='http://192.168.64.167:3000';
  String api = 'http://192.168.29.13:3000/service/hospitals';
  // String api='http://192.168.0.111:3000';
  // String api='http://192.168.208.167:3000';

  late final List hospitals;
  Position? position;
  final List<Marker> _marker = [];

  bool tap = false;
  List<String> display_list = [];
  List<Marker> branch = [];
  double lat = 19.149717;
  double log = 72.8350457;

  TextEditingController search_item = TextEditingController();
  TextEditingController your_location = TextEditingController();

  static CameraPosition _center =
      CameraPosition(target: LatLng(19.093914, 72.846541), zoom: 15);

  Future<void> getHospitals() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      hospitals = json.decode(response.body);
      for (Map hosp in hospitals) {
        createMarker(hosp['hospital_name'], hosp['hospital_address'],
            LatLng(hosp['hospital_lat'], hosp['hospital_log']));
      }
      setState(() {
        display_list = hospitals
            .map((hospital) => hospital["hospital_name"].toString())
            .toList();
        print('List ${display_list}');
      });
    }
  }

  void createMarker(title, address, position) {
    branch.add(Marker(
      draggable: title == 'You' ? true:false,
      onDrag: (position)=>{
      setState(() {
      _marker.removeLast();
      branch.removeLast();
      addressFromLocation(position);
      })
      },
      markerId: MarkerId('${branch.length + 1}'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
          title: title,
          snippet: address,
          onTap: () => title == 'You' ? '' : search_item.text = title),
      icon: title == 'You'
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
          : BitmapDescriptor.defaultMarker,
    ));
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      permission = await Geolocator.requestPermission();
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));

        permission = await Geolocator.requestPermission();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Location permissions are permanently denied, we cannot request permissions.'),
        action: SnackBarAction(
            label: 'Give Permission',
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            }),
      ));
      return false;
    }
    getLocation();

    return true;
  }


  void addressFromLocation(position) {
    placemarkFromCoordinates(position.latitude, position.longitude)
        .then((placemarks) {
      setState(() {
        if (placemarks.isNotEmpty) {
          _center = CameraPosition(
              target: LatLng(position.latitude, position.longitude), zoom: 14);
          Placemark info = placemarks[1];
          your_location.text = placemarks[0].name.toString() +
              ', ' +
              info.name.toString() +
              info.street.toString() +
              info.thoroughfare.toString() +
              info.subLocality.toString() +
              info.locality.toString() +
              info.postalCode.toString();
          createMarker('You', your_location.text, position);
        } else {
          print('No results found.');
        }
        _marker.addAll(branch);
      });
    });
  }

  void getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    addressFromLocation(position);
  }

  void changeLocation(argument){
    setState(() {
      _marker.removeLast();
      branch.removeLast();
      addressFromLocation(argument);
      print(_marker[0].position == argument);
    });
  }

  void updateList(val) {
    setState(() {
      if (val == '') {
        display_list = [];
        tap = false;
      } else {
        List display = hospitals
            .where((element) => element['hospital_name']!
                .toLowerCase()
                .contains(val.toLowerCase()))
            .toList();
        display_list = display.map((item) => item.toString()).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getHospitals();
    _handleLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: branch.length < 0
          ? CircularProgressIndicator()
          : Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                GoogleMap(
                  markers: Set<Marker>.of(_marker),
                  onMapCreated: (GoogleMapController controller) {
                    _mapcontroller.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                  trafficEnabled: true,
                  onTap: (argument) => setState(() {
                    changeLocation(argument);
                  }),
                  initialCameraPosition: _center,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 150,
                  margin: EdgeInsets.only(top: 80),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.location_searching,color: Colors.white,),
                              onPressed: () {
                                setState(() {
                                  _marker.removeLast();
                                  branch.removeLast();
                                  getLocation();
                                });
                              },
                              padding: EdgeInsets.zero),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: your_location,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Your Location',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.only(left: 15),
                                // counterText: '',
                                suffix: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.black, size: 30),
                                  onPressed: () {
                                    your_location.clear();
                                  },
                                ),
                              ),
                              textAlignVertical: TextAlignVertical.center,
                            ),
                            // CustomDropdown.search(
                            //     hintText: 'Current Location',
                            //     excludeSelected: true,
                            //     hideSelectedFieldWhenOpen: true,
                            //     fieldSuffixIcon: IconButton(
                            //       icon: Icon(Icons.cancel,
                            //           color: Colors.black, size: 30),
                            //       onPressed: () {
                            //         search_item.clear();
                            //       },
                            //     ),
                            //     listItemStyle: TextStyle(fontSize: 12),
                            //     selectedStyle: TextStyle(fontSize: 12),
                            //     items: display_list.length > 0
                            //         ? display_list
                            //         : ['Not Available'],
                            //     controller: search_item),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.location_on_outlined,color: Colors.white,size: 25,),
                              onPressed: () {},
                              padding: EdgeInsets.zero),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: CustomDropdown.search(
                                hintText: 'Search Hospital',
                                hideSelectedFieldWhenOpen: true,
                                excludeSelected: true,
                                fieldSuffixIcon: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.black, size: 30),
                                  onPressed: () {
                                    search_item.clear();
                                  },
                                ),
                                // listItemStyle: TextStyle(fontSize: 12),
                                // selectedStyle: TextStyle(fontSize: 12),
                                items: display_list.length > 0
                                    ? display_list
                                    : ['Not Available'],
                                controller: search_item),
                          )
                        ],
                      ),
                      // CustomDropdown.search(
                      //   hintText: 'Search Hospital',
                      //     excludeSelected: true,
                      //     fieldSuffixIcon: IconButton(icon: Icon(Icons.cancel,color: Colors.black,size: 30), onPressed: () { search_item.clear(); },),
                      //
                      //     items: display_list.length>0?display_list:['Not Available'],
                      //     controller: search_item)
                      // TextField(
                      //   onChanged: (value) {
                      //     tap = true;
                      //     updateList(value);
                      //   },
                      //   controller: search_item,
                      //   decoration: InputDecoration(
                      //     filled: true,
                      //     fillColor: Color(0xFFF4F5F9),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(16),
                      //       // borderSide: BorderSide.none,
                      //     ),
                      //     hintText: 'Search Hospital',
                      //     suffixIcon: Icon(Icons.search),
                      //   ),
                      // ),
                      // tap
                      //     ? Expanded(
                      //         child: display_list.length == 0
                      //             ? Center(
                      //                 child: Text('No result Found',
                      //                     style: TextStyle(
                      //                         color: Colors.black,
                      //                         fontWeight: FontWeight.bold)),
                      //               )
                      //             : ListView.builder(
                      //                 itemCount: display_list.length,
                      //                 itemBuilder: (context, index) =>
                      //                     ListTile(
                      //                       onTap: (){
                      //                         search_item.text=display_list[index]['hospital_name'];
                      //                         setState(() {
                      //                           tap=false;
                      //                         });
                      //                         },
                      //                   title: Text(
                      //                     display_list[index]
                      //                         ['hospital_name'],
                      //                     style:
                      //                         TextStyle(color: Colors.black),
                      //                   ),
                      //                 ),
                      //               ),
                      //       )
                      //     : Container(),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 100,
                    height: 50,
                    margin: EdgeInsets.only(bottom: 60),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all()),
                    child: TextButton(
                      onPressed: () {
                        if(your_location.text.length>10) {
                          Navigator.pop(context);
                        }
                        else{
                          Fluttertoast.showToast(
                              msg: "Address Needed",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Text('Next'),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: EdgeInsets.only(top: 50),
                    icon: Icon(Icons.arrow_back_outlined),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
