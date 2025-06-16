import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../services/api.dart';
import '../../utils/colors.dart';

class LivedataAnalysis extends StatefulWidget {
  const LivedataAnalysis({super.key});

  @override
  State<LivedataAnalysis> createState() => _LivedataAnalysisState();
}

class _LivedataAnalysisState extends State<LivedataAnalysis> {

  String? speedValue, socValue, locationName;
  late MapController _mapController;
  LatLng _mapCenter = LatLng(12.9716, 77.5946); // Bengaluru

  double? accelX, accelY, accelZ;
  Queue<FlSpot> speedValueData = Queue<FlSpot>();
  Queue<FlSpot> socValueData = Queue<FlSpot>();

  Queue<FlSpot> accelerationXData = Queue<FlSpot>();
  Queue<FlSpot> accelerationYData = Queue<FlSpot>();
  Queue<FlSpot> accelerationZData = Queue<FlSpot>();

  Queue<FlSpot> gyroXData = Queue<FlSpot>();
  Queue<FlSpot> gyroYData = Queue<FlSpot>();
  Queue<FlSpot> gyroZData = Queue<FlSpot>();

  int timeCounter = 0;
  String _currentTimestamp = "";

  late StreamSubscription _dataStream;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLiveUpdates();
  }

  void _startLiveUpdates() {
    _dataStream = Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      await _updateTime();
      await _fetchLiveData();
    });
  }

  Future<void> _updateTime() async {
    setState(() {
      _currentTimestamp = DateFormat('yyyy-MMMM-dd HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _fetchLiveData() async {
    await Future.wait([
      _fetchSpeed(),
      _fetchSOC(),
      _fetchLocation(),
      _fetchAcceleration(),
      _fetchGyro(),
    ]);
  }

  Future<void> _fetchSpeed() async {
    try {
      final response = await http.get(Uri.parse(BaseURLConfig.speedApiURL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data.isNotEmpty) {
          final latestSpeed = double.parse(data.last['vehicle_speed'].toString());
          setState(() {
            speedValue = latestSpeed.toString();
            if (speedValueData.length > 100) speedValueData.removeFirst();
            speedValueData.add(FlSpot(timeCounter.toDouble(), latestSpeed));
          });
          timeCounter++;
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchSOC() async {
    try {
      final response = await http.get(Uri.parse(BaseURLConfig.batterySOCApiURL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data.isNotEmpty) {
          final latestSOC = double.parse(data.last['soc_drive_info'].toString());
          setState(() {
            socValue = latestSOC.toString();
            if (socValueData.length > 100) socValueData.removeFirst();
            socValueData.add(FlSpot(timeCounter.toDouble(), latestSOC));
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchLocation() async {
    try {
      final response = await http.get(Uri.parse(BaseURLConfig.locationApiURL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data.isNotEmpty) {
          final lat = data.last['latitude'];
          final lon = data.last['longitude'];
          setState(() {
            _mapCenter = LatLng(lat, lon);
            locationName = 'Lat: $lat\nLong: $lon';
          });
          _mapController.move(_mapCenter, 18.0);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchAcceleration() async {
    try {
      final response = await http.get(Uri.parse(BaseURLConfig.accelApiURL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          accelX = data["xaxis"].toDouble();
          accelY = data["yaxis"].toDouble();
          accelZ = data["zaxis"].toDouble();
          if (accelerationXData.length > 100) accelerationXData.removeFirst();
          accelerationXData.add(FlSpot(timeCounter.toDouble(), accelX!));
          accelerationYData.add(FlSpot(timeCounter.toDouble(), accelY!));
          accelerationZData.add(FlSpot(timeCounter.toDouble(), accelZ!));
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchGyro() async {
    try {
      final response = await http.get(Uri.parse(BaseURLConfig.gyroApiURL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          if (gyroXData.length > 100) gyroXData.removeFirst();
          gyroXData.add(FlSpot(timeCounter.toDouble(), data["xaxis"].toDouble()));
          gyroYData.add(FlSpot(timeCounter.toDouble(), data["yaxis"].toDouble()));
          gyroZData.add(FlSpot(timeCounter.toDouble(), data["zaxis"].toDouble()));
        });
      }
    } catch (_) {}
  }

  LineChartData _buildAccelerationChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value % 2 == 0) {
                return Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    color: oBlack,
                    fontSize: 12,
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: accelerationXData.toList(),
          isCurved: true,
          color: oBlueDark,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: oBlueDark.withOpacity(0.3),
          ),
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: accelerationYData.toList(),
          isCurved: true,
          color: oBlueSky,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: oBlueSky.withOpacity(0.3),
          ),
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: accelerationZData.toList(),
          isCurved: true,
          color: oBlueLight,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: oBlueLight.withOpacity(0.3),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
      minY: -2,
      maxY: 2,
      minX: 0,
      maxX: timeCounter.toDouble(),

      lineTouchData: LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return const TouchedSpotIndicatorData(
              FlLine(
                color: oBlueDark, // default vertical line indicator
              ),
              FlDotData(show: false),  // default dot indicator
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) {
            // Set the tooltip color to black
            return oBlack;
          },
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            // Create a tooltip item for each touched spot
            return touchedSpots.map((touchedSpot) {
              // Check which line (X, Y, or Z) is being touched
              String label;
              if (touchedSpot.barIndex == 0) {
                label = 'x: ${touchedSpot.y.toStringAsFixed(2)}';
              } else if (touchedSpot.barIndex == 1) {
                label = 'y: ${touchedSpot.y.toStringAsFixed(2)}';
              } else {
                label = 'z: ${touchedSpot.y.toStringAsFixed(2)}';
              }

              return LineTooltipItem(
                label,
                GoogleFonts.poppins(
                  color: oWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartData _buildGyroChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              // Reverse scaling to display ±2000 labels
              double originalValue = (value / 180) * 2000;

              // Show only appropriate intervals
              if (originalValue % 500 == 0) {
                return Text(
                  originalValue.toStringAsFixed(0), // Adjust precision as needed
                  style: GoogleFonts.poppins(
                    color: oBlack,
                    fontSize: 12,
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: gyroXData.map((e) => FlSpot(e.x, (e.y / 2000) * 180)).toList(), // Scale data
          isCurved: true,
          color: oRed,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: gyroYData.map((e) => FlSpot(e.x, (e.y / 2000) * 180)).toList(), // Scale data
          isCurved: true,
          color: oOrange,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: gyroZData.map((e) => FlSpot(e.x, (e.y / 2000) * 180)).toList(), // Scale data
          isCurved: true,
          color: oGrey,
          barWidth: 1,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: false),
        ),
      ],
      minY: -180, // Display range
      maxY: 180,  // Display range
      minX: 0,
      maxX: timeCounter.toDouble(),

      lineTouchData: LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return const TouchedSpotIndicatorData(
              FlLine(color: oOrange),
              FlDotData(show: false),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) => oBlack,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              String label;
              if (touchedSpot.barIndex == 0) {
                label = 'roll: ${(touchedSpot.y / 180 * 2000).toStringAsFixed(2)}';
              } else if (touchedSpot.barIndex == 1) {
                label = 'pitch: ${(touchedSpot.y / 180 * 2000).toStringAsFixed(2)}';
              } else {
                label = 'yaw: ${(touchedSpot.y / 180 * 2000).toStringAsFixed(2)}';
              }

              return LineTooltipItem(
                label,
                GoogleFonts.poppins(
                  color: oWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: oTransparent,
                        border: Border.all(width: 0.4, color: oBlack),
                      ),
                      child: Center(
                        child: Text(
                          "Devices",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: oBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 140,
                      height: 30,
                      decoration: BoxDecoration(
                        color: oTransparent,
                        border: Border.all(width: 0.6, color: oBlack),
                      ),
                      child: Center(
                        child: Text(
                          "Car#6GDF5653",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: oBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 30,
                      decoration: BoxDecoration(
                        color: oTransparent,
                        border: Border.all(width: 0.4, color: oBlack),
                      ),
                      child: Center(
                        child: Text(
                          "Parameters",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: oBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 350,
                      height: 30,
                      decoration: BoxDecoration(
                        color: oTransparent,
                        border: Border.all(width: 0.6, color: oBlack),
                      ),
                      child: Center(
                        child: Text(
                          "Speed + Acceleration + Gyroscope + Battery SOC",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: oBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Row(
              children: [
                Container(
                  width: 120,
                  height: 30,
                  decoration: BoxDecoration(
                    color: oTransparent,
                    border: Border.all(width: 0.4, color: oBlack),
                  ),
                  child: Center(
                    child: Text(
                      "Live Timestamp",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: oBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 200,
                  height: 30,
                  decoration: BoxDecoration(
                    color: oTransparent,
                    border: Border.all(width: 0.6, color: oBlack),
                  ),
                  child: Center(
                    child: Text(
                      _currentTimestamp, // Display live timestamp with date
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: oBlack, // Red color for visibility
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 175,
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/car.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                buildParameterInfo(
                  title: "Speed",
                  value: speedValue?.toString() ?? "0",
                  unit: "km/h",
                  gradient: oGreenGradient1,
                  width: 175,
                ),
                const SizedBox(height: 15,),
                buildParameterInfo(
                  title: "Battery SOC",
                  value: socValue?.toString() ?? "0",
                  unit: "%",
                  gradient: oBlueGradient1,
                  width: 175,
                ),

              ],
            ),
            const SizedBox(width: 15,),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.427,
                  height: 175,
                  decoration: BoxDecoration(
                      color: oTransparent,
                      border: Border.all(width: 0.4, color: oBlack)
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Acceleration (m/s\u00B2)",
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: oBlack,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Expanded(
                        child: LineChart(
                            _buildAccelerationChartData()
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Row(
                            children: [
                              _buildLegend("x", oBlueDark),
                              const SizedBox(width: 10),
                              _buildLegend("y", oBlueSky),
                            ],
                          ),
                          const Spacer(),
                          _buildLegend("z", oBlueLight),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width * 0.427,
                  height: 175,
                  decoration: BoxDecoration(
                      color: oTransparent,
                      border: Border.all(width: 0.4, color: oBlack)
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gyroscope (\u00B0/s)", //Altitude
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: oBlack,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Expanded(
                        child: LineChart(
                            _buildGyroChartData()
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Row(
                            children: [
                              _buildLegend("roll", oRed),
                              const SizedBox(width: 10),
                              _buildLegend("pitch", oOrange),
                            ],
                          ),
                          const Spacer(),
                          _buildLegend("yaw", oGrey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15,),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 365,
              decoration: BoxDecoration(
                color: oTransparent,
                border: Border.all(width: 0.4, color: oBlack),
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "GPS Position",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: oBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: oWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: oBlack.withOpacity(0.3),
                                spreadRadius: 0.5,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ]
                        ),
                        child: IconButton(
                            onPressed: (){}, // _moveToCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 15, color: oBlack)
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(initialCenter: _mapCenter, keepAlive: true),
                      children: [
                        TileLayer(
                            tileProvider: CancellableNetworkTileProvider(),
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _mapCenter,
                              width: 10.0,
                              height: 10.0,
                              child: Container(
                                decoration: const BoxDecoration(
                                    gradient: oBlueGradient2,
                                    shape: BoxShape.circle
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            )
          ],
        ),

      ],
    );
  }

  Widget buildParameterInfo({
    required String title,
    required String value,
    required String unit,
    required Gradient gradient,
    double width = 200,
    double height = 110,
    double fontSize = 35,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: oWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                      color: oWhite,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: " $unit",
                    style: GoogleFonts.poppins(
                      color: oWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 5,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4)
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: oBlack,
              fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

}
