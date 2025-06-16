import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/userModel.dart';
import '../../utils/colors.dart';
import '../../utils/logger.dart';
import '../../utils/routes/route_names.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = true;

  // Dummy user list
  List<User> users = [
    User(name: "Ajitesh", email: "ajitesh.bms@jayemauto.com", mobile: "9876543210", team: "BMS Team", role: "Admin", username: "ajitesh", password: "pass@123"),
    User(name: "Madhan Mohan", email: "madhanmohan.thermal@jayemauto.com", mobile: "9876543211", team: "Thermal Team", role: "User", username: "madhan", password: "pass@123"),
    User(name: "Naveen", email: "naveen.bms@jayemauto.com", mobile: "9876543212", team: "BMS Team", role: "User", username: "naveen", password: "pass@123"),
    User(name: "Narayan Raju", email: "narayanraju.thermal@jayemauto.com", mobile: "9876543213", team: "Thermal Team", role: "User", username: "narayan", password: "pass@123"),
    User(name: "Harish", email: "harish.bms@jayemauto.com", mobile: "9876543214", team: "BMS Team", role: "User", username: "harish", password: "pass@123"),
  ];

  void _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    User? authenticatedUser = users.firstWhere(
          (user) => user.username == username && user.password == password,
      orElse: () => User(name: "", email: "", mobile: "", team: "", role: "", username: "", password: ""),
    );

    if (authenticatedUser.username.isNotEmpty) {
      LoggerUtil.getInstance.print("Login successful: ${authenticatedUser.username}");

      // Store session details
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", authenticatedUser.username);
      prefs.setString("role", authenticatedUser.role);

      // Show Success Alert
      _showSuccessDialog(authenticatedUser);

    } else {
      // Show Failure Alert
      _showFailureDialog();
    }
  }

// Success Dialog
  void _showSuccessDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.check_mark_circled_solid, color: oGreen, size: 80),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${user.name}!",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: oBlack,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You have successfully logged in \nas ${user.role}.",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: oBlack,
                    fontWeight: FontWeight.w400
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Navigate based on role
                  if (user.role == "Admin") {
                    Navigator.pushReplacementNamed(context, RouteNames.homePage);
                  } else {
                    Navigator.pushReplacementNamed(context, RouteNames.homePage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: oGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  fixedSize: const Size(150, 40)
                ),
                child: Text("Continue", style: GoogleFonts.poppins(color: oWhite, fontSize: 15)),
              ),
            ],
          ),
        );
      },
    );
  }

// Failure Dialog
  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.exclamationmark_circle_fill, color: oRedDark, size: 80),
              const SizedBox(height: 20),
              Text(
                "Login Failed",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: oBlack,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Invalid Username or Password.\nPlease try again.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: oBlack,
                    fontWeight: FontWeight.w400
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: oRedDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  fixedSize: const Size(150, 40)
                ),
                child: Text("Try Again", style: GoogleFonts.poppins(color: oWhite, fontSize: 14)),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get screen width
          double screenWidth = constraints.maxWidth;
          double containerWidth = screenWidth < 600
              ? screenWidth * 0.9 // Mobile
              : screenWidth < 1200
              ? screenWidth * 0.5 // Tablet
              : screenWidth * 0.35; // Desktop

          double fontSize = screenWidth < 600 ? 25 : 30; // Adjust text size
          double inputFontSize = screenWidth < 600 ? 12 : 13;

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'images/bg5.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              Center(
                child: Container(
                  width: containerWidth.clamp(300, 500), // Min 300px, Max 500px
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 600 ? 20 : 30,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: oWhite.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: oBlack.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's Login\nData Log Portal",
                        style: GoogleFonts.poppins(
                          color: oBlack,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Kindly provide your registered username and "
                            "a working password in the blanks below.",
                        style: GoogleFonts.poppins(
                          color: oBlack,
                          fontSize: inputFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Username Field
                      _buildInputField(
                        label: "Username",
                        controller: _usernameController,
                        icon: CupertinoIcons.person,
                        isPassword: false,
                        fontSize: inputFontSize,
                      ),
                      const SizedBox(height: 15),

                      // Password Field
                      _buildInputField(
                        label: "Password",
                        controller: _passwordController,
                        icon: Icons.password_rounded,
                        isPassword: true,
                        fontSize: inputFontSize,
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            // onPressed: () {
                            //   LoggerUtil.getInstance.print("Login button pressed");
                            //   Navigator.pushReplacementNamed(context, RouteNames.homePage);
                            //
                            // },
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: oBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Log In",
                              style: GoogleFonts.poppins(
                                color: oWhite,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Text
                      Center(
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "© 2025 ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: oBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Data Log Solutions",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: oBlueDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ". All rights reserved based on",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: oBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Terms and Conditions Page
                                LoggerUtil.getInstance.print("Terms and Conditions Clicked");
                              },
                              child: Text(
                                "Terms & Conditions",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: oBlueDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Reusable Input Field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isPassword,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$label ",
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: oBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: oRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? isPasswordVisible : false,
          cursorColor: oBlack,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: oBlack,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: oBlack, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: oBlack, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: oRed, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: oRed),
              borderRadius: BorderRadius.circular(15),
            ),
            prefixIcon: Icon(icon, color: oBlack.withOpacity(0.35), size: 20),
            suffixIcon: isPassword
                ? IconButton(
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              icon: Icon(
                isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: oBlack.withOpacity(0.35),
                size: 20,
              ),
            )
                : null,
            hintText: label,
            hintStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              color: oBlack.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
