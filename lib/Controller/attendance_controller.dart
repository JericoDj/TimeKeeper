import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isClockedIn = false.obs;
  var timeIn = ''.obs;
  var timeOut = ''.obs;
  var pin = ''.obs; // Observable to store the user's PIN
  var userName = ''.obs; // Observable to store the user's name

  // Method to load attendance data, including the PIN and user name
  Future<void> loadAttendanceData() async {
    try {
      print("Loading attendance data..."); // Added for debugging
      User? user = _auth.currentUser;
      if (user == null) {
        print("No user is signed in."); // Added for debugging
        return;
      }

      // Fetch user data from the 'users' collection
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Load each field and update the observables
        isClockedIn.value = data['isClockedIn'] ?? false;
        timeIn.value = data['timeIn'] ?? '';
        timeOut.value = data['timeOut'] ?? '';
        pin.value = data['pin'] ?? '0000'; // Default to '0000' if no PIN is set
        userName.value = data['name'] ?? 'User'; // Correctly fetch the name from the 'users' document

        // Print all details to the console for debugging
        print("User name: ${userName.value}");
        print("Is Clocked In: ${isClockedIn.value}");
        print("Time In: ${timeIn.value}");
        print("Time Out: ${timeOut.value}");
        print("PIN: ${pin.value}");
      } else {
        print("No user data found for UID: ${user.uid}");
      }
    } catch (e) {
      print("Error loading attendance data: $e");
      Get.snackbar('Error', 'Failed to load attendance data: $e');
    }
  }

  // Other methods for clocking in, clocking out, and fetching timecards
  Future<void> savePin(String newPin) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'No user is signed in.');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'pin': newPin,
      }, SetOptions(merge: true)); // Merge with existing data

      pin.value = newPin;
      Get.snackbar('Success', 'PIN saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save PIN: $e');
    }
  }

  Future<void> clockIn() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'No user is signed in.');
        return;
      }

      DateTime now = DateTime.now();
      String monthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      Map<String, dynamic> record = {
        'timeIn': now.toIso8601String(),
        'timeOut': null,
        'date': now.toIso8601String().split('T')[0],
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('timecards')
          .doc(monthKey)
          .set(
        {
          'records': FieldValue.arrayUnion([record]),
        },
        SetOptions(merge: true),
      );

      isClockedIn.value = true;
      timeIn.value = now.toIso8601String();
      Get.snackbar('Success', 'Clocked in at ${DateFormat.jm().format(now)}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clock in: $e');
    }
  }

  Future<void> clockOut() async {
    try {
      User? user = _auth.currentUser;
      if (user == null || !isClockedIn.value) {
        Get.snackbar('Error', 'No user is signed in or not clocked in.');
        return;
      }

      DateTime now = DateTime.now();
      String monthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      DocumentReference docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('timecards')
          .doc(monthKey);

      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        List<dynamic> records = snapshot['records'] ?? [];

        for (var record in records.reversed) {
          if (record['timeOut'] == null) {
            record['timeOut'] = now.toIso8601String();
            break;
          }
        }

        await docRef.update({
          'records': records,
        });

        isClockedIn.value = false;
        timeOut.value = now.toIso8601String();
        Get.snackbar('Success', 'Clocked out at ${DateFormat.jm().format(now)}');
      } else {
        Get.snackbar('Error', 'No clock-in record found to clock out.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to clock out: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTimecardsForMonth(int month, int year) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return [];

      String monthKey = "$year-${month.toString().padLeft(2, '0')}";

      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('timecards')
          .doc(monthKey)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> records = data['records'] ?? [];
        return records.map((record) => record as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timecard data: $e');
      return [];
    }
  }

  // Method to fetch timecard entries for a specific employee for a specific month
  Future<List<Map<String, dynamic>>> fetchTimecardsForEmployeeMonth(String employeeId, int month, int year) async {
    try {
      // Format the month as "YYYY-MM"
      String monthKey = "$year-${month.toString().padLeft(2, '0')}";

      // Fetch the document for the specified month
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(employeeId)
          .collection('timecards')
          .doc(monthKey)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> records = data['records'] ?? [];
        return records.map((record) => record as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timecard data: $e');
      return [];
    }
  }
}
