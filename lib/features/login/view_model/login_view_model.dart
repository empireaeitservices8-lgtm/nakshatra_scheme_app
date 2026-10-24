import 'dart:async';
import 'package:flutter/material.dart';

import '../../../utils/app_build_methods.dart';
import '../model/login_model.dart';
import '../model/otp_model.dart';
import '../repo/login_repository.dart';

enum LoginStep {
  phoneInput,
  otpVerification,
}

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository;

  // Controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Legacy controllers for compatibility
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State
  LoginStep _currentStep = LoginStep.phoneInput;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;
  String? _successMessage;

  // OTP data
  SendOtpResponseModel? _sendOtpResponse;
  VerifyOtpResponseModel? _verifyOtpResponse;
  LoginResponseModel? _loginResponse;

  int? _userId;
  String? _receivedOtpForTesting; // Useful for dev testing

  // Countdown timer for Resend OTP
  Timer? _resendTimer;
  int _resendCountdown = 0;
  static const int resendDurationSeconds = 30;

  LoginViewModel({LoginRepository? repository})
      : _repository = repository ?? LoginRepository();

  // Getters
  LoginStep get currentStep => _currentStep;
  bool get isPhoneStep => _currentStep == LoginStep.phoneInput;
  bool get isOtpStep => _currentStep == LoginStep.otpVerification;
  bool get isLoading => _isLoading;
  String get selectedCountryCode => _selectedCountryCode;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get resendCountdown => _resendCountdown;
  bool get canResendOtp => _resendCountdown == 0;
  String? get receivedOtpForTesting => _receivedOtpForTesting;
  int? get userId => _userId;

  SendOtpResponseModel? get sendOtpResponse => _sendOtpResponse;
  VerifyOtpResponseModel? get verifyOtpResponse => _verifyOtpResponse;
  LoginResponseModel? get loginResponse => _loginResponse;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

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

  void setStep(LoginStep step) {
    _currentStep = step;
    _errorMessage = null;
    notifyListeners();
  }

  void changePhoneNumber() {
    _stopTimer();
    _currentStep = LoginStep.phoneInput;
    otpController.clear();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  bool validatePhoneInput() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      _errorMessage = "Please enter your mobile number";
      notifyListeners();
      return false;
    }

    if (!isValidIndianPhoneNumber(phone)) {
      _errorMessage = "Please enter a valid 10-digit Indian mobile number";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool validateOtpInput() {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      _errorMessage = "Please enter the 6-digit OTP";
      notifyListeners();
      return false;
    }

    if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      _errorMessage = "Please enter a valid 6-digit OTP code";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Sends OTP to the entered phone number
  Future<bool> sendOtp() async {
    if (!validatePhoneInput()) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final phone = phoneController.text.trim();
      final response = await _repository.sendOtp(phone: phone);
      _sendOtpResponse = response;

      _isLoading = false;

      if (response.isSuccess) {
        _userId = response.result?.userId;
        _receivedOtpForTesting = response.result?.otp;
        _currentStep = LoginStep.otpVerification;
        _successMessage = response.result?.message ?? "OTP sent successfully";

        // Clear OTP field for manual user entry
        otpController.clear();

        _startResendTimer();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error?.message ??
            response.result?.message ??
            "Failed to send OTP. Please check your phone number.";
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

  /// Resends OTP to the phone number via /api/scheme/otp/resend
  Future<bool> resendOtp() async {
    if (!canResendOtp) return false;
    if (!validatePhoneInput()) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final phone = phoneController.text.trim();
      final response = await _repository.resendOtp(phone: phone);

      _isLoading = false;

      if (response.isSuccess) {
        if (response.result?.userId != null) {
          _userId = response.result?.userId;
        }
        _receivedOtpForTesting = response.result?.otp;
        _successMessage = response.result?.message ?? "OTP resent successfully";

        // Clear OTP field for manual user entry
        otpController.clear();

        _startResendTimer();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error?.message ??
            response.result?.message ??
            "Failed to resend OTP. Please try again.";
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

  /// Verifies OTP code entered by the user
  Future<bool> verifyOtp() async {
    if (!validateOtpInput()) return false;

    if (_userId == null) {
      _errorMessage = "User session expired. Please request OTP again.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final otp = otpController.text.trim();

      final response = await _repository.verifyOtp(
        userId: _userId!,
        otp: otp,
      );
      _verifyOtpResponse = response;

      _isLoading = false;

      if (response.isSuccess) {
        _stopTimer();
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error?.message ??
            response.result?.message ??
            "Invalid OTP. Please try again.";
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

  void _startResendTimer() {
    _stopTimer();
    _resendCountdown = resendDurationSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  /// Legacy method for backward compatibility
  Future<bool> signIn() async {
    return await verifyOtp();
  }

  @override
  void dispose() {
    _stopTimer();
    phoneController.dispose();
    otpController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
