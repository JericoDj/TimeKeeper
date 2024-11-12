import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'view_and_edit.dart';

class ManagerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manager Dashboard', style: TextStyle(color: Colors.white, fontFamily: 'CustomFont'),),
          centerTitle: true,
          backgroundColor: Color(0xFF2b6777), // Primary color from your palette
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 600,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found.'));
                }

                List<DocumentSnapshot> users = snapshot.data!.docs;
                List<DocumentSnapshot> contractors = users
                    .where((user) => user['accountType'] == 'contractor')
                    .toList();
                List<DocumentSnapshot> managers = users
                    .where((user) => user['accountType'] == 'manager')
                    .toList();
                List<DocumentSnapshot> customers = users
                    .where((user) => user['accountType'] == 'customer')
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserSection('Contractors', contractors, context),
                      SizedBox(height: 20),
                      _buildUserSection('Managers', managers, context),
                      SizedBox(height: 20),
                      _buildUserSection('Customers', customers, context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(String title, List<DocumentSnapshot> users, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2b6777), // Primary color from your palette
          ),
        ),
        SizedBox(height: 10),
        users.isEmpty
            ? Text(
          'No $title found.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        )
            : Container(
          decoration: BoxDecoration(
            color: Color(0xFFc8d8e4), // Secondary background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: users.map((user) {
              String employeeId = user.id;
              String employeeName = user['name'] ?? 'Unknown Name';
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    employeeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2b6777), // Primary color for text
                    ),
                  ),
                  subtitle: Text(
                    'Account Type: ${user['accountType'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View Timecard Button
                      TextButton(
                        onPressed: () {
                          Get.to(() => ViewTimecardScreen(
                            employeeId: employeeId,
                            employeeName: employeeName,
                          ));
                        },
                        child: Text(
                          'View Timecard',
                          style: TextStyle(color: Color(0xFF52ab98)), // Accent color
                        ),
                      ),
                      // Edit Timecard Button

                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
