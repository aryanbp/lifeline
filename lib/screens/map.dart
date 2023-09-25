import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

class LoadMap extends StatefulWidget {
  const LoadMap({super.key});

  @override
  State<StatefulWidget> createState() => _MyLoadMapState();
}

class _MyLoadMapState extends State<LoadMap> {
  final Completer<GoogleMapController> _mapcontroller = Completer();

  late final Position position;
  static CameraPosition _center =
      const CameraPosition(target: LatLng(19.093914, 72.846541), zoom: 14);
  final List<Marker> _marker = [];

  final List<Marker> _branch = const [
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(19.093914, 72.846541),
      infoWindow: InfoWindow(title: 'Source'),
    ),
    Marker(
      markerId: MarkerId("2"),
      position: LatLng(19.149717, 72.8350457),
      infoWindow: InfoWindow(title: "Destination", snippet: "Testing"),
    ),
  ];

  List<LatLng> polylineCoordinate = [];

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    getLocation();
    return true;
  }

  void getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _center = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14);
    setState(() {});
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

    setState(() {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoadMap()));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleLocationPermission();
    _marker.addAll(_branch);
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
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            margin: EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(25)),
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
