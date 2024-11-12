import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Controller/timecard_controller.dart';

class ViewTimecardScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  ViewTimecardScreen({required this.employeeId, required this.employeeName});

  @override
  _ViewTimecardScreenState createState() => _ViewTimecardScreenState();
}

class _ViewTimecardScreenState extends State<ViewTimecardScreen> {
  final Color backgroundColor = Color(0xFFf2f2f2);
  late TimecardController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = TimecardController(
      employeeId: widget.employeeId,
      employeeName: widget.employeeName,
    );
    controller.selectedMonth = controller.getInitialSelectedMonth();
    controller.loadTimecards(setState).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<DateTime>> monthItems = controller.generateMonthDropdownItems();
    if (!monthItems.any((item) => item.value == controller.selectedMonth)) {
      controller.selectedMonth = monthItems.first.value!;
    }
    final Color whiteColor = Color(0xFFFFFFFF);

    // Helper function to split timecards into chunks of 7 for row-wise display
    List<List<Map<String, dynamic>>> splitTimecards(List<Map<String, dynamic>> timecards) {
      List<List<Map<String, dynamic>>> chunks = [];
      for (int i = 0; i < timecards.length; i += 7) {
        int end = (i + 7 < timecards.length) ? i + 7 : timecards.length;
        chunks.add(timecards.sublist(i, end));
      }
      return chunks;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Timecard",
          style: TextStyle(color: whiteColor,fontFamily: 'CustomFont'),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2b6777), // Your primary color
      ),
      backgroundColor: backgroundColor, // Set background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Employee name display
            Text(
              "Name: ${widget.employeeName}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2b6777), // Your primary color
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select Month:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20 ,),
                Container(
                  width: 200, // Adjust the width to your preference
                  decoration: BoxDecoration(
                    color: backgroundColor, // Set a white background for the dropdown
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    border: Border.all(color: Colors.grey.shade400), // Border color for the dropdown
                  ),
                  child: DropdownButtonHideUnderline( // Hide the default underline
                    child: DropdownButton<DateTime>(
                      value: controller.selectedMonth,
                      isExpanded: true, // Make sure the dropdown expands to fill the width
                      onChanged: (DateTime? newValue) {
                        if (newValue != null) {
                          setState(() {
                            controller.selectedMonth = newValue;
                            isLoading = true;
                          });
                          controller.loadTimecards(setState).then((_) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        }
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade700, // Icon color for better visibility
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Text color for the dropdown items
                      ),
                      dropdownColor: backgroundColor, // Background color for the dropdown menu
                      items: monthItems, // Your list of DropdownMenuItems
                    ),
                  ),
                )

              ],
            ),
            SizedBox(height: 20),
            // Display loading indicator or timecards
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (controller.timecards.isEmpty)
              Center(
                child: Text(
                  "No timecards found for ${widget.employeeName}.",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(

                  child: Wrap(
                    spacing: 16.0, // Space between tables
                    runSpacing: 16.0, // Space between rows of tables
                    children: splitTimecards(controller.timecards).map((chunk) {
                      return Container(
                        width: 350, // Adjust the width as needed
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
                            1: FlexColumnWidth(0.15),
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
                            ...chunk.map((timecard) {
                              DateTime timeIn = DateTime.parse(timecard['timeIn']);
                              DateTime? timeOut = timecard['timeOut'] != null
                                  ? DateTime.parse(timecard['timeOut'])
                                  : null;

                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat.yMMMd().format(timeIn)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat.jm().format(timeIn)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          timeOut != null ? DateFormat.jm().format(timeOut) : 'N/A',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit, size: 18, color: Color(0xFF2b6777)),
                                          onPressed: () {
                                            int index = controller.timecards.indexOf(timecard);
                                            controller.startEditing(index, setState);
                                          },
                                        ),
                                      ],
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
            SizedBox(height: 20),
            // Add Date button
            if (controller.isAdding || controller.editingIndex != null)
              _buildTimecardForm()
            else
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      controller.isAdding = true;
                      controller.dateController.clear();
                      controller.timeInController.clear();
                      controller.timeOutController.clear();

                    });
                  },
                  child: Text("Add Date", style: TextStyle(color: whiteColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF52ab98), // Your secondary color
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimecardForm() {
    return Container(

      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.dateController,
            decoration: InputDecoration(labelText: 'Date'),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                controller.dateController.text = DateFormat('MMM d, yyyy').format(picked);
              }
            },
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  controller.timeInController.text = picked.format(context);
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: controller.timeInController,
                decoration: InputDecoration(
                  labelText: 'Time In',
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  controller.timeOutController.text = picked.format(context);
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: controller.timeOutController,
                decoration: InputDecoration(
                  labelText: 'Time Out',
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.isAdding
                ? () => controller.addNewTimecard(context, setState)
                : () {
              if (controller.editingIndex != null) {
                controller.saveTimecard(
                  context,
                  controller.editingIndex!,
                  setState,
                );
              }
            },
            child: Text(controller.isAdding ? "Add Timecard" : "Save Changes",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF52ab98),
            ),
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              setState(() {
                controller.editingIndex = null;
                controller.isAdding = false;
              });
            },
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
