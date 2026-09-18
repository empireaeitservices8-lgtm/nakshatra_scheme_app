import 'package:flutter/material.dart';

class SchemeOption {
  final String id;
  final String name;
  final String duration;
  final String description;

  const SchemeOption({
    required this.id,
    required this.name,
    required this.duration,
    required this.description,
  });
}

class CreateAccountViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: "2000");
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineeRelationController = TextEditingController();

  final List<SchemeOption> availableSchemes = const [
    SchemeOption(
      id: 'swarna_varsha_11',
      name: 'Swarna Varsha',
      duration: '11 Months',
      description: 'Pay 11 monthly installments & get exciting gold bonus benefits',
    ),
    SchemeOption(
      id: 'nakshathra_flexi_gold',
      name: 'Nakshathra Flexi Gold',
      duration: 'Flexible',
      description: 'Accumulate gold weight at live gold rates anytime',
    ),
    SchemeOption(
      id: 'swarna_nidhi_daily',
      name: 'Swarna Nidhi Daily',
      duration: '300 Days',
      description: 'Save small amounts daily and redeem for gold jewellery',
    ),
  ];

  late SchemeOption _selectedScheme;
  int _selectedAmountIndex = 1; // Default to ₹2,000
  final List<int> presetAmounts = [1000, 2000, 5000, 10000];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;

  CreateAccountViewModel() {
    _selectedScheme = availableSchemes.first;
  }

  // Getters
  SchemeOption get selectedScheme => _selectedScheme;
  int get selectedAmountIndex => _selectedAmountIndex;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get agreedToTerms => _agreedToTerms;
  bool get isLoading => _isLoading;
  String get selectedCountryCode => _selectedCountryCode;
  String? get errorMessage => _errorMessage;

  void selectScheme(SchemeOption scheme) {
    _selectedScheme = scheme;
    notifyListeners();
  }

  void selectPresetAmount(int index) {
    _selectedAmountIndex = index;
    if (index >= 0 && index < presetAmounts.length) {
      amountController.text = presetAmounts[index].toString();
    }
    notifyListeners();
  }

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
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final amount = amountController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      _errorMessage = "Please enter your full name";
      notifyListeners();
      return false;
    }

    if (phone.isEmpty || phone.length < 10) {
      _errorMessage = "Please enter a valid 10-digit mobile number";
      notifyListeners();
      return false;
    }

    if (amount.isEmpty || (int.tryParse(amount) ?? 0) < 500) {
      _errorMessage = "Minimum monthly installment amount is ₹500";
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
      _errorMessage = "Please accept the Scheme Terms & Conditions to proceed";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> registerSchemeAccount() async {
    if (!validateForm()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call for scheme enrollment & account registration
      await Future.delayed(const Duration(milliseconds: 1500));
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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    amountController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    super.dispose();
  }
}
