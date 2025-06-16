import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';

import '../../models/userModel.dart';
import '../../utils/colors.dart';
import '../../utils/logger.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {

  final TextEditingController _searchController = TextEditingController();

  List<User> users = [
    User(name: "Ajitesh", email: "ajitesh.bms@jayemauto.com", mobile: "9876543210", team: "BMS Team", role: "Admin", username: "ajitesh", password: "pass@123"),
    User(name: "Madhan Mohan", email: "madhanmohan.thermal@jayemauto.com", mobile: "9876543211", team: "Thermal Team", role: "User", username: "madhan", password: "pass@123"),
    User(name: "Naveen", email: "naveen.bms@jayemauto.com", mobile: "9876543212", team: "BMS Team", role: "User", username: "naveen", password: "pass@123"),
    User(name: "Narayan Raju", email: "narayanraju.thermal@jayemauto.com", mobile: "9876543213", team: "Thermal Team", role: "User", username: "narayan", password: "pass@123"),
    User(name: "Harish", email: "harish.bms@jayemauto.com", mobile: "9876543214", team: "BMS Team", role: "User", username: "harish", password: "pass@123"),
  ];

  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  void _editUser(int index) {
    // Implement edit functionality (Open Dialog or New Screen)
  }

  void _addUser() {
    setState(() {
      users.add(User(
          name: "New User",
          email: "new@example.com",
          mobile: "9999999999",
          team: "BMS Team",
          role: "User",
          username: "newuser",
          password: "password"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "User Management",
                  style: GoogleFonts.poppins(
                      color: oBlack, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Container(
                      width: 300,
                      height: 40,
                      decoration: BoxDecoration(
                        //color: oWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5, color: oBlack)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Center(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search...",
                            hintStyle: GoogleFonts.poppins(
                              color: oBlack.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(CupertinoIcons.search, color: oBlack.withOpacity(0.7),size: 18,),
                          ),
                          style: GoogleFonts.poppins(
                            color: oBlack,
                            fontSize: 13,
                          ),
                          cursorColor: oBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    TextButton(
                      // onPressed: () {
                      //   LoggerUtil.getInstance.print("Add user button pressed");
                      //   _createUser(context);
                      // },
                      onPressed: _addUser,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(oBlack),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(const Size(110, 40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.add, size: 18, color: oWhite,),
                          const SizedBox(width: 5,),
                          Text(
                            "Add User",
                            style: GoogleFonts.poppins(
                              color: oWhite,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15,),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      //border: TableBorder.all(color: oBlack.withOpacity(0.5), width: 0.5),
      border: TableBorder(
        top: BorderSide(color: oBlack.withOpacity(0.5), width: 0.5),
        left: BorderSide(color: oBlack.withOpacity(0.5), width: 0.5),
        right: BorderSide(color: oBlack.withOpacity(0.5), width: 0.5),
        bottom: BorderSide(color: oBlack.withOpacity(0.5), width: 0.5),
        horizontalInside: const BorderSide(
          color: oBlack, // Row-dividing line color
          width: 0.1,
        ),
      ),
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(4),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(2),
        6: FlexColumnWidth(2),
        7: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _buildTableCell('S.No', isHeader: true),
          _buildTableCell('Username', isHeader: true),
          _buildTableCell('Name', isHeader: true),
          _buildTableCell('Email', isHeader: true),
          _buildTableCell('Team', isHeader: true),
          _buildTableCell('Role', isHeader: true),
          _buildTableCell('Mobile', isHeader: true),
          _buildTableCell('Actions', isHeader: true),
        ]),
        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return TableRow(children: [
            _buildTableCell('${index + 1}'),
            _buildTableCell(user.username),
            _buildTableCell(user.name),
            _buildTableCell(user.email),
            _buildTableCell(user.team),
            _buildTableCell(user.role),
            _buildTableCell(user.mobile),
            _buildActionCell(index),
          ]);
        }),
      ],
    );
  }

  Widget _buildTableCell(String content, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: oBlack,
        ),
      ),
    );
  }

  Widget _buildActionCell(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'icons/edit.svg',
            color: oBlue,
            width: 20.0,
            height: 20.0,
          ),
          onPressed: () => _editUser(index),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'icons/delete.svg',
            color: oRed,
            width: 20.0,
            height: 20.0,
          ),
          onPressed: () => _deleteUser(index),
        ),
      ],
    );
  }

}
