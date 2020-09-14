import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_coolrunning/locations.dart' as locations;
import 'package:flutter_coolrunning/speed_monitor.dart';

class MapRoutes extends StatefulWidget
{
  @override
  _MapRoutesState createState() => _MapRoutesState();
}

class _MapRoutesState extends State<MapRoutes>
{
  //final Completer<GoogleMapController> _controllerCompleter = Completer();

  final Map<String, Marker> _markers = {};
  Future<void> mapCreated(GoogleMapController controller) async
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

  GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = 'AIzaSyDL1BPavdJ8ILb31PV8ZeLZjxhq53-6UPo';

  @override
  void initState()
  {
    super.initState();
    //getPoints();

    /// origin marker
    _addMarker(
      LatLng(_originLatitude, _originLongitude),
      'origin',
      BitmapDescriptor.defaultMarker,
    );

    /// destination marker
    _addMarker(
      LatLng(_destLatitude, _destLongitude),
      'destination',
      BitmapDescriptor.defaultMarkerWithHue(90),
    );
    _getPolyline();
  }

  void _onMapCreated(GoogleMapController controller) async
  {
    mapController = controller;
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor)
  {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position
    );
    markers[markerId] = marker;
  }

  void _addPolyLine()
  {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  void _getPolyline() async
  {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty)
    {
      result.points.forEach((PointLatLng point)
      {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context)
  {
    print('Starting coordinates saved in speed monitor class: ${SpeedMonitor.getStartCoord()}');
    print('Ending coordinates saved in speed monitor class: ${SpeedMonitor.getDestCoord()}');

    return Scaffold(
      appBar: titleAppBar,
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(_originLatitude, _originLongitude),
          zoom: 15,
        ),
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        scrollGesturesEnabled: true,
      ),
    );
  }
}