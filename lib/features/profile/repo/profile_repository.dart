import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/urls.dart';
import '../model/logout_model.dart';
import '../model/reset_password_model.dart';
import '../model/support_faq_model.dart';
import '../model/transaction_receipt_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Fetches Support and FAQ data from api/scheme/support-faq
  Future<SupportFaqResponseModel> getSupportFaq({int? userId}) async {
    final effectiveUserId = userId ?? await SpHelper.getUserId() ?? 1;
    final requestBody = SupportFaqRequestModel(
      params: SupportFaqRequestParams(userId: effectiveUserId),
    ).toJson();

    debugPrint("===> [ProfileRepository] Request to $urlSchemeSupportFaq: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeSupportFaq,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [ProfileRepository] Support FAQ status: ${response.statusCode}");
      debugPrint("<=== [ProfileRepository] Support FAQ data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      final faqResponse = SupportFaqResponseModel.fromJson(responseMap);
      return faqResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [ProfileRepository] Support FAQ DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return SupportFaqResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server.";
      }

      return SupportFaqResponseModel(
        error: SupportFaqErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [ProfileRepository] Unexpected error in getSupportFaq: $e");
      return SupportFaqResponseModel(
        error: SupportFaqErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches transaction receipts from api/scheme/transaction-receipts
  Future<TransactionReceiptsResponseModel> getTransactionReceipts() async {
    final requestBody = TransactionReceiptsRequestModel().toJson();

    debugPrint("===> [ProfileRepository] Request to $urlSchemeTransactionReceipts: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty)
          'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeTransactionReceipts,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [ProfileRepository] Transaction receipts status: ${response.statusCode}");
      debugPrint("<=== [ProfileRepository] Transaction receipts data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      return TransactionReceiptsResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [ProfileRepository] Transaction receipts DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return TransactionReceiptsResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server.";
      }

      return TransactionReceiptsResponseModel(
        error: TransactionReceiptsErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [ProfileRepository] Unexpected error in getTransactionReceipts: $e");
      return TransactionReceiptsResponseModel(
        error: TransactionReceiptsErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Resets user password via api/scheme/reset-password
  Future<ResetPasswordResponseModel> resetPassword({
    int? userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final effectiveUserId = userId ?? await SpHelper.getUserId() ?? 1;
    final requestBody = ResetPasswordRequestModel(
      params: ResetPasswordParams(
        userId: effectiveUserId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    ).toJson();

    debugPrint("===> [ProfileRepository] Request to $urlSchemeResetPassword: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty)
          'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeResetPassword,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [ProfileRepository] Reset password status: ${response.statusCode}");
      debugPrint("<=== [ProfileRepository] Reset password data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      return ResetPasswordResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [ProfileRepository] Reset password DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return ResetPasswordResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server.";
      }

      return ResetPasswordResponseModel(
        error: ResetPasswordErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [ProfileRepository] Unexpected error in resetPassword: $e");
      return ResetPasswordResponseModel(
        error: ResetPasswordErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Executes the Scheme Logout API request and clears local session
  Future<LogoutResponseModel> logout() async {
    final requestBody = LogoutRequestModel().toJson();
    final sessionId = await SpHelper.getSessionId();

    debugPrint("===> [ProfileRepository] Request to $urlSchemeLogout: ${jsonEncode(requestBody)}");

    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (sessionId != null && sessionId.isNotEmpty) {
        headers['Cookie'] = 'session_id=$sessionId';
        headers['Authorization'] = 'Bearer $sessionId';
      }

      final response = await _dio.post(
        urlSchemeLogout,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [ProfileRepository] Logout status: ${response.statusCode}");
      debugPrint("<=== [ProfileRepository] Logout data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseMap = {
          "result": {
            "status": "success",
            "message": "Successfully logged out"
          }
        };
      }

      final logoutResponse = LogoutResponseModel.fromJson(responseMap);

      // Always clear local user session upon logout
      await SpHelper.clearUserSession();

      return logoutResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [ProfileRepository] DioException: ${dioError.message}");

      // Clear local session even if network call failed
      await SpHelper.clearUserSession();

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return LogoutResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      return LogoutResponseModel(
        result: LogoutResultModel(
          status: "success",
          message: "Successfully logged out",
        ),
      );
    } catch (e) {
      debugPrint("❌ [ProfileRepository] Unexpected error in logout: $e");
      await SpHelper.clearUserSession();
      return LogoutResponseModel(
        result: LogoutResultModel(
          status: "success",
          message: "Successfully logged out",
        ),
      );
    }
  }
}

/// Backward compatibility alias
typedef LogoutRepository = ProfileRepository;
