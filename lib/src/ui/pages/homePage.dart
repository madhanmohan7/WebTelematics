import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obdtelematics/src/ui/pages/userManagementPage.dart';
import 'package:svg_flutter/svg.dart';
import '../../utils/colors.dart';
import 'dashboardPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedMenuItem = "Dashboard"; // Default selected item
  bool isMenuVisible = false; // Toggle menu visibility

  // List of pages to display
  final Map<String, Widget> pages = {
    "Dashboard": const DashboardPage(),
    "User Management": const UserManagementPage(),
    "Settings": Center(child: Text("Settings Screen", style: TextStyle(fontSize: 20))),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oWhite,
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10),
        child: Column(
          children: [
            // Logo Row
            Row(
              children: [
                SvgPicture.asset(
                  "icons/obd_logo.svg",
                  width: 100,
                  height: 40,
                ),
                const Spacer(),
                Row(
                  children: [
                    Row(
                      children: [
                        // Menu Bar (Visible when isMenuVisible is true)
                        Visibility(
                          visible: isMenuVisible,
                          child: Container(
                            width: 445,
                            height: 45,
                            decoration: BoxDecoration(
                              color: oGrey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMenuItem("Dashboard"),
                                _buildMenuItem("User Management"),
                                _buildMenuItem("Settings"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Text(
                          "Menu Bar",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: oBlack,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                              color: oWhite,
                              shape: BoxShape.circle,
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
                            icon: SvgPicture.asset(
                              isMenuVisible ? "icons/hide.svg" : "icons/show.svg",
                              width: 25,
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                isMenuVisible ? oRedDark : oGreen,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isMenuVisible = !isMenuVisible;
                              });
                            },
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(width: 10,),

                    Tooltip(
                      message: "Profile",
                      textStyle: GoogleFonts.poppins(fontSize: 10, color: oWhite),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          gradient: oGreenGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            "icons/user.svg",
                            color: oWhite,
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),

            const SizedBox(height: 15,),
            // Display the Selected Screen
            Expanded(
              child: pages[selectedMenuItem]!,
            ),
          ],
        ),
      ),
    );
  }

  // Menu Item Widget
  Widget _buildMenuItem(String itemLabel) {
    bool isSelected = selectedMenuItem == itemLabel;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMenuItem = itemLabel;
        });
      },
      child: Container(
        width: 140,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? oGreen : oWhite,
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
