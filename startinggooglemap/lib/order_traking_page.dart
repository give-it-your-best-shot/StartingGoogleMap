import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation =
      LatLng(37.33500926, -122.03272188); // vi tri hien tai
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = []; // list toa do da tuyen
  LocationData? currentLocation;
  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
      setState(() {});
    });
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      print("Debug point: " + point.toString());
    });
    setState(() {});
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  static final Polyline _kPolyline =
      Polyline(polylineId: PolylineId("_kPolyline"), points: [
    LatLng(sourceLocation.latitude, sourceLocation.longitude),
    LatLng(destination.latitude, destination.longitude)
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "Track order",
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: (currentLocation == null)
          ? Center(child: Text("Loading"))
          : Center(
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!)),
                  polylines: {
                    Polyline(
                        polylineId: PolylineId("route"),
                        points: polylineCoordinates,
                        color: Colors.black,
                        width: 10),
                    //_kPolyline
                  },
                  markers: {
                    Marker(
                        markerId: const MarkerId("current location"),
                        position: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!)),
                    const Marker(
                        markerId: MarkerId("source"), position: sourceLocation),
                    const Marker(
                        markerId: MarkerId("destination"),
                        position: destination),
                  }),
            ),
    );
  }
}
