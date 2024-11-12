import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For using ScaffoldMessenger
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../Models/account_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isSignedIn = false.obs;

  AuthController() {
    // Listen to authentication state changes and update `isSignedIn`
    _auth.authStateChanges().listen((User? user) {
      isSignedIn.value = user != null;
    });
  }

  // Method to create an account
  Future<void> createAccount(
      String email, String password, String name, AccountType accountType, BuildContext context) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a new UserAccount object
      UserAccount userAccount = UserAccount(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        accountType: accountType,
      );

      // Save the user account information to Firestore
      await _firestore.collection('users').doc(userAccount.uid).set(userAccount.toFirestore());

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
          ,backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating, // Makes the SnackBar float
          margin: EdgeInsets.only(top: 50, left: 16, right: 16), // Adjust the top margin

        ),
      );

      // Navigate to the home screen or dashboard (example using Get)
      context.go('/home'); // Replace '/home' with your home route
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Method to sign in
  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      // Sign in the user with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating, // Makes the SnackBar float
            margin: EdgeInsets.only(top: 50, left: 16, right: 16), // Adjust the top margin)
        )
      );

      // Navigate to the home screen or dashboard (example using Get)
      context.go('/home'); // Replace '/home' with your home route
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Method to sign out
  Future<void> signOut(BuildContext context) async {
    try {
      // Sign out the user
      await _auth.signOut();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed out successfully',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)

          ,backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating, // Makes the SnackBar float
          margin: EdgeInsets.only(top: 50, left: 16, right: 16), // Adjust the top margin
        ),
      );

      // Navigate to the sign-in screen (example using Get)
      context.go('/'); // Replace '/' with your sign-in route
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Method to get the current user's account type
  Future<AccountType?> getCurrentUserAccountType() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Convert the Firestore data to a UserAccount object and return the account type
        return UserAccount.fromFirestore(userDoc.data() as Map<String, dynamic>, user.uid).accountType;
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error fetching account type: $e');
      return null;
    }
  }
}
