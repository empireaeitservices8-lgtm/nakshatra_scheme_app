import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_build_methods.dart';
import '../../../widgets/nakshathra_logo.dart';
import '../../create_account/view/create_account_screen.dart';
import '../../home/view/home_screen.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  bool _obscureOtp = true;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() async {
    FocusScope.of(context).unfocus();
    final success = await _viewModel.sendOtp();
    if (!mounted) return;

    if (success) {
      showToast("OTP sent successfully to +91 ${_viewModel.phoneController.text}");
      _otpFocusNode.requestFocus();
    }
  }

  void _onVerifyOtpPressed() async {
    FocusScope.of(context).unfocus();
    final success = await _viewModel.verifyOtp();
    if (!mounted) return;

    if (success) {
      showToast("Signed in successfully!");
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.routeName,
        (route) => false,
      );
    }
  }

  void _onResendOtpPressed() async {
    final success = await _viewModel.resendOtp();
    if (!mounted) return;

    if (success) {
      showToast("OTP resent successfully to +91 ${_viewModel.phoneController.text}");
      _otpFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: const Color(0xFF070B14),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF080E1C),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF090F1D),
                  Color(0xFF0D1627),
                  Color(0xFF080D18),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Consumer<LoginViewModel>(
                          builder: (context, viewModel, _) {
                            return Column(
                              children: [
                                const SizedBox(height: 28),

                                // Top Brand Logo & Header
                                const NakshathraBrandHeader(width: 190),

                                const SizedBox(height: 22),

                                // Title & Subtitle based on step
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: viewModel.isPhoneStep
                                      ? const Column(
                                          key: ValueKey("phone_header"),
                                          children: [
                                            Text(
                                              "Welcome to Nakshathra",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 23,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                                fontFamily: 'OpenSans',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Sign in with OTP to access your gold schemes",
                                              style: TextStyle(
                                                color: Color(0xFF8B9AAF),
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'OpenSans',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      : const Column(
                                          key: ValueKey("otp_header"),
                                          children: [
                                            Text(
                                              "Verify Mobile Number",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 23,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                                fontFamily: 'OpenSans',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Enter the 6-digit code sent to your phone",
                                              style: TextStyle(
                                                color: Color(0xFF8B9AAF),
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'OpenSans',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                ),

                                const SizedBox(height: 28),

                                // Auth Card (Phone Input or OTP Verification)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: viewModel.isPhoneStep
                                      ? _buildPhoneStepCard(context, viewModel)
                                      : _buildOtpStepCard(context, viewModel),
                                ),

                                const SizedBox(height: 24),

                                // Bottom Links
                                _buildBottomLinks(context),

                                const Spacer(),

                                // Security / Trust Badge
                                _buildTrustBadge(),

                                const SizedBox(height: 18),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: Phone Number Input Card
  Widget _buildPhoneStepCard(BuildContext context, LoginViewModel viewModel) {
    return Container(
      key: const ValueKey("phone_card"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1C273A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // SECURE LOGIN header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MOBILE AUTHENTICATION",
                style: TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  fontFamily: 'OpenSans',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B869).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFE5B869),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "FAST & SECURE",
                      style: TextStyle(
                        color: Color(0xFFE5B869),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Label
          const Text(
            "Enter Phone Number",
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),

          const SizedBox(height: 8),

          // Mobile Number Input Field with Flag
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF161F30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: viewModel.errorMessage != null
                    ? const Color(0xFFF87171)
                    : const Color(0xFF253347),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Flag & Country Code
                _buildFlagBadge(),
                const SizedBox(width: 8),
                const Text(
                  "+91",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 22,
                  color: const Color(0xFF2D3C52),
                ),
                const SizedBox(width: 12),

                // Phone TextField
                Expanded(
                  child: TextField(
                    controller: viewModel.phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      IndianPhoneNumberFormatter(),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenSans',
                    ),
                    cursorColor: const Color(0xFFE5B869),
                    decoration: const InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      hintText: "98765 43210",
                      hintStyle: TextStyle(
                        color: Color(0xFF556882),
                        fontSize: 14.5,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'OpenSans',
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => viewModel.clearError(),
                    onSubmitted: (_) => _onSendOtpPressed(),
                  ),
                ),

                // Phone Icon
                const Icon(
                  Icons.phone_android_rounded,
                  color: Color(0xFF7A8B9E),
                  size: 20,
                ),
              ],
            ),
          ),

          // Error banner
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(viewModel.errorMessage!),
          ],

          const SizedBox(height: 22),

          // SEND OTP Button
          _buildActionButton(
            text: "GET OTP",
            isLoading: viewModel.isLoading,
            onPressed: _onSendOtpPressed,
          ),

          const SizedBox(height: 14),

          // Helper note
          Center(
            child: Text(
              "An SMS with a 6-digit OTP will be sent to your number",
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                fontFamily: 'OpenSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: OTP Verification Card
  Widget _buildOtpStepCard(BuildContext context, LoginViewModel viewModel) {
    final phone = viewModel.phoneController.text.trim();

    return Container(
      key: const ValueKey("otp_card"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1C273A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with back / change number button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ENTER 6-DIGIT OTP",
                style: TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  fontFamily: 'OpenSans',
                ),
              ),
              GestureDetector(
                onTap: viewModel.changePhoneNumber,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162133),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF263650),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFE5B869),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Edit Number",
                        style: TextStyle(
                          color: Color(0xFFE5B869),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sent to number chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF151E2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF223147),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF7A8B9E),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Code sent to +91 $phone",
                    style: const TextStyle(
                      color: Color(0xFFD3DFEE),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // OTP Visual Input
          _buildOtpInputField(viewModel),

          // Error banner
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(viewModel.errorMessage!),
          ],

          const SizedBox(height: 18),

          // Resend Timer & Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Didn't receive the OTP?",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12.5,
                  fontFamily: 'OpenSans',
                ),
              ),
              viewModel.canResendOtp
                  ? GestureDetector(
                      onTap: viewModel.isLoading ? null : _onResendOtpPressed,
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Color(0xFFE5B869),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Color(0xFF8B9AAF),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Resend in 00:${viewModel.resendCountdown.toString().padLeft(2, '0')}s",
                          style: const TextStyle(
                            color: Color(0xFF8B9AAF),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ),
            ],
          ),

          const SizedBox(height: 24),

          // VERIFY & SIGN IN Button
          _buildActionButton(
            text: "VERIFY & CONTINUE",
            isLoading: viewModel.isLoading,
            onPressed: _onVerifyOtpPressed,
          ),
        ],
      ),
    );
  }

  /// 6-digit styled OTP Input Field with masked characters and visibility toggle
  Widget _buildOtpInputField(LoginViewModel viewModel) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: viewModel.errorMessage != null
              ? const Color(0xFFF87171)
              : const Color(0xFF253347),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Balances the trailing eye toggle icon so digits stay perfectly centered
          const SizedBox(width: 32),
          Expanded(
            child: TextField(
              controller: viewModel.otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              obscureText: _obscureOtp,
              obscuringCharacter: '•',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(
                color: Colors.white,
                fontSize: _obscureOtp ? 24 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: _obscureOtp ? 14 : 12,
                fontFamily: 'OpenSans',
              ),
              cursorColor: const Color(0xFFE5B869),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                hintText: _obscureOtp ? "••••••" : "000000",
                hintStyle: TextStyle(
                  color: const Color(0xFF556882),
                  fontSize: _obscureOtp ? 24 : 20,
                  letterSpacing: _obscureOtp ? 14 : 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                viewModel.clearError();
                if (val.length == 6) {
                  _onVerifyOtpPressed();
                }
              },
              onSubmitted: (_) => _onVerifyOtpPressed(),
            ),
          ),
          // Visibility toggle button
          IconButton(
            icon: Icon(
              _obscureOtp
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF7A8B9E),
              size: 20,
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: _obscureOtp ? "Show OTP" : "Hide OTP",
            onPressed: () {
              setState(() {
                _obscureOtp = !_obscureOtp;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String msg) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFF87171),
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            msg,
            style: const TextStyle(
              color: Color(0xFFF87171),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlagBadge() {
    return Container(
      width: 22,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Saffron top band
          Expanded(child: Container(color: const Color(0xFFFF9933))),
          // White middle band with navy blue chakra dot
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF000080),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Green bottom band
          Expanded(child: Container(color: const Color(0xFF138808))),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7E294),
            Color(0xFFE2B755),
            Color(0xFFC79532),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A346).withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF111724),
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF111724),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontFamily: 'OpenSans',
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(CreateAccountScreen.routeName);
            },
            behavior: HitTestBehavior.opaque,
            child: const Text(
              "Create Account",
              style: TextStyle(
                color: Color(0xFFE5B869),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: Colors.white.withOpacity(0.35),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          "256-bit SSL Encrypted • 100% Secure",
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11.5,
            letterSpacing: 0.5,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }
}
