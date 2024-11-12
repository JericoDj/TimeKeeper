import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimecardController {
  final String employeeId;
  final String employeeName;
  List<Map<String, dynamic>> timecards = [];
  int? editingIndex;
  bool isAdding = false;
  TextEditingController dateController = TextEditingController();
  TextEditingController timeInController = TextEditingController();
  TextEditingController timeOutController = TextEditingController();
  DateTime selectedMonth = DateTime(2024, 1);

  TimecardController({required this.employeeId, required this.employeeName});

  DateTime getInitialSelectedMonth() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  Future<void> loadTimecards(Function setStateCallback) async {
    try {
      String monthKey = DateFormat('yyyy-MM').format(selectedMonth);

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(employeeId)
          .collection('timecards')
          .doc(monthKey)
          .get();

      List<Map<String, dynamic>> allRecords = [];

      if (snapshot.exists) {
        List<dynamic> records = snapshot['records'] ?? [];
        for (var record in records) {
          allRecords.add(record as Map<String, dynamic>);
        }
      }

      // Sort the records from earliest to latest
      allRecords.sort((a, b) {
        DateTime dateA = DateTime.parse(a['timeIn']);
        DateTime dateB = DateTime.parse(b['timeIn']);
        return dateA.compareTo(dateB);
      });

      setStateCallback(() {
        timecards = allRecords;
      });
    } catch (e) {
      print("Error loading timecards: $e");
    }
  }

  List<DropdownMenuItem<DateTime>> generateMonthDropdownItems() {
    List<DropdownMenuItem<DateTime>> items = [];
    DateTime currentDate = DateTime(2024, 1);
    DateTime now = DateTime.now();

    // Generate months from January 2024 to the current month
    while (currentDate.isBefore(DateTime(now.year, now.month + 1))) {
      items.add(DropdownMenuItem(
        value: currentDate,
        child: Text(DateFormat.yMMM().format(currentDate)),
      ));
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Sort items from latest to earliest
    items.sort((a, b) => b.value!.compareTo(a.value!));
    return items;
  }

  void showDeleteConfirmationDialog(
      BuildContext context, int index, Function(int) deleteCallback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this timecard?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteCallback(index);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTimecard(
      BuildContext context, int index, Function setStateCallback) async {
    try {
      DateTime timeIn = DateTime.parse(timecards[index]['timeIn']);
      String monthKey = DateFormat('yyyy-MM').format(timeIn);

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(employeeId)
          .collection('timecards')
          .doc(monthKey);

      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<dynamic> records = List.from(docSnapshot['records']);
        records.removeWhere((record) =>
        record['timeIn'] == timecards[index]['timeIn'] &&
            record['timeOut'] == timecards[index]['timeOut']);
        await docRef.update({'records': records});
      }

      setStateCallback(() {
        timecards.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timecard deleted successfully!')),
      );
    } catch (e) {
      print("Error deleting timecard: $e");
    }
  }

  void startEditing(int index, Function setStateCallback) {
    var timecard = timecards[index];
    DateTime timeIn = DateTime.parse(timecard['timeIn']);
    DateTime? timeOut = timecard['timeOut'] != null
        ? DateTime.parse(timecard['timeOut'])
        : null;

    setStateCallback(() {
      editingIndex = index;
      dateController.text = DateFormat('MMM d, yyyy').format(timeIn);
      timeInController.text = DateFormat('h:mm a').format(timeIn);
      timeOutController.text =
      timeOut != null ? DateFormat('h:mm a').format(timeOut) : 'N/A';
    });
  }

  Future<void> saveTimecard(BuildContext context, int index, Function setStateCallback) async {
    try {
      DateTime date = DateFormat('MMM d, yyyy').parse(dateController.text);

      // Parse Time In
      TimeOfDay timeInTimeOfDay = TimeOfDay(
        hour: int.parse(timeInController.text.split(':')[0]),
        minute: int.parse(timeInController.text.split(':')[1].split(' ')[0]),
      );
      DateTime timeIn = DateTime(
        date.year,
        date.month,
        date.day,
        timeInTimeOfDay.hour,
        timeInTimeOfDay.minute,
      );

      // Parse Time Out
      DateTime? timeOut;
      if (timeOutController.text != 'N/A') {
        TimeOfDay timeOutTimeOfDay = TimeOfDay(
          hour: int.parse(timeOutController.text.split(':')[0]),
          minute: int.parse(timeOutController.text.split(':')[1].split(' ')[0]),
        );
        timeOut = DateTime(
          date.year,
          date.month,
          date.day,
          timeOutTimeOfDay.hour,
          timeOutTimeOfDay.minute,
        );
      }

      // Save or update the timecard
      timecards[index]['timeIn'] = timeIn.toIso8601String();
      timecards[index]['timeOut'] = timeOut?.toIso8601String();

      setStateCallback(() {
        editingIndex = null;
      });

      // Save to Firestore
      String monthKey = DateFormat('yyyy-MM').format(timeIn);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employeeId)
          .collection('timecards')
          .doc(monthKey)
          .update({'records': timecards});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timecard updated successfully!')),
      );
    } catch (e) {
      print("Error saving timecard: $e");
    }
  }


  Future<void> addNewTimecard(
      BuildContext context, Function setStateCallback) async {
    try {
      DateTime date = DateFormat('MMM d, yyyy').parse(dateController.text);
      TimeOfDay timeInTimeOfDay = TimeOfDay(
        hour: int.parse(timeInController.text.split(':')[0]),
        minute: int.parse(timeInController.text.split(':')[1].split(' ')[0]),
      );
      DateTime timeIn = DateTime(date.year, date.month, date.day,
          timeInTimeOfDay.hour, timeInTimeOfDay.minute);

      DateTime? timeOut;
      if (timeOutController.text != 'N/A') {
        TimeOfDay timeOutTimeOfDay = TimeOfDay(
          hour: int.parse(timeOutController.text.split(':')[0]),
          minute: int.parse(timeOutController.text.split(':')[1].split(' ')[0]),
        );
        timeOut = DateTime(date.year, date.month, date.day,
            timeOutTimeOfDay.hour, timeOutTimeOfDay.minute);
      }

      String monthKey = DateFormat('yyyy-MM').format(timeIn);
      Map<String, dynamic> newTimecard = {
        'timeIn': timeIn.toIso8601String(),
        'timeOut': timeOut?.toIso8601String(),
      };

      setStateCallback(() {
        timecards.add(newTimecard);
        isAdding = false;
      });

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(employeeId)
          .collection('timecards')
          .doc(monthKey);

      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<dynamic> records = List.from(docSnapshot['records']);
        records.add(newTimecard);
        await docRef.update({'records': records});
      } else {
        await docRef.set({'records': [newTimecard]});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timecard added successfully!')),
      );
    } catch (e) {
      print("Error adding new timecard: $e");
    }
  }
}
