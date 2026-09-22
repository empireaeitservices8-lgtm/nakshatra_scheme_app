import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/bottom_nav_provider.dart';
import '../../../utils/app_build_methods.dart';
import '../../home/view/home_screen.dart';

class CheckoutScreenParams {
  final String title;
  final String subtitle;
  final double amount;

  const CheckoutScreenParams({
    this.title = "First Installment",
    this.subtitle = "Gold Savings Installment",
    this.amount = 10000.0,
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
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: Net Banking

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

                      // 2. Choose Payment Method Section
                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(
                          color: Color(0xFF0D1627),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'OpenSans',
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Payment Methods List
                      _buildPaymentOption(
                        index: 0,
                        icon: Icons.account_balance_wallet_outlined,
                        title: "UPI (Google Pay, PhonePe)",
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        index: 1,
                        icon: Icons.credit_card_rounded,
                        title: "Credit / Debit Card",
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        index: 2,
                        icon: Icons.account_balance_rounded,
                        title: "Net Banking",
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
            color: const Color(0xFF0F172A).withOpacity(0.04),
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
                      color: const Color(0xFF0D1627).withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0D1627),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
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
              onTap: () {
                _showPaymentSuccessDialog(context, params);
              },
              child: Container(
                width: double.infinity,
                height: 54,
                alignment: Alignment.center,
                child: Text(
                  "PAY ₹${params.amount.toInt()} SECURELY",
                  style: const TextStyle(
                    color: Color(0xFFE5B869),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 256-bit SSL Secure Encryption
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF8E9DB5),
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                "256-bit SSL Secure Encryption",
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
