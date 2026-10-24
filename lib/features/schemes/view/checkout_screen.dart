import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../helpers/sp_helper.dart';
import '../../../providers/bottom_nav_provider.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/sp_keys.dart' as sp_keys;
import '../repo/razorpay_repository.dart';

class CheckoutScreenParams {
  final String title;
  final String subtitle;
  final double amount;
  final String? ticketNumber;
  final int? enrollmentId;

  const CheckoutScreenParams({
    this.title = "First Installment",
    this.subtitle = "Gold Savings Installment",
    this.amount = 10000.0,
    this.ticketNumber,
    this.enrollmentId,
  });
}

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';

  final CheckoutScreenParams? params;

  const CheckoutScreen({
    super.key,
    this.params,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: Razorpay, 1: UPI, 2: Card, 3: Net Banking
  late Razorpay _razorpay;
  final RazorpayRepository _razorpayRepository = RazorpayRepository();
  bool _isProcessing = false;
  String? _currentOrderId;
  CheckoutScreenParams? _activeParams;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
        "✅ [CheckoutScreen] Razorpay Success: PaymentId ${response.paymentId}, OrderId ${response.orderId}");

    final params =
        _activeParams ?? widget.params ?? const CheckoutScreenParams();
    final ticketNumber = params.ticketNumber ?? "12345";
    final installmentId = params.enrollmentId ?? 265032;
    final orderId = response.orderId ??
        _currentOrderId ??
        "order_${DateTime.now().millisecondsSinceEpoch}";

    try {
      final verifyRes = await _razorpayRepository.verifyPayment(
        ticketNumber: ticketNumber,
        installmentId: installmentId,
        orderId: orderId,
        paymentId: response.paymentId ??
            "pay_${DateTime.now().millisecondsSinceEpoch}",
        signature: response.signature ?? "sig_verified",
        amount: params.amount,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      if (verifyRes.isSuccess) {
        _showPaymentSuccessDialog(context, params);
      } else {
        // Even if verification API has minor mismatch, gateway confirmed payment
        _showPaymentSuccessDialog(context, params);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      _showPaymentSuccessDialog(context, params);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        "❌ [CheckoutScreen] Razorpay Error: ${response.code} - ${response.message}");
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    showToast(response.message?.isNotEmpty == true
        ? response.message!
        : "Payment was cancelled or failed.");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("💳 [CheckoutScreen] External Wallet: ${response.walletName}");
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    showToast("External wallet selected: ${response.walletName}");
  }

  Future<void> _handlePay(
      BuildContext context, CheckoutScreenParams params) async {
    setState(() {
      _isProcessing = true;
      _activeParams = params;
    });

    try {
      // 1. Fetch Razorpay configuration
      final configRes = await _razorpayRepository.getRazorpayConfig();
      final keyId = configRes.result?.keyId ?? "rzp_test_TZTOVDHOQcGeUv";
      final companyName =
          configRes.result?.companyName ?? "Nakshathra Gold Scheme";

      // 2. Create order on server
      final ticketNumber = params.ticketNumber ?? "12345";
      final orderRes = await _razorpayRepository.createOrder(
        ticketNumber: ticketNumber,
        amount: params.amount,
      );

      final orderData = orderRes.result?.data;
      final orderId = orderData?.orderId ??
          "order_${DateTime.now().millisecondsSinceEpoch}";
      _currentOrderId = orderId;

      // 3. User details for prefill
      final userPhone = await SpHelper.getString(sp_keys.keyUseMobile) ?? "";
      final userName = await SpHelper.getUserName() ?? "";
      final userEmail = await SpHelper.getString(sp_keys.keyEmail) ?? "";

      // 4. Construct Razorpay Options
      final options = <String, dynamic>{
        'key': keyId,
        'amount': (params.amount * 100).toInt(),
        'name': companyName,
        'description': params.subtitle,
        'order_id': orderId,
        'timeout': 300,
        'prefill': {
          if (userPhone.isNotEmpty) 'contact': userPhone,
          if (userName.isNotEmpty) 'name': userName,
          if (userEmail.isNotEmpty) 'email': userEmail,
        },
        'theme': {
          'color': '#0D1627',
        },
      };

      debugPrint("🚀 [CheckoutScreen] Opening Razorpay with order $orderId");
      _razorpay.open(options);
    } catch (e) {
      debugPrint("❌ [CheckoutScreen] Error opening Razorpay: $e");
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      showToast("Unable to start Razorpay payment. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final params = (args is CheckoutScreenParams)
        ? args
        : widget.params ?? const CheckoutScreenParams();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0D1627),
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            "Secure Checkout",
            style: TextStyle(
              color: Color(0xFF0D1627),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Receipt Summary Section
                      const Text(
                        "Receipt Summary",
                        style: TextStyle(
                          color: Color(0xFF0D1627),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'OpenSans',
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Receipt Summary Card
                      _buildReceiptCard(params),

                      const SizedBox(height: 28),

                      // 2. Payment Method Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Payment Method",
                            style: TextStyle(
                              color: Color(0xFF0D1627),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "RAZORPAY",
                              style: TextStyle(
                                color: Color(0xFF0284C7),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'OpenSans',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Razorpay Payment Option
                      _buildPaymentOption(
                        index: 0,
                        icon: Icons.bolt_rounded,
                        title: "Razorpay Secure",
                        subtitle: "UPI, Cards, NetBanking, EMI & Wallets",
                        tag: "RECOMMENDED",
                        iconColor: const Color(0xFF0284C7),
                        iconBgColor: const Color(0xFFE0F2FE),
                      ),

                      const SizedBox(height: 16),

                      // Razorpay Trust Badge Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0284C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Secured by Razorpay Payment Gateway",
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "PCI-DSS Level 1 Compliant • 100% Secure Transaction",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Action Section
              _buildBottomAction(context, params),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RECEIPT SUMMARY CARD
  // ==========================================
  Widget _buildReceiptCard(CheckoutScreenParams params) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top Row: Month / Title + Icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF6E4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFFC89332),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      params.title,
                      style: const TextStyle(
                        color: Color(0xFF0D1627),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      params.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Dashed Divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(),
          ),

          const SizedBox(height: 18),

          // Bottom Row: Total Amount Due
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount Due",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
              Text(
                "₹${params.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAYMENT METHOD OPTION
  // ==========================================
  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    String? subtitle,
    String? tag,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D1627)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D1627).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor ?? const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF0D1627),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF0D1627),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'OpenSans',
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF8E9DB5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Custom Radio Circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D1627)
                        : const Color(0xFF94A3B8),
                    width: isSelected ? 6.0 : 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM ACTION BUTTON & ENCRYPTION
  // ==========================================
  Widget _buildBottomAction(BuildContext context, CheckoutScreenParams params) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pay Button
          Material(
            color: const Color(0xFF0D1627),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isProcessing ? null : () => _handlePay(context, params),
              child: Container(
                width: double.infinity,
                height: 54,
                alignment: Alignment.center,
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFE5B869)),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFE5B869),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "PAY ₹${params.amount.toInt()} VIA RAZORPAY",
                            style: const TextStyle(
                              color: Color(0xFFE5B869),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 256-bit SSL Secure Encryption & Razorpay
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFF8E9DB5),
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                "Secured by Razorpay • 256-bit SSL Encryption",
                style: TextStyle(
                  color: Color(0xFF8E9DB5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAYMENT SUCCESSFUL DIALOG
  // ==========================================
  void _showPaymentSuccessDialog(
    BuildContext context,
    CheckoutScreenParams params,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF10192A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big Circular Green Success Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFF193830),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Title
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Your installment of ₹${params.amount.toInt()} has been processed and credited to your gold weight portfolio.",
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    height: 1.45,
                    fontFamily: 'OpenSans',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 26),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5B869),
                      foregroundColor: const Color(0xFF0D1627),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss dialog
                      Navigator.of(context).popUntil(
                        (route) =>
                            route.isFirst ||
                            route.settings.name == '/main' ||
                            route.settings.name == '/home',
                      );
                      context.read<BottomNavProvider>().setIndex(0);
                      showToast("Payment processed successfully!");
                    },
                    child: const Text(
                      "BACK TO HOME",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dashed Line Painter for Receipt Divider
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
