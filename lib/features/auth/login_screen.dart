import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PulseUp", style: TextStyle(fontSize: 32)),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                var url = Uri.parse("http://192.168.100.62/login.php");

                var response = await http.post(url, body: {
                  "email": emailController.text,
                  "password": passwordController.text,
                });

                var data = jsonDecode(response.body);

                if (data["status"] == "ok") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login failed")),
                  );
                }
              },
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}