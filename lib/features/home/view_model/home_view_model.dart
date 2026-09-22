import 'package:flutter/material.dart';

import '../../../helpers/sp_helper.dart';
import '../../schemes/model/popular_plans_model.dart';
import '../model/gold_account_model.dart';
import '../model/live_gold_price_model.dart';
import '../model/my_schemes_model.dart';
import '../repo/home_repository.dart';

class SchemePlan {
  final String id;
  final String title;
  final String description;
  final bool isDark;
  final String duration;
  final double monthlyAmount;

  const SchemePlan({
    required this.id,
    required this.title,
    required this.description,
    required this.isDark,
    this.duration = "11 Months",
    this.monthlyAmount = 5000,
  });
}

class ActiveScheme {
  final String id;
  final String title;
  final String duration;
  final String monthlyDue;
  final String nextPaymentDate;
  final double progressPercent;

  const ActiveScheme({
    required this.id,
    required this.title,
    required this.duration,
    required this.monthlyDue,
    required this.nextPaymentDate,
    required this.progressPercent,
  });
}

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewModel({HomeRepository? homeRepository})
      : _homeRepository = homeRepository ?? HomeRepository() {
    _loadUserData();
    fetchLiveGoldPrice();
    fetchGoldAccountDetails();
    fetchMySchemes();
    fetchPopularPlans();
  }

  // User Profile
  String _userName = "User";
  String _userInitials = "U";
  String _memberCode = "NGS-2026-9845";

  // Gold Account Data
  double _goldWeightGrams = 15.5;
  double _currentGoldValue = 110000;
  String _purityText = "22CT(92)";
  GoldAccountDataModel? _goldAccountData;
  bool _isLoadingGoldAccount = false;
  String? _goldAccountErrorMessage;

  // Live Gold Price State
  double _liveGoldPricePerGram = 14010;
  String _unit = "/g";
  double _boardRate = 0;
  double _goldPriceChangePercentage = 21.72;
  String _currencySymbol = "₹";
  bool _isPriceTrendingUp = true;
  bool _isLoadingLivePrice = false;
  String? _livePriceErrorMessage;
  LiveGoldPriceDataModel? _liveGoldPriceData;

  // Dynamic My Schemes from Backend
  List<MySchemeDataModel> _apiMySchemes = [];
  bool _isLoadingMySchemes = false;
  String? _mySchemesErrorMessage;

  // Dynamic Popular Plans from Backend
  List<PopularPlanDataModel> _apiPopularPlans = [];
  bool _isLoadingPopularPlans = false;
  String? _popularPlansErrorMessage;

  // Bottom Navigation
  int _selectedTabIndex = 0;

  // Active Schemes Fallback
  final List<ActiveScheme> _activeSchemes = const [
    ActiveScheme(
      id: "scheme_1",
      title: "11-Month Gold Savings Plan",
      duration: "11 Months",
      monthlyDue: "₹5000",
      nextPaymentDate: "15th of month",
      progressPercent: 0.75,
    ),
  ];

  // Fallback Popular Plans
  final List<SchemePlan> _popularPlans = const [
    SchemePlan(
      id: "fixed_weight",
      title: "Fixed Weight Plan",
      description: "Accumulate physical gold monthly and protect against price hikes.",
      isDark: true,
      duration: "11 Months",
      monthlyAmount: 10000,
    ),
    SchemePlan(
      id: "maturity_bonus",
      title: "Maturity Bonus Plan",
      description: "Redeem value with exclusive making charges discounts and bonuses.",
      isDark: false,
      duration: "12 Months",
      monthlyAmount: 5000,
    ),
    SchemePlan(
      id: "digi_gold_flexi",
      title: "Digi-Gold Flexi Plan",
      description: "Invest any amount anytime at live 24K pure gold rates.",
      isDark: true,
      duration: "Flexible",
      monthlyAmount: 2000,
    ),
  ];

  // Getters
  double get goldWeightGrams => _goldWeightGrams;
  double get currentGoldValue => _currentGoldValue;
  String get memberCode => _memberCode;
  String get purityText => _purityText;
  String get userInitials => _userInitials;
  String get userName => _userName;
  GoldAccountDataModel? get goldAccountData => _goldAccountData;
  bool get isLoadingGoldAccount => _isLoadingGoldAccount;
  String? get goldAccountErrorMessage => _goldAccountErrorMessage;

  double get liveGoldPricePerGram => _liveGoldPricePerGram;
  String get unit => _unit;
  double get boardRate => _boardRate;
  double get goldPriceChangePercentage => _goldPriceChangePercentage;
  String get currencySymbol => _currencySymbol;
  bool get isPriceTrendingUp => _isPriceTrendingUp;
  bool get isLoadingLivePrice => _isLoadingLivePrice;
  String? get livePriceErrorMessage => _livePriceErrorMessage;
  LiveGoldPriceDataModel? get liveGoldPriceData => _liveGoldPriceData;

  List<MySchemeDataModel> get apiMySchemes => _apiMySchemes;
  bool get isLoadingMySchemes => _isLoadingMySchemes;
  String? get mySchemesErrorMessage => _mySchemesErrorMessage;

  List<PopularPlanDataModel> get apiPopularPlans => _apiPopularPlans;
  bool get isLoadingPopularPlans => _isLoadingPopularPlans;
  String? get popularPlansErrorMessage => _popularPlansErrorMessage;

  int get selectedTabIndex => _selectedTabIndex;
  List<ActiveScheme> get activeSchemes => _activeSchemes;
  List<SchemePlan> get popularPlans => _popularPlans;

  /// Loads stored user details from local storage
  Future<void> _loadUserData() async {
    try {
      final name = await SpHelper.getUserName();
      final email = await SpHelper.getUserEmail();
      final userId = await SpHelper.getUserId();

      if (name != null && name.trim().isNotEmpty) {
        _userName = name.trim();
        _userInitials = _extractInitials(_userName);
      } else if (email != null && email.trim().isNotEmpty) {
        _userName = email.split('@').first;
        _userInitials = _extractInitials(_userName);
      }

      if (userId != null && userId > 0 && (_memberCode.isEmpty || _memberCode == "NGS-2026-9845")) {
        _memberCode = "NGS-${DateTime.now().year}-$userId";
      }

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ [HomeViewModel] Error loading user data: $e");
    }
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      final second = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
      return '$first$second';
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return "JD";
  }

  /// Fetches live gold price from the backend API
  Future<void> fetchLiveGoldPrice() async {
    _isLoadingLivePrice = true;
    _livePriceErrorMessage = null;
    notifyListeners();

    try {
      final response = await _homeRepository.getLiveGoldPrice();
      if (response.isSuccess && response.result?.data != null) {
        final data = response.result!.data!;
        _liveGoldPriceData = data;
        if (data.goldPricePerGram != null) {
          _liveGoldPricePerGram = data.goldPricePerGram!.toDouble();
        }
        if (data.unit != null && data.unit!.isNotEmpty) {
          _unit = data.unit!;
        }
        if (data.boardRate != null) {
          _boardRate = data.boardRate!.toDouble();
        }
        if (data.purity != null && data.purity!.isNotEmpty) {
          _purityText = data.purity!;
        }
        if (data.changePercentage != null) {
          _goldPriceChangePercentage = data.changePercentage!.toDouble();
        }
        if (data.currencySymbol != null && data.currencySymbol!.isNotEmpty) {
          _currencySymbol = data.currencySymbol!;
        }

        _isPriceTrendingUp = _goldPriceChangePercentage >= 0;
        if (_goldAccountData == null || _goldAccountData?.currentValue == null) {
          _currentGoldValue = _goldWeightGrams * _liveGoldPricePerGram;
        }
        _livePriceErrorMessage = null;
      } else {
        _livePriceErrorMessage = response.error?.message ?? "Failed to fetch live gold price";
      }
    } catch (e) {
      _livePriceErrorMessage = e.toString();
      debugPrint("❌ [HomeViewModel] Exception in fetchLiveGoldPrice: $e");
    } finally {
      _isLoadingLivePrice = false;
      notifyListeners();
    }
  }

  /// Fetches gold account details from backend API
  Future<void> fetchGoldAccountDetails() async {
    _isLoadingGoldAccount = true;
    _goldAccountErrorMessage = null;
    notifyListeners();

    try {
      final response = await _homeRepository.getGoldAccountDetails();
      if (response.isSuccess && response.result?.data != null) {
        final data = response.result!.data!;
        _goldAccountData = data;
        if (data.totalGrams != null) {
          _goldWeightGrams = data.totalGrams!.toDouble();
        }
        if (data.currentValue != null) {
          _currentGoldValue = data.currentValue!.toDouble();
        }
        if (data.memberCode != null && data.memberCode!.isNotEmpty) {
          _memberCode = data.memberCode!;
        }
        if (data.purity != null && data.purity!.isNotEmpty) {
          _purityText = data.purity!;
        }
        if (data.currencySymbol != null && data.currencySymbol!.isNotEmpty) {
          _currencySymbol = data.currencySymbol!;
        }
        _goldAccountErrorMessage = null;
        debugPrint("✅ [HomeViewModel] Loaded gold account: ${_goldWeightGrams}g, $_currencySymbol$_currentGoldValue, member: $_memberCode");
      } else if (response.error != null) {
        _goldAccountErrorMessage = response.error?.message ?? "Failed to load gold account";
      }
    } catch (e) {
      _goldAccountErrorMessage = e.toString();
      debugPrint("❌ [HomeViewModel] Exception in fetchGoldAccountDetails: $e");
    } finally {
      _isLoadingGoldAccount = false;
      notifyListeners();
    }
  }

  /// Fetches enrolled active schemes from backend API
  Future<void> fetchMySchemes() async {
    _isLoadingMySchemes = true;
    _mySchemesErrorMessage = null;
    notifyListeners();

    try {
      final response = await _homeRepository.getMySchemes();
      if (response.isSuccess && response.result?.data != null) {
        _apiMySchemes = response.result!.data!;
        _mySchemesErrorMessage = null;
        debugPrint("✅ [HomeViewModel] Loaded ${_apiMySchemes.length} enrolled schemes from API");
      } else if (response.error != null) {
        _mySchemesErrorMessage = response.error?.message ?? "Failed to load schemes";
      }
    } catch (e) {
      _mySchemesErrorMessage = e.toString();
      debugPrint("❌ [HomeViewModel] Exception in fetchMySchemes: $e");
    } finally {
      _isLoadingMySchemes = false;
      notifyListeners();
    }
  }

  /// Fetches popular scheme plans from backend API
  Future<void> fetchPopularPlans() async {
    _isLoadingPopularPlans = true;
    _popularPlansErrorMessage = null;
    notifyListeners();

    try {
      final response = await _homeRepository.getPopularPlans();
      if (response.isSuccess && response.result?.data != null && response.result!.data!.isNotEmpty) {
        _apiPopularPlans = response.result!.data!;
        _popularPlansErrorMessage = null;
        debugPrint("✅ [HomeViewModel] Loaded ${_apiPopularPlans.length} popular plans from API");
      } else if (response.error != null) {
        _popularPlansErrorMessage = response.error?.message ?? "Failed to load plans";
      }
    } catch (e) {
      _popularPlansErrorMessage = e.toString();
      debugPrint("❌ [HomeViewModel] Exception in fetchPopularPlans: $e");
    } finally {
      _isLoadingPopularPlans = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void refreshData() {
    _loadUserData();
    fetchLiveGoldPrice();
    fetchGoldAccountDetails();
    fetchMySchemes();
    fetchPopularPlans();
  }
}
