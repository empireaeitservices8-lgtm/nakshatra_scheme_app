import 'package:flutter/material.dart';

import '../model/register_model.dart';
import '../repo/register_repository.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final RegisterRepository _repository;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Backwards compatibility alias for full name if needed
  TextEditingController get nameController => firstNameController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;
  RegisterResponseModel? _registerResponse;

  CreateAccountViewModel({RegisterRepository? repository})
      : _repository = repository ?? RegisterRepository();

  // Getters
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get agreedToTerms => _agreedToTerms;
  bool get isLoading => _isLoading;
  String get selectedCountryCode => _selectedCountryCode;
  String? get errorMessage => _errorMessage;
  RegisterResponseModel? get registerResponse => _registerResponse;
  RegisterUserDataModel? get registeredUser => _registerResponse?.result?.data;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void toggleTermsAgreement(bool? val) {
    _agreedToTerms = val ?? false;
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

  bool validateForm() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final city = cityController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty) {
      _errorMessage = "Please enter your first name";
      notifyListeners();
      return false;
    }

    if (lastName.isEmpty) {
      _errorMessage = "Please enter your last name";
      notifyListeners();
      return false;
    }

    if (phone.isEmpty || phone.length < 10) {
      _errorMessage = "Please enter a valid 10-digit mobile number";
      notifyListeners();
      return false;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _errorMessage = "Please enter a valid email address";
      notifyListeners();
      return false;
    }

    if (city.isEmpty) {
      _errorMessage = "Please enter your city";
      notifyListeners();
      return false;
    }

    if (password.isEmpty || password.length < 6) {
      _errorMessage = "Password must be at least 6 characters long";
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = "Passwords do not match";
      notifyListeners();
      return false;
    }

    if (!_agreedToTerms) {
      _errorMessage = "Please agree to the Terms & Conditions to proceed";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Executes user registration via RegisterRepository
  Future<bool> registerAccount() async {
    if (!validateForm()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final fullName = "$firstName $lastName".trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final city = cityController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      final params = RegisterRequestParams(
        name: fullName,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        city: city,
      );

      final response = await _repository.register(params);
      _registerResponse = response;

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

        _errorMessage = errorMsg ?? "Registration failed. Please try again.";
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
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
