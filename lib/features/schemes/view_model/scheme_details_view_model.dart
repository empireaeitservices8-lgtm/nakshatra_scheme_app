import 'package:flutter/material.dart';

import '../model/scheme_details_model.dart';
import '../repo/schemes_repository.dart';

class SchemeDetailsViewModel extends ChangeNotifier {
  final SchemesRepository _schemesRepository;
  final int enrollmentId;

  SchemeDetailsViewModel({
    SchemesRepository? schemesRepository,
    this.enrollmentId = 1,
  }) : _schemesRepository = schemesRepository ?? SchemesRepository() {
    fetchSchemeDetails(enrollmentId);
  }

  SchemeDetailsDataModel? _schemeDetails;
  bool _isLoading = false;
  String? _errorMessage;

  SchemeDetailsDataModel? get schemeDetails => _schemeDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches scheme details by enrollment ID from backend API
  Future<void> fetchSchemeDetails(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _schemesRepository.getSchemeDetails(enrollmentId: id);
      if (response.isSuccess && response.result?.data != null) {
        _schemeDetails = response.result!.data;
        _errorMessage = null;
        debugPrint("✅ [SchemeDetailsViewModel] Loaded details for enrollment $id: ${_schemeDetails?.planName}");
      } else if (response.error != null) {
        _errorMessage = response.error?.message ?? "Failed to load scheme details";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ [SchemeDetailsViewModel] Exception in fetchSchemeDetails: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    fetchSchemeDetails(_schemeDetails?.enrollmentId ?? enrollmentId);
  }
}
