import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
//import 'package:flutter_coolrunning/locations.dart';
//import 'package:flutter_coolrunning/locations.dart' as locations;
/*import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';*/
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_coolrunning/speed_monitor.dart';

class MapRoutes extends StatefulWidget
{
  @override
  _MapRoutesState createState() => _MapRoutesState();
}

class _MapRoutesState extends State<MapRoutes>
{
  /*final Map<String, Marker> _markers = {};
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
  }*/

  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> points = SpeedMonitor.getCoordinates();
  double _originLatitude = 0.0;
  double _originLongitude = 0.0;
  double _destLatitude = 0.0;
  double _destLongitude = 0.0;
  final String googleAPIKey = 'AIzaSyDL1BPavdJ8ILb31PV8ZeLZjxhq53-6UPo';

  @override
  void initState()
  {
    super.initState();
    _originLatitude = points[0].latitude;
    _originLongitude = points[0].longitude;
    _destLatitude = points[points.length - 1].latitude;
    _destLongitude = points[points.length - 1].longitude;

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
    var markerId = MarkerId(id);
    var marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;
  }

  void _addPolyLine()
  {
    var id = PolylineId('poly');
    var polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      width: 7,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  void _getPolyline() async
  {
    /// Commented code is for getting navigation between two points
    /// Not suitable for usage in South Korea

    /*PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty)
    {
      result.points.forEach((PointLatLng point)
      {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }*/

    points.forEach((point)
    {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context)
  {
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
        zoomGesturesEnabled: true,
      ),
    );
  }
}