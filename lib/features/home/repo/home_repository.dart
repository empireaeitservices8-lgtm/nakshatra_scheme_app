import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/urls.dart';
import '../../schemes/model/popular_plans_model.dart';
import '../model/gold_account_model.dart';
import '../model/live_gold_price_model.dart';
import '../model/my_schemes_model.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Fetches the live gold price from Odoo JSON-RPC API
  Future<LiveGoldPriceResponseModel> getLiveGoldPrice() async {
    final requestBody = LiveGoldPriceRequestModel().toJson();

    debugPrint("===> [HomeRepository] Request to $urlSchemeLiveGoldPrice: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeLiveGoldPrice,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [HomeRepository] Response status: ${response.statusCode}");
      debugPrint("<=== [HomeRepository] Response data: ${response.data}");

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

      final goldPriceResponse = LiveGoldPriceResponseModel.fromJson(responseMap);
      return goldPriceResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [HomeRepository] DioException: ${dioError.message}");
      debugPrint("❌ [HomeRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return LiveGoldPriceResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server. Please verify the server IP/port.";
      }

      return LiveGoldPriceResponseModel(
        error: LiveGoldPriceErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [HomeRepository] Unexpected error: $e");
      return LiveGoldPriceResponseModel(
        error: LiveGoldPriceErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches gold account details from Odoo JSON-RPC API
  Future<GoldAccountResponseModel> getGoldAccountDetails() async {
    final requestBody = GoldAccountRequestModel().toJson();

    debugPrint("===> [HomeRepository] Request to $urlSchemeGoldAccount: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeGoldAccount,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [HomeRepository] Gold account status: ${response.statusCode}");
      debugPrint("<=== [HomeRepository] Gold account data: ${response.data}");

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

      final goldAccountResponse = GoldAccountResponseModel.fromJson(responseMap);
      return goldAccountResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [HomeRepository] Gold account DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return GoldAccountResponseModel.fromJson(errorMap);
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

      return GoldAccountResponseModel(
        error: GoldAccountErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [HomeRepository] Unexpected error in getGoldAccountDetails: $e");
      return GoldAccountResponseModel(
        error: GoldAccountErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches popular scheme plans from Odoo JSON-RPC API
  Future<PopularPlansResponseModel> getPopularPlans() async {
    final requestBody = PopularPlansRequestModel().toJson();

    debugPrint("===> [HomeRepository] Request to $urlSchemePopularPlans: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemePopularPlans,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [HomeRepository] Popular plans status: ${response.statusCode}");
      debugPrint("<=== [HomeRepository] Popular plans data: ${response.data}");

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

      final popularPlansResponse = PopularPlansResponseModel.fromJson(responseMap);
      return popularPlansResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [HomeRepository] Popular plans DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return PopularPlansResponseModel.fromJson(errorMap);
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

      return PopularPlansResponseModel(
        error: PopularPlansErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [HomeRepository] Unexpected error in getPopularPlans: $e");
      return PopularPlansResponseModel(
        error: PopularPlansErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches enrolled user schemes from Odoo JSON-RPC API
  Future<MySchemesResponseModel> getMySchemes() async {
    final requestBody = MySchemesRequestModel().toJson();

    debugPrint("===> [HomeRepository] Request to $urlSchemeMySchemes: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeMySchemes,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [HomeRepository] My schemes status: ${response.statusCode}");
      debugPrint("<=== [HomeRepository] My schemes data: ${response.data}");

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

      final mySchemesResponse = MySchemesResponseModel.fromJson(responseMap);
      return mySchemesResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [HomeRepository] My schemes DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return MySchemesResponseModel.fromJson(errorMap);
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

      return MySchemesResponseModel(
        error: MySchemesErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [HomeRepository] Unexpected error in getMySchemes: $e");
      return MySchemesResponseModel(
        error: MySchemesErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }
}
