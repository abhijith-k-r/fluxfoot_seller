// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/auth/authgate.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';

class LoginProvider extends ChangeNotifier {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>(
    debugLabel: 'LoginForm',
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  GlobalKey<FormState> get loginFormKey => _loginFormKey;

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  FocusNode get emailFocus => _emailFocus;
  FocusNode get passwordFocus => _passwordFocus;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisible() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> handleLoging(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      setLoading(true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: WebColors.succesGreen,
          ),
        );

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthGate()),
        );
      } on FirebaseAuthException catch (e) {
        setError(e.message);
        log('Login Failed 1: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed1: ${e.message}'),
            backgroundColor: WebColors.errorRed,
          ),
        );
      } catch (e) {
        setError(e.toString());
        log('Login Failed 2 : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed2: ${e.toString()}'),
            backgroundColor: WebColors.errorRed,
          ),
        );
      } finally {
        setLoading(false);
      }
    }
  }

  Future<void> handleForgotPassword(BuildContext context) async {
    String? email = await showDialog<String>(
      context: context,
      builder: (context) {
        String emailInput = '';
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            onChanged: (value) => emailInput = value,
            decoration: InputDecoration(hintText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, emailInput),
              child: Text('Send'),
            ),
          ],
        );
      },
    );

    if (email != null && email.isNotEmpty) {
      setLoading(true);
      try {
        await _auth.sendPasswordResetEmail(email: email.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: WebColors.succesGreen,
          ),
        );
      } on FirebaseAuthException catch (e) {
        setError(e.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: WebColors.errorRed,
          ),
        );
      } finally {
        setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
