//import 'package:project/User/room_list_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project/config.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;
  bool _isLoading = false;

Future<void> _signup() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final response = await http.post(
      Uri.parse('$baseURL/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful. Please log in.')),
      );

      // Navigate back to Login page
      Navigator.pop(context);
    } else {
      final responseData = jsonDecode(response.body);
      String errorMessage =
          responseData['message'] ?? 'Unknown error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server error. Please try again later.')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in the details',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.secondary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email', colorScheme),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildPasswordInputDecoration(
                          'Password',
                          colorScheme,
                          _obscurePassword,
                          () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.trim().length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password Field
                      TextFormField(
                        controller: _reEnterPasswordController,
                        decoration: _buildPasswordInputDecoration(
                          'Re-enter Password',
                          colorScheme,
                          _obscureReEnterPassword,
                          () => setState(() => _obscureReEnterPassword =
                              !_obscureReEnterPassword),
                        ),
                        obscureText: _obscureReEnterPassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Confirmation password is required';
                          }
                          if (value.trim() != _passwordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 16, color: colorScheme.onPrimary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.secondary),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  InputDecoration _buildPasswordInputDecoration(
    String label,
    ColorScheme colorScheme,
    bool obscure,
    VoidCallback toggle,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.secondary),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: colorScheme.secondary,
        ),
        onPressed: toggle,
      ),
    );
  }
}
