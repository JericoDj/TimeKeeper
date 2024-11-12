import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Controller/attendance_controller.dart';

class TimecardScreen extends StatefulWidget {
  @override
  _TimecardScreenState createState() => _TimecardScreenState();
}

class _TimecardScreenState extends State<TimecardScreen> {
  final Color backgroundColor = Color(0xFFf2f2f2);
  final AttendanceController attendanceController = Get.find();
  List<Map<String, dynamic>> timecards = [];
  DateTime selectedDate = DateTime.now();
  List<DropdownMenuItem<DateTime>> monthItems = [];

  @override
  void initState() {
    super.initState();
    attendanceController.loadAttendanceData();
    monthItems = _generateMonthDropdownItems();

    if (!monthItems.any((item) => item.value == selectedDate)) {
      selectedDate = monthItems.first.value!;
    }

    _loadTimecards();
  }

  Future<void> _loadTimecards() async {
    int month = selectedDate.month;
    int year = selectedDate.year;
    List<Map<String, dynamic>> data = await attendanceController.fetchTimecardsForMonth(month, year);

    data.sort((a, b) {
      DateTime dateA = DateTime.parse(a['timeIn']);
      DateTime dateB = DateTime.parse(b['timeIn']);
      return dateA.compareTo(dateB);
    });

    setState(() {
      timecards = data;
    });
  }

  List<DropdownMenuItem<DateTime>> _generateMonthDropdownItems() {
    List<DropdownMenuItem<DateTime>> items = [];
    DateTime currentDate = DateTime.now();
    DateTime startMonth = DateTime(2024, 1);

    while (currentDate.isAfter(DateTime(startMonth.year, startMonth.month - 1))) {
      items.add(DropdownMenuItem(
        value: currentDate,
        child: Text(DateFormat.yMMM().format(currentDate)),
      ));
      currentDate = DateTime(currentDate.year, currentDate.month - 1);
    }

    return items;
  }

  List<List<Map<String, dynamic>>> splitTimecards(List<Map<String, dynamic>> timecards) {
    List<List<Map<String, dynamic>>> chunks = [];
    for (int i = 0; i < timecards.length; i += 7) {
      int end = (i + 7 < timecards.length) ? i + 7 : timecards.length;
      chunks.add(timecards.sublist(i, end));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Timecard", style: TextStyle(color: backgroundColor, fontFamily: 'CustomFont')),
        backgroundColor: Color(0xFF2b6777),
      ),
      backgroundColor: backgroundColor, // Set background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              return Text(
                "Name: ${attendanceController.userName.value}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2b6777),
                ),
              );
            }),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select Month:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Container(
                  width: 150, // Set the width as needed
                  decoration: BoxDecoration(
                    color: backgroundColor, // Background color for the dropdown
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    border: Border.all(color: Colors.grey.shade400), // Border color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Subtle shadow color
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline( // Hides the default underline
                    child: DropdownButton<DateTime>(
                      alignment: Alignment.center,
                      value: selectedDate,
                      items: monthItems,
                      isExpanded: true, // Ensure the dropdown expands fully
                      onChanged: (DateTime? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDate = newValue;
                          });
                          _loadTimecards();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade700, // Customize icon color
                        size: 24, // Icon size
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Text color
                        fontWeight: FontWeight.w600, // Font weight for better readability
                      ),
                      dropdownColor: backgroundColor, // Dropdown menu background color
                    ),
                  ),
                )


              ],
            ),
            SizedBox(height: 20),
            if (timecards.isEmpty)
              Center(
                child: Text(
                  "No records found for this month",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: splitTimecards(timecards).map((chunk) {
                      return Container(
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columnWidths: {
                            0: FlexColumnWidth(0.2),
                            1: FlexColumnWidth(0.2),
                            2: FlexColumnWidth(0.2),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFFc8d8e4),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2b6777),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Time In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2b6777),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Time Out",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2b6777),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...chunk.map((entry) {
                              DateTime timeIn = DateTime.parse(entry['timeIn']);
                              DateTime? timeOut = entry['timeOut'] != null
                                  ? DateTime.parse(entry['timeOut'])
                                  : null;

                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      DateFormat.yMMMd().format(timeIn),
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      DateFormat.jm().format(timeIn),
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      timeOut != null ? DateFormat.jm().format(timeOut) : 'N/A',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
