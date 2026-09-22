import 'package:flutter/material.dart';

import '../model/login_model.dart';
import '../repo/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Alias for backwards compatibility if needed
  TextEditingController get phoneController => usernameController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;
  LoginResponseModel? _loginResponse;

  LoginViewModel({LoginRepository? repository})
      : _repository = repository ?? LoginRepository();

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  String get selectedCountryCode => _selectedCountryCode;
  String? get errorMessage => _errorMessage;
  LoginResponseModel? get loginResponse => _loginResponse;
  UserDataModel? get currentUser => _loginResponse?.result?.data;

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
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _errorMessage = "Please enter your username or email";
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

  /// Performs login using the LoginRepository
  Future<bool> signIn() async {
    if (!validateInputs()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text;

      final response = await _repository.login(
        username: username,
        password: password,
      );

      _loginResponse = response;

      if (response.isSuccess) {
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        
        // Extract descriptive error message from server
        String? errorMsg = response.result?.message;
        if (errorMsg == null && response.error != null) {
          if (response.error?.data is Map &&
              response.error!.data['message'] != null) {
            errorMsg = response.error!.data['message'].toString();
          } else {
            errorMsg = response.error?.message;
          }
        }

        _errorMessage = errorMsg ?? "Invalid username or password. Please try again.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
