import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'src/utils/colors.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  List<LatLng> _geofencePolygon = [];
  bool _isInsideGeofence = false;
  final TextEditingController _searchController = TextEditingController();

  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadGeofence('Eiffel Tower'); // Default geofence
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _checkGeofence();
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _loadGeofence(String placeName) async {
    try {
      _geofencePolygon = await fetchGeofencePolygon(placeName);
      setState(() {});
    } catch (e) {
      print("Error loading geofence: $e");
    }
  }

  void _checkGeofence() {
    if (_currentLocation != null && _geofencePolygon.isNotEmpty) {
      setState(() {
        _isInsideGeofence = isPointInPolygon(_currentLocation!, _geofencePolygon);
      });
      print("Is inside geofence: $_isInsideGeofence");
    }
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % polygon.length];
      if (point.longitude > [p1.longitude, p2.longitude].reduce((a, b) => a < b ? a : b) &&
          point.longitude <= [p1.longitude, p2.longitude].reduce((a, b) => a > b ? a : b) &&
          point.latitude <= [p1.latitude, p2.latitude].reduce((a, b) => a > b ? a : b) &&
          p1.longitude != p2.longitude) {
        double intersect = (point.longitude - p1.longitude) * (p2.latitude - p1.latitude) /
            (p2.longitude - p1.longitude) +
            p1.latitude;
        if (p1.latitude == p2.latitude || point.latitude <= intersect) {
          intersectCount++;
        }
      }
    }
    return intersectCount % 2 != 0;
  }

  Future<List<LatLng>> fetchGeofencePolygon(String placeName) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$placeName&format=geojson'));

      if (response.statusCode == 200) {
        final geoJson = json.decode(response.body);

        if (geoJson['features'] != null && geoJson['features'].isNotEmpty) {
          final feature = geoJson['features'][0];
          if (feature['geometry'] != null &&
              feature['geometry']['type'] == 'Polygon') {
            final coordinates = feature['geometry']['coordinates'][0];
            return coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
          } else if (feature['geometry'] != null && feature['geometry']['type'] == "Point"){
            final lat = feature['geometry']['coordinates'][1];
            final long = feature['geometry']['coordinates'][0];
            return createCirclePolygon(LatLng(lat,long), .01);
          } else {
            throw Exception('No polygon found for the given place.');
          }
        } else {
          throw Exception('Place not found.');
        }
      } else {
        throw Exception('Failed to load geofence data');
      }
    } catch (e) {
      print("Error fetching geofence polygon: $e");
      return [];
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          _suggestions = results
              .map<String>((result) => result['display_name'].toString())
              .toList();
        });
      } else {
        print('Failed to fetch suggestions');
        setState(() {_suggestions = [];});
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {_suggestions = [];});
    }
  }
  List<LatLng> createCirclePolygon(LatLng center, double radius){
    List<LatLng> polygon = [];
    int numberOfPoints = 30;
    double angleIncrement = 360/numberOfPoints;
    for (int i = 0; i < numberOfPoints; i++){
      double angle = i * angleIncrement;
      double radianAngle = angle * (3.14159265359/180);
      double lat = center.latitude + (radius * Math.sin(radianAngle));
      double long = center.longitude + (radius * Math.cos(radianAngle));
      polygon.add(LatLng(lat,long));
    }
    return polygon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oWhite,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (text) {
                      _fetchSuggestions(text);
                    },
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: oBlack,
                    ),
                    cursorColor: oBlack,
                    decoration: InputDecoration(
                      labelText: 'Search by Place Name for Geofencing',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: oBlack,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: oBlackOpacity),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: oBlackOpacity),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: oBlackOpacity),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: oBlackOpacity),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: oWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: oBlack.withOpacity(0.3),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset: Offset(1, 1),
                      ),
                    ]
                  ),
                  child: IconButton(
                    icon: Icon(CupertinoIcons.search, size: 18,color: oBlack),
                    onPressed: () {
                      _loadGeofence(_searchController.text);
                      setState(() {_suggestions = [];});
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              height: 150,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      _searchController.text = _suggestions[index];
                      _loadGeofence(_suggestions[index]);
                      setState(() {_suggestions = [];});
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: _currentLocation == null
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
              options: MapOptions(initialCenter: _currentLocation!, keepAlive: true),
              children: [
                TileLayer(
                  tileProvider: CancellableNetworkTileProvider(),
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"

                  //urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  //subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 15.0,
                      height: 15.0,
                      // Assuming you have oBlueGradient defined.
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: oBlueGradient,
                            shape: BoxShape.circle
                        ),
                      ),
                    ),
                  ],
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _geofencePolygon,
                      color: _isInsideGeofence ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                      borderColor: _isInsideGeofence ? Colors.green : Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}