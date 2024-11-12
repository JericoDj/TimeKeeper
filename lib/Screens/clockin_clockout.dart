import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/attendance_controller.dart';

class ClockInOutScreen extends StatelessWidget {
  final AttendanceController attendanceController = Get.find();
  final TextEditingController pinController = TextEditingController();

  // Theme colors from your previous palette
  final Color primaryColor = Color(0xFF2b6777);
  final Color secondaryColor = Color(0xFFc8d8e4);
  final Color backgroundColor = Color(0xFFf2f2f2);
  final Color accentColor = Color(0xFF52ab98);
  final Color whiteColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    attendanceController.loadAttendanceData();

    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Clock In/Out',
          style: TextStyle(color: whiteColor, fontFamily: 'CustomFont'),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Image.asset(
                    'assets/logos/pixelcut-export.png',
                    height: 250, // Adjust height as needed
                    fit: BoxFit.contain, // Fit the image within the bounds
                  ),
                  Obx(() {
                    return Text(
                      attendanceController.isClockedIn.value
                          ? 'Clocked in at: ${attendanceController.timeIn.value}'
                          : 'You are not clocked in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    );
                  }),
                  SizedBox(height: 30),

                  // Clock In/Out Button
                  ElevatedButton(
                    onPressed: () async {
                      bool success = await _showPinDialog(context);
                      if (success) {
                        if (attendanceController.isClockedIn.value) {
                          attendanceController.clockOut();
                        } else {
                          attendanceController.clockIn();
                        }
                      }
                    },
                    child: Obx(() {
                      return Text(
                        attendanceController.isClockedIn.value ? 'Clock Out' : 'Clock In',
                        style: TextStyle(fontSize: 16),
                      );
                    }),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Forgot/Reset PIN Button
                  TextButton(
                    onPressed: () {
                      _showResetPinDialog(context);
                    },
                    child: Text(
                      'Forgot PIN / Reset PIN',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to show the PIN dialog
  Future<bool> _showPinDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text(
            'Enter your 4-digit PIN',
            style: TextStyle(color: primaryColor),
          ),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '****',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (pinController.text == attendanceController.pin.value) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect PIN'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  Navigator.of(context).pop(false);
                }
              },
              child: Text('Submit', style: TextStyle(color: primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  // Function to show the Reset PIN dialog
  void _showResetPinDialog(BuildContext context) {
    final TextEditingController newPinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text(
            'Reset your PIN',
            style: TextStyle(color: primaryColor),
          ),
          content: TextField(
            controller: newPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              hintText: 'Enter new 4-digit PIN',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newPinController.text.length == 4) {
                  attendanceController.savePin(newPinController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN reset successfully'),
                      backgroundColor: accentColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN must be 4 digits'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('Reset', style: TextStyle(color: primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
