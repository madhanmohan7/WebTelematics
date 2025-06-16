import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obdtelematics/src/utils/colors.dart';

import 'liveData.dart';
import 'postAnalysis.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedDataAnalysis = "Live Data"; // Default selected item

  // List of pages to display
  final Map<String, Widget> pages = {
    "Live Data": const LivedataAnalysis(),
    "Post Analysis": const PostDataAnalysis(),
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 300,
              height: 45,
              decoration: BoxDecoration(
                color: oGrey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDataAnalysis("Live Data"),
                  _buildDataAnalysis("Post Analysis")
                ],
              ),
            ),
        
            const SizedBox(height: 15,),
            // Display the Selected Screen
            pages[selectedDataAnalysis]!,
          ],
        ),
      ),
    );
  }

  // Menu Item Widget
  Widget _buildDataAnalysis(String itemLabel) {
    bool isSelected = selectedDataAnalysis == itemLabel;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDataAnalysis = itemLabel;
        });
      },
      child: Container(
        width: 140,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? oBlueDark : oWhite,
          borderRadius: BorderRadius.circular(10),
          //border: Border.all(color: oBlack, width: 0.5),
        ),
        child: Center(
          child: Text(
            itemLabel,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? oWhite : oBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
