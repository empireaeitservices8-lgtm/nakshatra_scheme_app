import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/urls.dart';
import '../model/razorpay_model.dart';

class RazorpayRepository {
  final Dio _dio;

  RazorpayRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// 1. Fetches Razorpay Configuration from /razorpay/config or api/scheme/razorpay/config
  Future<RazorpayConfigResponseModel> getRazorpayConfig() async {
    final requestBody = RazorpayConfigRequestModel().toJson();

    debugPrint("===> [RazorpayRepository] Request to $urlSchemeRazorpayConfig: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      Response response;
      try {
        response = await _dio.post(
          urlSchemeRazorpayConfig,
          data: requestBody,
          options: Options(headers: headers),
        );
      } on DioException catch (dioError) {
        // Fallback to /razorpay/config or api/razorpay/config if 404
        if (dioError.response?.statusCode == 404) {
          final fallbackUrl = "${urlBase}razorpay/config";
          debugPrint("🔄 [RazorpayRepository] Trying fallback URL: $fallbackUrl");
          response = await _dio.post(
            fallbackUrl,
            data: requestBody,
            options: Options(headers: headers),
          );
        } else {
          rethrow;
        }
      }

      debugPrint("<=== [RazorpayRepository] Config status: ${response.statusCode}");
      debugPrint("<=== [RazorpayRepository] Config data: ${response.data}");

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

      return RazorpayConfigResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [RazorpayRepository] Config DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return RazorpayConfigResponseModel.fromJson(errorMap);
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

      return RazorpayConfigResponseModel(
        error: RazorpayErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [RazorpayRepository] Unexpected error in getRazorpayConfig: $e");
      return RazorpayConfigResponseModel(
        error: RazorpayErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// 2. Creates a Razorpay Order via scheme/razorpay/create-order
  Future<RazorpayCreateOrderResponseModel> createOrder({
    required String ticketNumber,
    required double amount,
  }) async {
    final requestBody = RazorpayCreateOrderRequestModel(
      params: RazorpayCreateOrderParams(
        ticketNumber: ticketNumber,
        amount: amount,
      ),
    ).toJson();

    debugPrint("===> [RazorpayRepository] Request to $urlSchemeRazorpayCreateOrder: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      Response response;
      try {
        response = await _dio.post(
          urlSchemeRazorpayCreateOrder,
          data: requestBody,
          options: Options(headers: headers),
        );
      } on DioException catch (dioError) {
        if (dioError.response?.statusCode == 404) {
          final fallbackUrl = "${urlBase}scheme/razorpay/create-order";
          debugPrint("🔄 [RazorpayRepository] Trying fallback URL: $fallbackUrl");
          response = await _dio.post(
            fallbackUrl,
            data: requestBody,
            options: Options(headers: headers),
          );
        } else {
          rethrow;
        }
      }

      debugPrint("<=== [RazorpayRepository] Create order status: ${response.statusCode}");
      debugPrint("<=== [RazorpayRepository] Create order data: ${response.data}");

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

      return RazorpayCreateOrderResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [RazorpayRepository] Create Order DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return RazorpayCreateOrderResponseModel.fromJson(errorMap);
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

      return RazorpayCreateOrderResponseModel(
        error: RazorpayErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [RazorpayRepository] Unexpected error in createOrder: $e");
      return RazorpayCreateOrderResponseModel(
        error: RazorpayErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// 3. Verifies Razorpay Payment via razorpay/verify-payment
  Future<RazorpayVerifyPaymentResponseModel> verifyPayment({
    required String ticketNumber,
    required int installmentId,
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
  }) async {
    final requestBody = RazorpayVerifyPaymentRequestModel(
      params: RazorpayVerifyPaymentParams(
        ticketNumber: ticketNumber,
        installmentId: installmentId,
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        amount: amount,
      ),
    ).toJson();

    debugPrint("===> [RazorpayRepository] Request to $urlSchemeRazorpayVerifyPayment: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      Response response;
      try {
        response = await _dio.post(
          urlSchemeRazorpayVerifyPayment,
          data: requestBody,
          options: Options(headers: headers),
        );
      } on DioException catch (dioError) {
        if (dioError.response?.statusCode == 404) {
          final fallbackUrl = "${urlBase}razorpay/verify-payment";
          debugPrint("🔄 [RazorpayRepository] Trying fallback URL: $fallbackUrl");
          response = await _dio.post(
            fallbackUrl,
            data: requestBody,
            options: Options(headers: headers),
          );
        } else {
          rethrow;
        }
      }

      debugPrint("<=== [RazorpayRepository] Verify payment status: ${response.statusCode}");
      debugPrint("<=== [RazorpayRepository] Verify payment data: ${response.data}");

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

      return RazorpayVerifyPaymentResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [RazorpayRepository] Verify Payment DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return RazorpayVerifyPaymentResponseModel.fromJson(errorMap);
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

      return RazorpayVerifyPaymentResponseModel(
        error: RazorpayErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [RazorpayRepository] Unexpected error in verifyPayment: $e");
      return RazorpayVerifyPaymentResponseModel(
        error: RazorpayErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }
}
