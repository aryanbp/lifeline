import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:http/http.dart' as http;

class LoadMap extends StatefulWidget {
  const LoadMap({super.key});

  @override
  State<StatefulWidget> createState() => _MyLoadMapState();
}

class _MyLoadMapState extends State<LoadMap> {
  final Completer<GoogleMapController> _mapcontroller = Completer();

  // String api='http://192.168.64.167:3000';
  String api = 'http://192.168.29.13:3000/hospitals';
  // String api='http://192.168.0.111:3000';
  // String api='http://192.168.208.167:3000';

  late final List hospitals;
  double lat=19.149717;
  double log=72.8350457;

  late final Position position;
  static CameraPosition _center =
      const CameraPosition(target: LatLng(19.093914, 72.846541), zoom: 14);
  final List<Marker> _marker = [];
   List<Marker> branch = [];

  List<LatLng> polylineCoordinate = [];


  Future<void> getHospitals() async {
    var url = Uri.parse(api);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      hospitals = json.decode(response.body);
      for(Map hosp in hospitals){
        createMarker(hosp['hospital_name'], hosp['hospital_address'], LatLng(hosp['hospital_lat'],hosp['hospital_log']));
      }
    }
  }
  void createMarker(title,address,position){
    branch.add(Marker(
      markerId: MarkerId('${branch.length+1}'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: title, snippet: address),
      icon: title=='You'?BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure):BitmapDescriptor.defaultMarker,
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
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: const Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
      action: SnackBarAction(label: 'Give Permission', onPressed: (){
        Navigator.pop(context);
        Geolocator.openAppSettings();
      }),));
      return false;
    }
    getLocation();
    return true;
  }

  void getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    _center = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14);
    setState(() {
      List<Placemark> placemarks = await Geolocator.`
      createMarker('You','add',position);
      _marker.addAll(branch);
    });
    if (kDebugMode) {
      print(position);
    }
  }

  void getPolylinePoints() async {
    // PolylinePoints  polylinePoints = PolylinePoints();
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   "AIzaSyB2s9eBKcqaKUNVkKls7gGhlvcWY-oyhHk",
    //   const PointLatLng(19.093914 , 72.846541),
    //   const PointLatLng(19.149717,72.8350457),
    // );
    // print('.....................Points');
    // print(result.points);
    //
    // if(result.points.isNotEmpty){
    //   result.points.forEach((PointLatLng point) => polylineCoordinate.add(LatLng(point.latitude, point.longitude)));
    // }

    // setState(() {
      // Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LoadMap()));
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHospitals();
    _handleLocationPermission();
    getPolylinePoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          GoogleMap(
            markers: Set<Marker>.of(_marker),
            onMapCreated: (GoogleMapController controller) {
              _mapcontroller.complete(controller);
            },
            initialCameraPosition: _center,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 150,
            margin: EdgeInsets.only(top: 80),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                       filled: true,
                      fillColor:Color(0xFFF4F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        // borderSide: BorderSide.none,
                      ),
                      hintText: 'Search Hospital',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 100,
              height: 50,
              margin: EdgeInsets.only(bottom: 60),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all()),
              child: TextButton(
                onPressed: () {},
                child: Text('Next'),
              ),
            ),
          ),
          Align(alignment: Alignment.topLeft,
          child:IconButton(
            padding: EdgeInsets.only(top: 50),
            icon: Icon(Icons.arrow_back_outlined),
            onPressed: () { Navigator.pop(context);
              },
          ) ,
          ),
        ],
      ),
    );
  }
}
