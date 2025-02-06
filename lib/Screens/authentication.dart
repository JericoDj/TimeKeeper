import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import '../Controller/auth_controller.dart';
import '../Models/account_model.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController authController = AuthController(); // Removed Get.find()
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  AccountType selectedAccountType = AccountType.contractor;
  bool isCreatingAccount = false;

  // Define your color palette
  final Color primaryColor = Color(0xFF2b6777);
  final Color secondaryColor = Color(0xFFc8d8e4);
  final Color accentColor = Color(0xFF52ab98);
  final Color backgroundColor = Color(0xFFf2f2f2);
  final Color whiteColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'TimeKeeper',
          style: TextStyle(color: whiteColor, fontFamily: 'CustomFont'),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/pixelcut-export.png',
                    height: 250, // Adjust height as needed
                    fit: BoxFit.contain, // Fit the image within the bounds
                  ),
                  Text(
                    isCreatingAccount ? 'Create Your Account' : 'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentColor),
                      ),
                    ),
                    obscureText: true,
                  ),
                  if (isCreatingAccount)
                    Column(
                      children: [
                        SizedBox(height: 10),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: 400,
                          decoration: BoxDecoration(
                            color: backgroundColor, // Set background color for the dropdown
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                            border: Border.all(color: Colors.grey.shade400), // Border color
                          ),
                          child: DropdownButtonHideUnderline( // Hides the default underline
                            child: DropdownButton<AccountType>(
                              value: selectedAccountType,
                              onChanged: (AccountType? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedAccountType = newValue;
                                  });
                                }
                              },
                              dropdownColor: secondaryColor,
                              isExpanded: true, // Ensure the dropdown expands fully
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: primaryColor,
                                size: 24,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              items: AccountType.values.map((AccountType accountType) {
                                return DropdownMenuItem<AccountType>(
                                  value: accountType,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Add horizontal and vertical padding
                                    child: Text(
                                      accountType.toString().split('.').last,
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )

                      ],
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (isCreatingAccount) {
                        authController.createAccount(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                          selectedAccountType,
                          context,
                        );
                      } else {
                        authController.signIn(
                          emailController.text,
                          passwordController.text,
                          context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: whiteColor,
                      padding: EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32), // Adjusted padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isCreatingAccount ? 'Create Account' : 'Sign In',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Forgot Password Button (use GoRouter)
                  TextButton(
                    onPressed: () {
                      context.push('/forgot-password'); // Use GoRouter
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isCreatingAccount = !isCreatingAccount;
                      });
                    },
                    child: Text(
                      isCreatingAccount
                          ? 'Already have an account? Sign In'
                          : 'Don’t have an account? Create one',
                      style: TextStyle(color: primaryColor),
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
}

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final Color primaryColor = Color(0xFF2b6777);
  final Color accentColor = Color(0xFF52ab98);
  final Color whiteColor = Color(0xFFFFFFFF);
  final Color backgroundColor = Color(0xFFf2f2f2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Forgot Password',
          style: TextStyle(color: whiteColor, fontFamily: 'CustomFont'),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,

      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/logos/pixelcut-export.png',
                  height: 250, // Adjust height as needed
                  fit: BoxFit.contain, // Fit the image within the bounds
                ),
                Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    labelStyle: TextStyle(color: primaryColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: emailController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Password reset email sent!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: accentColor,
                          behavior: SnackBarBehavior.floating,
                          // Makes the SnackBar float
                          margin: EdgeInsets.only(top: 50, left: 16, right: 16), // Adjust the top margin
                        ),
                      );

                      context.push('/');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: whiteColor,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Send Password Reset Email',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
