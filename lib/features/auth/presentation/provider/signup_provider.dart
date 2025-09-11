// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  final GlobalKey<FormState> _signupFormkey = GlobalKey<FormState>(
    debugLabel: 'SingUpForm',
  );
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isEnterPasswordVisible = false;
  bool _isCreatePasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  GlobalKey<FormState> get signupFormkey => _signupFormkey;
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPassController => _confirmPassController;
  bool get isEnterPasswordVisible => _isEnterPasswordVisible;
  bool get isCreatePasswordVisible => _isCreatePasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;

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

  Future<void> handleLoging(BuildContext context) async {
    if (_signupFormkey.currentState!.validate()) {
      setLoading(true);

      try {
        await Future.delayed(Duration(seconds: 3));
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
    super.dispose();
  }
}
