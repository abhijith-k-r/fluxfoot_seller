// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/auth/authgate.dart';

class SignupProvider extends ChangeNotifier {
  final GlobalKey<FormState> _signupFormkey = GlobalKey<FormState>(
    debugLabel: 'SingUpForm',
  );
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEnterPasswordVisible = false;
  bool _isCreatePasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  GlobalKey<FormState> get signupFormkey => _signupFormkey;
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPassController => _confirmPassController;
  TextEditingController get phoneController => _phoneController;

  bool get isEnterPasswordVisible => _isEnterPasswordVisible;
  bool get isCreatePasswordVisible => _isCreatePasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibleEnter() {
    _isEnterPasswordVisible = !_isEnterPasswordVisible;
    notifyListeners();
  }

  void togglePasswordVisibleCreate() {
    _isCreatePasswordVisible = !_isCreatePasswordVisible;
    notifyListeners();
  }

  void toggleRemember(bool? value) {
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

  Future<void> handleSignup(BuildContext context) async {
    if (_signupFormkey.currentState!.validate()) {
      if (_passwordController.text != _confirmPassController.text) {
        setError('Passwords do not match');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setLoading(true);
      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // Check if the user was created successfully
        if (userCredential.user != null) {
          final String uid = userCredential.user!.uid;
          // Store seller data in Firestore
          await _firestore.collection('sellers').doc(uid).set({
            'uid': uid,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _confirmPassController.text.trim(),
            'phone': _phoneController.text.trim(),
            'createdAt': Timestamp.now(),
            'status': 'pending',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-up successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AuthGate()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setError(e.message);
        log(e.toString());
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Sign-up failed: ${e.message}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      } catch (e) {
        setError(e.toString());
        log(e.toString());
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Sign-up failed: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      } finally {
        setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
