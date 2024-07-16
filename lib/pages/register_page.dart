import 'dart:convert';
import 'package:ecommerce/components/my_button.dart';
import 'package:ecommerce/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  String? _errorMessage;

  // email validator method
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  // register method
  void register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (!isValidEmail(emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://ecommercebackend-o2fv.onrender.com/user/register'),
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login_page');
      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),

                // app name
                const Text(
                  "M I N I M A L",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 50),

                // email text-field
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        hintText: "Email",
                        obscureText: false,
                        controller: emailController,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),

                // password text-field
                MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 10),

                // confirm password text-field
                MyTextField(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmpasswordController,
                ),
                const SizedBox(height: 10),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                // register button
                MyButton(
                  text: "Register",
                  onTap: register,
                  child: const Text("Register"),
                ),
                const SizedBox(height: 25),

                // already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?    ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login_page'),
                      child: const Text(
                        "Login Here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
