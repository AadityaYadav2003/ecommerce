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
  final TextEditingController confirmpasswordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  // email validator method
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  // date picker method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // register method
  void register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty ||
        dateOfBirthController.text.isEmpty ||
        mobileController.text.isEmpty ||
        usernameController.text.isEmpty) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://ecommercebackend-o2fv.onrender.com/user/register'),
        body: jsonEncode({
          "username": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "dob": dateOfBirthController.text,
          "mobile": mobileController.text,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
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

                    MyTextField(
                      hintText: "Username",
                      obscureText: false,
                      controller: usernameController,
                    ),
                    const SizedBox(height: 10),

                    // email text-field
                    MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController,
                    ),
                    const SizedBox(height: 10),

                    // mobile number text-field
                    MyTextField(
                      hintText: "Mobile No.",
                      obscureText: false,
                      controller: mobileController,
                    ),
                    const SizedBox(height: 10),

                    // date of birth text-field with date picker
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: MyTextField(
                          hintText: "Date of Birth",
                          obscureText: false,
                          controller: dateOfBirthController,
                        ),
                      ),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
