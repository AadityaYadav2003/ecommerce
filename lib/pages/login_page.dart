import 'dart:convert';
import 'package:ecommerce/components/my_button.dart';
import 'package:ecommerce/components/my_textfield.dart';
import 'package:ecommerce/pages/shop_page.dart';
import 'package:ecommerce/provider/user_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoggingIn = false;
  static const String EMAILKEY = "username";
  static const String PASSKEY = "password";
  static const String LOGIN = "isLoggedIn";
  String? savedUsername;
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    _checkForSavedCredentials();
  }

  void _checkForSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUsername = prefs.getString(EMAILKEY);
    savedPassword = prefs.getString(PASSKEY);

    if (savedUsername != null && savedPassword != null) {
      emailController.text = savedUsername!;
      passwordController.text = savedPassword!;
    }
  }

  // login method
  void _login() async {
    setState(() {
      _isLoggingIn = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUsername = prefs.getString(EMAILKEY);
    savedPassword = prefs.getString(PASSKEY);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Validate email format
    if (!EmailValidator.validate(emailController.text.trim())) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Email"),
          content: const Text("Please enter a valid email address"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      setState(() {
        _isLoggingIn = false;
      });
      return;
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Credentials Missing"),
          content: const Text("Enter Your Email & Password"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Attempt to log in using the API
      try {
        final response = await http.post(
          Uri.parse('https://ecommercebackend-o2fv.onrender.com/user/login'),
          body: jsonEncode({
            'email': emailController.text,
            'password': passwordController.text,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          await prefs.setString(EMAILKEY, emailController.text);
          await prefs.setString(PASSKEY, passwordController.text);
          await prefs.setBool(LOGIN, true);
          
          await userProvider.setUser(emailController.text, passwordController.text);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShopPage()),
          );
          print('Login Using API');
        } else {
          print('Login failed with status code: ${response.statusCode}');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: const Text("Invalid email or password."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        print('Error: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("An error occurred during login."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _isLoggingIn = false;
    });
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoggingIn) {
      return Container();
    }
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withOpacity(0.5),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
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

                    // email textfield
                    MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController,
                    ),
                    const SizedBox(height: 10),

                    // password textfield
                    MyTextField(
                      hintText: "Password",
                      obscureText: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 10),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgotpassword_page'),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // sign in button
                    MyButton(
                      text: "Login",
                      onTap: _isLoggingIn ? null : _login,
                      child: const Text("Login"),
                    ),
                    const SizedBox(height: 25),

                    // don't have account? Register here
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?   ",
                          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register_page'),
                          child: const Text(
                            "Register Here",
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
          _buildLoadingOverlay(),
        ],
      ),
    );
  }
}
