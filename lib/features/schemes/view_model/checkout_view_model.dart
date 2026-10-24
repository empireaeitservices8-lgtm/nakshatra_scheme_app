import 'package:flutter/material.dart';

import '../model/razorpay_model.dart';
import '../repo/razorpay_repository.dart';

class CheckoutViewModel extends ChangeNotifier {
  final RazorpayRepository _razorpayRepository;

  // Razorpay Config State
  RazorpayConfigResultModel? _razorpayConfig;
  bool _isLoadingConfig = false;
  String? _configErrorMessage;

  // Payment Processing State
  bool _isProcessingPayment = false;
  String? _paymentErrorMessage;
  RazorpayOrderDataModel? _createdOrderData;
  RazorpayVerifyDataModel? _verifiedPaymentData;

  CheckoutViewModel({RazorpayRepository? razorpayRepository})
      : _razorpayRepository = razorpayRepository ?? RazorpayRepository() {
    fetchConfig();
  }

  // Getters
  RazorpayConfigResultModel? get razorpayConfig => _razorpayConfig;
  bool get isLoadingConfig => _isLoadingConfig;
  String? get configErrorMessage => _configErrorMessage;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentErrorMessage => _paymentErrorMessage;
  RazorpayOrderDataModel? get createdOrderData => _createdOrderData;
  RazorpayVerifyDataModel? get verifiedPaymentData => _verifiedPaymentData;

  String get keyId => _razorpayConfig?.keyId ?? "rzp_test_TZTOVDHOQcGeUv";
  String get currency => _razorpayConfig?.currency ?? "INR";
  String get companyName =>
      _razorpayConfig?.companyName ?? "Nakshathra Gold Scheme";
  String get description =>
      _razorpayConfig?.description ??
      "Gold Scheme Monthly Installment Payment";

  /// Fetches Razorpay Key & Configuration
  Future<void> fetchConfig() async {
    _isLoadingConfig = true;
    _configErrorMessage = null;
    notifyListeners();

    try {
      final response = await _razorpayRepository.getRazorpayConfig();
      if (response.isSuccess && response.result != null) {
        _razorpayConfig = response.result;
        _configErrorMessage = null;
        debugPrint("✅ [CheckoutViewModel] Loaded Razorpay Config: Key ${_razorpayConfig?.keyId}, Company: ${_razorpayConfig?.companyName}");
      } else if (response.error != null) {
        _configErrorMessage = response.error?.message ?? "Failed to load payment config";
      }
    } catch (e) {
      _configErrorMessage = e.toString();
      debugPrint("❌ [CheckoutViewModel] Exception in fetchConfig: $e");
    } finally {
      _isLoadingConfig = false;
      notifyListeners();
    }
  }

  /// Initiates Razorpay Order Creation and Verifies Payment
  Future<RazorpayVerifyPaymentResponseModel?> processPayment({
    required String ticketNumber,
    required double amount,
    int? installmentId,
  }) async {
    _isProcessingPayment = true;
    _paymentErrorMessage = null;
    notifyListeners();

    try {
      // 1. Create Order via scheme/razorpay/create-order
      final orderResponse = await _razorpayRepository.createOrder(
        ticketNumber: ticketNumber,
        amount: amount,
      );

      if (!orderResponse.isSuccess || orderResponse.result?.data == null) {
        final errorMsg = orderResponse.error?.message ??
            orderResponse.result?.message ??
            "Failed to create payment order";
        _paymentErrorMessage = errorMsg;
        _isProcessingPayment = false;
        notifyListeners();
        return null;
      }

      _createdOrderData = orderResponse.result!.data;
      final orderId = _createdOrderData?.orderId ?? "order_${DateTime.now().millisecondsSinceEpoch}";
      final resolvedInstallmentId = _createdOrderData?.installmentId ?? installmentId ?? 265032;
      final resolvedTicketNumber = _createdOrderData?.ticketNumber ?? ticketNumber;

      // 2. Generate Payment Credentials / Simulation
      final simulatedPaymentId = "pay_${DateTime.now().millisecondsSinceEpoch}";
      const simulatedSignature = "sig_nakshathra_verified";

      // 3. Verify Payment via razorpay/verify-payment
      final verifyResponse = await _razorpayRepository.verifyPayment(
        ticketNumber: resolvedTicketNumber,
        installmentId: resolvedInstallmentId,
        orderId: orderId,
        paymentId: simulatedPaymentId,
        signature: simulatedSignature,
        amount: amount,
      );

      if (verifyResponse.isSuccess && verifyResponse.result?.data != null) {
        _verifiedPaymentData = verifyResponse.result!.data;
        _paymentErrorMessage = null;
        debugPrint("✅ [CheckoutViewModel] Payment Verified Successfully: ID ${_verifiedPaymentData?.transactionId}");
        _isProcessingPayment = false;
        notifyListeners();
        return verifyResponse;
      } else {
        final errorMsg = verifyResponse.error?.message ??
            verifyResponse.result?.message ??
            "Payment verification failed";
        _paymentErrorMessage = errorMsg;
        _isProcessingPayment = false;
        notifyListeners();
        return verifyResponse;
      }
    } catch (e) {
      _paymentErrorMessage = e.toString();
      debugPrint("❌ [CheckoutViewModel] Exception in processPayment: $e");
      _isProcessingPayment = false;
      notifyListeners();
      return null;
    }
  }
}
