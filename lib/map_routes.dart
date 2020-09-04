import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_coolrunning/locations.dart' as locations;

class MapRoutes extends StatefulWidget
{
  @override
  _MapRoutesState createState() => _MapRoutesState();
}

class _MapRoutesState extends State<MapRoutes>
{
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async
  {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: titleAppBar,
      body: /*GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),*/
      GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: const LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}