
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/colors.dart';

class PostDataAnalysis extends StatefulWidget {
  const PostDataAnalysis({super.key});

  @override
  State<PostDataAnalysis> createState() => _PostDataAnalysisState();
}

class _PostDataAnalysisState extends State<PostDataAnalysis> {
  String _postTimestamp = "2025 February 17 11:49:35"; // Store the post timestamp

  String? speedValue;
  int? rssiValue;
  String? socValue;
  String? locationName;

  int? odo;

  late MapController _mapController;

  // Set a fixed location for Bengaluru
  final LatLng _mapCenter = LatLng(12.9716, 77.5946);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Move the map to the fixed center location after the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToCurrentLocation();
    });
  }

  void _moveToCurrentLocation() {
    _mapController.move(_mapCenter, 18.0); // Keep zoom level at 18
  }

  // speed dummy data
  final List<FlSpot> speedData = List.generate(
    125, // Number of data points (adjustable between 25-50)
        (index) => FlSpot(index.toDouble(), Random().nextDouble() * 150),
  );

  final double speedLimit = 100; // Speed limit at 100 km/h

  //power regen and consumption dummy data
  final List<BarChartGroupData> barGroups = List.generate(
    10, // 10 bars in total (5 for regeneration, 5 for consumption)
        (index) {
      double value = (index < 5) ?  // First 5 bars for regeneration
      (50 + (index * 10)) :      // Increasing regen values
      (80 - (index * 6));       // Decreasing consumption values

      return BarChartGroupData(
        x: index,
        barsSpace: 0, // Space between bars
        barRods: [
          BarChartRodData(
            toY: value,
            color: index < 5 ? oBlueDark : oRed.withOpacity(0.6), // Green for Regen, Red for Consumption
            width: 38,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    },
  );

  //acceleration dummy data
  final List<FlSpot> xValues = List.generate(
    100,
        (index) => FlSpot(index.toDouble(), Random().nextDouble() * 4 - 2), // Values between -2 to 2
  );

  final List<FlSpot> yValues = List.generate(
    100,
        (index) => FlSpot(index.toDouble(), Random().nextDouble() * 4 - 2), // Values between -2 to 2
  );

  final List<FlSpot> zValues = List.generate(
    100,
        (index) => FlSpot(index.toDouble(), Random().nextDouble() * 4 - 2), // Values between -2 to 2
  );

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: false, // No curves, only straight lines
      color: color,
      barWidth: 1,
      isStrokeCapRound: false,
      dotData: FlDotData(show: false), // Hide dots
      belowBarData: BarAreaData(show: false), // No fill below line
    );
  }

  // Gyroscope dummy data with values between -180 and 180
  final List<FlSpot> rollValues = List.generate(
    60,
        (index) => FlSpot(index.toDouble(), (Random().nextDouble() * 360 - 180)), // Values between -180 to 180
  );

  final List<FlSpot> pitchValues = List.generate(
    60,
        (index) => FlSpot(index.toDouble(), (Random().nextDouble() * 180 - 90)), // Values between -180 to 180
  );

  final List<FlSpot> yawValues = List.generate(
    60,
        (index) => FlSpot(index.toDouble(), (Random().nextDouble() * 90 - 45)), // Values between -180 to 180
  );

  LineChartBarData _buildGyroLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: false, // No curves, only straight lines
      color: color,
      barWidth: 1,
      isStrokeCapRound: false,
      dotData: FlDotData(show: false), // Hide dots
      belowBarData: BarAreaData(show: false), // No fill below line
    );
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
                      "Post Timestamp",
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
                      _postTimestamp, // Display live timestamp with date
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
          children: [
            Column(
              children: [
                Row(
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
                    const SizedBox(width: 30,),

                    buildParameterInfo(
                      title: "Speed",
                      value: speedValue?.toString() ?? "65",
                      unit: "km/h",
                      gradient: oGreenGradient1,
                      width: 150,
                    ),
                    const SizedBox(width: 10,),
                    buildParameterInfo(
                      title: "SOC(Last)",
                      value: socValue?.toString() ?? "73",
                      unit: "%",
                      gradient: oBlueGradient2,
                      width: 150,
                    ),
                    const SizedBox(width: 10),
                    buildParameterInfo(
                      title: "SOC(Used)",
                      value: socValue?.toString() ?? "22",
                      unit: "%",
                      gradient: oBlueGradient1,
                      width: 150,
                    ),
                    const SizedBox(width: 10),
                    buildParameterInfo(
                      title: "Distance",
                      value: odo?.toString() ?? "125",
                      unit: "km",
                      gradient: oBlueGradient3,
                      width: 175,
                    ),
                    const SizedBox(width: 10,),
                    buildParameterInfo(
                      title: "Inside \u00B0C",
                      value: "12.2",
                      unit: "",
                      gradient: oRedGradient,
                      width: 125,
                    ),
                    const SizedBox(width: 10,),
                    buildParameterInfo(
                      title: "Outside \u00B0C",
                      value: "22.2",
                      unit: "",
                      gradient: oRedGradient1,
                      width: 125,
                    ),
                    const SizedBox(width: 10,),
                    buildParameterInfo(
                      title: "Battery \u00B0C",
                      value: "17.0",
                      unit: "",
                      gradient: oPinkGradient,
                      width: 125,
                    ),

                  ],
                ),
                const SizedBox(height: 10,),

                Row(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 150,
                              decoration: BoxDecoration(
                                color: oTransparent,
                                border: Border.all(width: 0.4, color: oBlack),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Speed (km/h)",
                                    style: GoogleFonts.poppins(fontSize: 13,
                                        color: oBlack,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        minY: 0, // Min speed
                                        maxY: 200, // Max speed
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true, // Show speed values on the left
                                              reservedSize: 50, // Space for labels
                                              interval: 100, // Show labels at every 50 km/h (0, 50, 100, 150, 200)
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: oBlack,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                  textAlign: TextAlign.left,
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: speedData,
                                            isCurved: false,
                                            color: oGreen,
                                            barWidth: 1.5,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(show: false),
                                            dotData: FlDotData(show: false),
                                          ),
                                        ],
                                        extraLinesData: ExtraLinesData( //Adding the red speed limit line
                                          horizontalLines: [
                                            HorizontalLine(
                                              y: speedLimit, // Draw at 100 km/h
                                              color: oRedDark, // Red line for speed limit
                                              strokeWidth: 0.6,
                                            ),
                                          ],
                                        ),
                                        lineTouchData: LineTouchData(
                                          enabled: true,
                                          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                            return spotIndexes.map((index) {
                                              return const TouchedSpotIndicatorData(
                                                FlLine(
                                                  color: oGreen, // default vertical line indicator
                                                ),
                                                FlDotData(show: false),  // default dot indicator
                                              );
                                            }).toList();
                                          },
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipColor: (LineBarSpot touchedSpots) {
                                              // Set the tooltip color to white
                                              return oBlack;
                                            },
                                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                              return touchedSpots.map((touchedSpot) {
                                                return LineTooltipItem(
                                                    '${touchedSpot.y.toInt()} km/h',                                                  GoogleFonts.poppins(
                                                      color: oWhite,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      _buildLegend("Speed", oGreen),
                                      const Spacer(),
                                      _buildLegend("Speed limit", oRed),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.27,
                              height: 150,
                              decoration: BoxDecoration(
                                color: oTransparent,
                                border: Border.all(width: 0.4, color: oBlack),
                              ),
                              padding: const EdgeInsets.all(10),
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
                                  const SizedBox(height: 15,),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        minY: -2,
                                        maxY: 2,
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: 2, // Show -2, -1, 0, 1, 2
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: GoogleFonts.poppins(fontSize: 10, color: oBlack, fontWeight: FontWeight.w500),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // No X-axis labels
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          _buildLine(xValues, oBlueDark), // X-axis (Dark Blue)
                                          _buildLine(yValues, oBlueSky), // Y-axis (Sky Blue)
                                          _buildLine(zValues, oBlueLight), // Z-axis (Light Blue)
                                        ],
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

                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
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
                            )
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 150,
                              decoration: BoxDecoration(
                                color: oTransparent,
                                border: Border.all(width: 0.4, color: oBlack),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Power Regen/Consumption (kW)",
                                    style: GoogleFonts.poppins(fontSize: 13,
                                        color: oBlack,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        barGroups: barGroups,
                                        gridData: FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 50,
                                              interval: 50,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: GoogleFonts.poppins(fontSize: 10, color: oBlack, fontWeight: FontWeight.w500),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Removed bottom titles
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        minY: 0,
                                        maxY: 100, // Y-axis range from 0 to 100

                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipPadding: const EdgeInsets.all(8),
                                            tooltipRoundedRadius: 8,
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                              return BarTooltipItem(
                                                '${rod.toY.toInt()} kW',  // Custom tooltip text
                                                GoogleFonts.poppins(
                                                  color: oWhite,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      _buildLegend("Power Regeneration", oBlueDark),
                                      const Spacer(),
                                      _buildLegend("Power Consumption", oRed.withOpacity(0.6)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.27,
                              height: 150,
                              decoration: BoxDecoration(
                                color: oTransparent,
                                border: Border.all(width: 0.4, color: oBlack),
                              ),
                              padding: const EdgeInsets.all(10),
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
                                  const SizedBox(height: 15,),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        minY: -180,
                                        maxY: 180,
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: 180, // Show -2, -1, 0, 1, 2
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: GoogleFonts.poppins(fontSize: 10, color: oBlack, fontWeight: FontWeight.w500),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // No X-axis labels
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          _buildGyroLine(rollValues, oRed), // X-axis (Dark Blue)
                                          _buildGyroLine(pitchValues, oOrange), // Y-axis (Sky Blue)
                                          _buildGyroLine(yawValues, oYellow), // Z-axis (Light Blue)
                                        ],

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

                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
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
                                      _buildLegend("yaw", oYellow),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],

                    ),
                    const SizedBox(width: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.343,
                      height: 310,
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
                                    onPressed: _moveToCurrentLocation,
                                    icon: const Icon(Icons.my_location, size: 15, color: oBlack)
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                  initialCenter: _mapCenter,
                                  keepAlive: true
                              ),
                              children: [
                                TileLayer(
                                  //urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  //subdomains: ['a', 'b', 'c'],
                                  tileProvider: CancellableNetworkTileProvider(),
                                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _mapCenter,  // Position of the marker
                                      width: 10.0,
                                      height: 10.0,
                                      child: Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: const BoxDecoration(
                                          gradient: oBlueGradient2,
                                          shape: BoxShape.circle,
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
            ),

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

  Widget buildTirePressure(
      String tirePlace,
      int psi
      ){
    double maxPsi = 50.0; // Max PSI for scaling
    double filledWidth = (psi / maxPsi) * (MediaQuery.of(context).size.width * 0.12);
    return Row(
      children: [
        Text(
          tirePlace,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: oBlack,
              fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(width: 5,),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.10,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              width: filledWidth,
              height: 25,
              decoration: BoxDecoration(
                color: oGreen,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        const SizedBox(width: 5,),
        Text(
          "38",
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: oGreen,
              fontWeight: FontWeight.w500
          ),
        ),
      ],
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
