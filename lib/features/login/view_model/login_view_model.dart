import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  String get selectedCountryCode => _selectedCountryCode;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setCountryCode(String code) {
    _selectedCountryCode = code;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  bool validateInputs() {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty) {
      _errorMessage = "Please enter your phone number";
      notifyListeners();
      return false;
    }

    if (phone.length < 10) {
      _errorMessage = "Please enter a valid 10-digit phone number";
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = "Please enter your password";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> signIn() async {
    if (!validateInputs()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network request or call authentication service
      await Future.delayed(const Duration(milliseconds: 1200));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
