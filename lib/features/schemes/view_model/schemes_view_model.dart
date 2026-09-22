import 'package:flutter/material.dart';

import '../model/popular_plans_model.dart';
import '../repo/schemes_repository.dart';

class SchemesViewModel extends ChangeNotifier {
  final SchemesRepository _schemesRepository;

  SchemesViewModel({SchemesRepository? schemesRepository})
      : _schemesRepository = schemesRepository ?? SchemesRepository() {
    fetchPopularPlans();
  }

  // Popular Plans State
  List<PopularPlanDataModel> _popularPlans = [];
  bool _isLoadingPlans = false;
  String? _plansErrorMessage;

  List<PopularPlanDataModel> get popularPlans => _popularPlans;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get plansErrorMessage => _plansErrorMessage;

  // Calculator State
  double _monthlyBudget = 5000.0;
  final double _minBudget = 5000.0;
  final double _maxBudget = 50000.0;
  final double _liveGoldPricePerGram = 7500.0;

  double get monthlyBudget => _monthlyBudget;
  double get minBudget => _minBudget;
  double get maxBudget => _maxBudget;
  double get liveGoldPricePerGram => _liveGoldPricePerGram;

  // Estimated accumulation in grams
  double get estimatedGramsPerMonth => _monthlyBudget / _liveGoldPricePerGram;

  String get formattedMonthlyBudget => "₹${_monthlyBudget.toInt()}";

  String get formattedEstAccumulation =>
      "~${estimatedGramsPerMonth.toStringAsFixed(3)} grams / month";

  void updateMonthlyBudget(double value) {
    // Snap to nearest 500
    _monthlyBudget = (value / 500).round() * 500.0;
    if (_monthlyBudget < _minBudget) _monthlyBudget = _minBudget;
    if (_monthlyBudget > _maxBudget) _monthlyBudget = _maxBudget;
    notifyListeners();
  }

  /// Fetches popular scheme plans from the backend API
  Future<void> fetchPopularPlans() async {
    _isLoadingPlans = true;
    _plansErrorMessage = null;
    notifyListeners();

    try {
      final response = await _schemesRepository.getPopularPlans();
      if (response.isSuccess && response.result?.data != null && response.result!.data!.isNotEmpty) {
        _popularPlans = response.result!.data!;
        _plansErrorMessage = null;
        debugPrint("✅ [SchemesViewModel] Loaded ${_popularPlans.length} popular plans from API");
      } else if (response.error != null) {
        _plansErrorMessage = response.error?.message ?? "Failed to load popular plans";
        debugPrint("⚠️ [SchemesViewModel] Error from API: $_plansErrorMessage");
      } else {
        // Empty data received, fallback to default templates if needed
        if (response.result?.data != null) {
          _popularPlans = response.result!.data!;
        }
      }
    } catch (e) {
      _plansErrorMessage = e.toString();
      debugPrint("❌ [SchemesViewModel] Exception in fetchPopularPlans: $e");
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  void refresh() {
    fetchPopularPlans();
  }
}
