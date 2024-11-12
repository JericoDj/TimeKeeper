import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Controller/auth_controller.dart';
import '../Models/account_model.dart';
import 'clockin_clockout.dart';
import 'timecard.dart';
import 'widgets/manager_dashboard.dart';

class MainScreen extends StatelessWidget {
  final AuthController authController = AuthController(); // Removed Get.find()

  // Define colors from your palette
  final Color primaryColor = Color(0xFF2b6777);
  final Color secondaryColor = Color(0xFFc8d8e4);
  final Color backgroundColor = Color(0xFFf2f2f2);
  final Color accentColor = Color(0xFF52ab98);
  final Color whiteColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time Keeper',
          style: TextStyle(color: whiteColor, fontFamily: 'CustomFont'),
        ),
        centerTitle: true,
        backgroundColor: primaryColor, // Set AppBar color to primary
        elevation: 0, // Remove shadow for a cleaner look
      ),
      backgroundColor: backgroundColor, // Set background color
      body: Align(
        alignment: Alignment.topCenter,
        child: FutureBuilder<AccountType?>(
          future: authController.getCurrentUserAccountType(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor)); // Loading indicator in primary color
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Error retrieving account type',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }

            final accountType = snapshot.data;

            return Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 600,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Image.asset(
                      'assets/logos/pixelcut-export.png',
                      height: 250, // Adjust height as needed
                      fit: BoxFit.contain, // Fit the image within the bounds
                    ),
                    //                     // Updated Descriptive Message
                    Text(
                      'Effortless Attendance Tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8), // Adding space between the title and description
                    Text(
                      'Your ultimate solution for tracking employee attendance, simplifying records for managers, and ensuring data accuracy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, // Adjust the font size as needed
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Clock In/Out Button
                    if (accountType == AccountType.manager || accountType == AccountType.contractor)
                      ElevatedButton(
                        onPressed: () {
                          context.go('/clockin-clockout'); // Use GoRouter
                        },
                        child: Text('Clock In/Out'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteColor, backgroundColor: primaryColor, // White text
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),

                    // Manager Dashboard Button
                    if (accountType == AccountType.manager)
                      ElevatedButton(
                        onPressed: () {
                          context.go('/manager-dashboard'); // Use GoRouter
                        },
                        child: Text('Manager Dashboard'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteColor, backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),

                    // View Timecard Button
                    if (accountType == AccountType.manager || accountType == AccountType.contractor)
                      ElevatedButton(
                        onPressed: () {
                          context.go('/timecard'); // Use GoRouter
                        },
                        child: Text('View Timecard'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteColor, backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),

                    // Message for Customer
                    if (accountType == AccountType.customer)
                      Center(
                        child: Text(
                          'You only have view permissions',
                          style: TextStyle(
                            color: secondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                    // Sign Out Button
                    ElevatedButton(
                      onPressed: () {
                        authController.signOut(context);
                      },
                      child: Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: whiteColor, backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
