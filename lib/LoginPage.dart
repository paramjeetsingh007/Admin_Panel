import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

// AdminPanel screen ko import karein
// import 'admin_panel.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 173, 82, 82).withOpacity(0.5),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 0.2, color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 300, // Set the desired width here
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300, // Set the desired width here
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add email login functionality here
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 20),
              const Text("Login With"),
              const SizedBox(height: 20),
              SignInButtonBuilder(
                text: 'Sign in with Google',
                icon: Icons.g_mobiledata,
                iconColor: Colors.white,
                onPressed: () {
                  // Add Google login functionality here
                },
                backgroundColor: Colors.black,
                width: 160,
                height: 40,
                fontSize: 12,
              ),
              const SizedBox(height: 20),
              // Skip Login Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Admin Panel without login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPanel()),
                  );
                },
                child: const Text("Skip Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AdminPanel() {
}
