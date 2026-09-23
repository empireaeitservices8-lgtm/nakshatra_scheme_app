import 'package:flutter/material.dart';

import '../../../helpers/sp_helper.dart';
import '../model/join_scheme_model.dart';
import '../repo/schemes_repository.dart';

class JoinSchemeViewModel extends ChangeNotifier {
  final SchemesRepository _schemesRepository;

  JoinSchemeViewModel({SchemesRepository? schemesRepository})
      : _schemesRepository = schemesRepository ?? SchemesRepository();

  bool _isLoading = false;
  String? _errorMessage;
  JoinSchemeResponseModel? _joinResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JoinSchemeResponseModel? get joinResponse => _joinResponse;

  /// Submits the join scheme request to api/scheme/join
  Future<JoinSchemeResponseModel?> submitJoinScheme({
    required String schemeType,
    required double monthlyInstallment,
    required int duration,
    required String nominee,
    int? customUserId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storedUserId = await SpHelper.getUserId();
      final effectiveUserId = customUserId ?? storedUserId ?? 2;

      final params = JoinSchemeRequestParams(
        userId: effectiveUserId,
        schemeType: schemeType,
        monthlyInstallment: monthlyInstallment,
        duration: duration,
        nominee: nominee.trim(),
      );

      final response = await _schemesRepository.joinScheme(params);

      if (response.isSuccess && response.result != null) {
        _joinResponse = response;
        _errorMessage = null;
        debugPrint("✅ [JoinSchemeViewModel] Scheme joined successfully. Enrollment ID: ${response.result?.data?.enrollmentId}");
      } else {
        _errorMessage = response.error?.message ?? response.result?.message ?? "Failed to join scheme.";
        debugPrint("❌ [JoinSchemeViewModel] Failed to join scheme: $_errorMessage");
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ [JoinSchemeViewModel] Exception in submitJoinScheme: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
