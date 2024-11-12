import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditTimecardScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  EditTimecardScreen({required this.employeeId, required this.employeeName});

  @override
  _EditTimecardScreenState createState() => _EditTimecardScreenState();
}

class _EditTimecardScreenState extends State<EditTimecardScreen> {
  List<Map<String, dynamic>> timecards = [];
  final DateFormat dateFormat = DateFormat.yMMMd();
  final DateFormat timeFormat = DateFormat.jm();

  @override
  void initState() {
    super.initState();
    _loadTimecards();
  }

  Future<void> _loadTimecards() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.employeeId)
          .collection('timecards')
          .get();

      List<Map<String, dynamic>> allRecords = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> records = data['records'] ?? [];

        for (var record in records) {
          allRecords.add(record as Map<String, dynamic>);
        }
      }

      setState(() {
        timecards = allRecords;
      });
    } catch (e) {
      print("Error loading timecards: $e");
    }
  }

  Future<void> _saveTimecard(int index) async {
    try {
      String monthKey = DateFormat('yyyy-MM').format(DateTime.parse(timecards[index]['date']));
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.employeeId)
          .collection('timecards')
          .doc(monthKey);

      await docRef.update({
        'records': timecards,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timecard updated successfully!')));
    } catch (e) {
      print("Error saving timecard: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving timecard: $e')));
    }
  }

  Future<void> _selectDate(int index) async {
    DateTime initialDate = DateTime.parse(timecards[index]['date']);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        timecards[index]['date'] = pickedDate.toIso8601String();
      });
    }
  }

  Future<void> _selectTime(int index, String key) async {
    TimeOfDay initialTime = TimeOfDay.fromDateTime(DateTime.parse(timecards[index][key]));
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      DateTime updatedDateTime = DateTime(
        initialTime.hour,
        initialTime.minute,
      );
      setState(() {
        timecards[index][key] = updatedDateTime.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Timecard for ${widget.employeeName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: timecards.isEmpty
            ? Center(child: Text("No timecards found for ${widget.employeeName}."))
            : ListView.builder(
          itemCount: timecards.length,
          itemBuilder: (context, index) {
            var timecard = timecards[index];
            DateTime timeIn = DateTime.parse(timecard['timeIn']);
            DateTime? timeOut = timecard['timeOut'] != null
                ? DateTime.parse(timecard['timeOut'])
                : null;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editable Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${dateFormat.format(timeIn)}'),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(index),
                        ),
                      ],
                    ),
                    // Editable Time In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time In: ${timeFormat.format(timeIn)}'),
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () => _selectTime(index, 'timeIn'),
                        ),
                      ],
                    ),
                    // Editable Time Out
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Out: ${timeOut != null ? timeFormat.format(timeOut) : 'Still clocked in'}',
                        ),
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: timeOut != null
                              ? () => _selectTime(index, 'timeOut')
                              : null,
                        ),
                      ],
                    ),
                    // Save Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _saveTimecard(index),
                        child: Text('Save Changes'),
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
