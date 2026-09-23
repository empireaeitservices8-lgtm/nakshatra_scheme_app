import 'package:flutter/material.dart';

import '../../../helpers/sp_helper.dart';
import '../model/logout_model.dart';
import '../model/support_faq_model.dart';
import '../model/transaction_receipt_model.dart';
import '../repo/profile_repository.dart';

// Keep for backward compat if used elsewhere
class TransactionReceipt {
  final String id;
  final String title;
  final String date;
  final String amount;
  final bool isCredit;

  const TransactionReceipt({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.isCredit = true,
  });
}

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  // User Details
  String _userName = "Nakshathra Member";
  String _userInitials = "NM";
  String _userEmail = "";
  String _userPhone = "";
  String _memberId = "NGS-2026-9845";
  String _memberSince = "Jan 2026";
  bool _isLoggingOut = false;

  // Support & FAQ State
  SupportFaqDataModel? _supportFaq;
  bool _isLoadingFaq = false;
  String? _faqErrorMessage;
  final Set<int> _expandedFaqIds = {};

  // Balances
  final double _goldBalanceGrams = 15.5;
  final double _totalValue = 110000;

  // Transaction Receipts (API-backed)
  List<TransactionReceiptItem> _receiptItems = [];
  bool _isLoadingReceipts = false;
  String? _receiptsErrorMessage;

  ProfileViewModel({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository() {
    _loadUserProfile();
    fetchSupportFaq();
    fetchTransactionReceipts();
  }

  // Getters
  String get userName => _userName;
  String get userInitials => _userInitials;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get memberId => _memberId;
  String get memberSince => _memberSince;
  bool get isLoggingOut => _isLoggingOut;
  double get goldBalanceGrams => _goldBalanceGrams;
  double get totalValue => _totalValue;

  // Transaction receipt getters
  List<TransactionReceiptItem> get receiptItems => _receiptItems;
  bool get isLoadingReceipts => _isLoadingReceipts;
  String? get receiptsErrorMessage => _receiptsErrorMessage;

  // Support & FAQ Getters
  SupportFaqDataModel? get supportFaq => _supportFaq;
  bool get isLoadingFaq => _isLoadingFaq;
  String? get faqErrorMessage => _faqErrorMessage;
  Set<int> get expandedFaqIds => _expandedFaqIds;

  bool isFaqExpanded(int id) => _expandedFaqIds.contains(id);

  void toggleFaq(int id) {
    if (_expandedFaqIds.contains(id)) {
      _expandedFaqIds.remove(id);
    } else {
      _expandedFaqIds.add(id);
    }
    notifyListeners();
  }

  String get formattedGoldBalance => "${_goldBalanceGrams.toStringAsFixed(1)} g";
  String get formattedTotalValue => "₹${_totalValue.toInt()}";

  /// Loads persisted user details from SpHelper
  Future<void> _loadUserProfile() async {
    final name = await SpHelper.getUserName();
    final email = await SpHelper.getUserEmail();
    final phone = await SpHelper.getUserPhone();
    final userId = await SpHelper.getUserId();

    if (name != null && name.isNotEmpty) {
      _userName = name;
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        _userInitials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        _userInitials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (userId != null) _memberId = "NGS-${userId.toString().padLeft(6, '0')}";

    notifyListeners();
  }

  /// Fetches Support and FAQ data from backend API
  Future<void> fetchSupportFaq() async {
    _isLoadingFaq = true;
    _faqErrorMessage = null;
    notifyListeners();

    try {
      final userId = await SpHelper.getUserId();
      final response = await _profileRepository.getSupportFaq(userId: userId);

      if (response.isSuccess && response.result?.data != null) {
        _supportFaq = response.result!.data;
        _faqErrorMessage = null;
        debugPrint("✅ [ProfileViewModel] Loaded Support FAQ: ${_supportFaq?.title} with ${_supportFaq?.faqs.length} FAQs");
      } else if (response.error != null) {
        _faqErrorMessage = response.error?.message ?? "Failed to load FAQs";
      }
    } catch (e) {
      _faqErrorMessage = e.toString();
      debugPrint("❌ [ProfileViewModel] Exception in fetchSupportFaq: $e");
    } finally {
      _isLoadingFaq = false;
      notifyListeners();
    }
  }

  /// Fetches transaction receipts from api/scheme/transaction-receipts
  Future<void> fetchTransactionReceipts() async {
    _isLoadingReceipts = true;
    _receiptsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _profileRepository.getTransactionReceipts();

      if (response.isSuccess && response.result?.data != null) {
        _receiptItems = response.result!.data;
        _receiptsErrorMessage = null;
        debugPrint("✅ [ProfileViewModel] Loaded ${_receiptItems.length} transaction receipt(s)");
      } else if (response.error != null) {
        _receiptsErrorMessage = response.error?.message ?? "Failed to load receipts";
        debugPrint("❌ [ProfileViewModel] Receipts error: $_receiptsErrorMessage");
      }
    } catch (e) {
      _receiptsErrorMessage = e.toString();
      debugPrint("❌ [ProfileViewModel] Exception in fetchTransactionReceipts: $e");
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }

  /// Calls the Logout API and clears local session
  Future<LogoutResponseModel> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      final response = await _profileRepository.logout();
      _isLoggingOut = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoggingOut = false;
      notifyListeners();
      return LogoutResponseModel(
        result: LogoutResultModel(
          status: "success",
          message: "Successfully logged out",
        ),
      );
    }
  }
}
