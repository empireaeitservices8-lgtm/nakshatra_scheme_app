import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../widgets/nakshathra_logo.dart';
import '../../create_account/view/create_account_screen.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onSignInPressed() async {
    FocusScope.of(context).unfocus();
    final success = await _viewModel.signIn();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Signed in successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF1B8755),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF070B14),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF080E1C),
                  Color(0xFF0E1729),
                  Color(0xFF0A101D),
                  Color(0xFF060A13),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 36),

                            // Top Brand Logo & Header
                            const NakshathraBrandHeader(),

                            const SizedBox(height: 32),

                            // Title & Subtitle
                            Text(
                              "Nakshathra Gold",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontFamily: 'OpenSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Access your gold portfolio securely",
                              style: TextStyle(
                                color: Color(0xFF909BB0),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'OpenSans',
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Secure Login Card
                            _buildLoginCard(context),

                            const SizedBox(height: 28),

                            // Bottom Navigation Links
                            _buildBottomLinks(context),

                            const SizedBox(height: 24),
                          ],
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

  Widget _buildLoginCard(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF131A29).withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF222C3E),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
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
              // SECURE LOGIN header badge text
              const Text(
                "SECURE LOGIN",
                style: TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  fontFamily: 'OpenSans',
                ),
              ),

              const SizedBox(height: 20),

              // Phone Number Input Container
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF28344A),
                    width: 1.1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Indian Flag Badge
                    _buildFlagBadge(),
                    const SizedBox(width: 8),

                    // Country Code
                    Text(
                      viewModel.selectedCountryCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Chevron Down Icon
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF8896AB),
                      size: 20,
                    ),

                    // Divider Line
                    Container(
                      height: 22,
                      width: 1,
                      color: const Color(0xFF2E3D56),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    // Phone Number TextField
                    Expanded(
                      child: TextField(
                        controller: viewModel.phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                        cursorColor: const Color(0xFFE5B869),
                        decoration: const InputDecoration(
                          hintText: "Phone Number",
                          hintStyle: TextStyle(
                            color: Color(0xFF5E6E87),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'OpenSans',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => viewModel.clearError(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Password Input Container
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF28344A),
                    width: 1.1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Lock Icon
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF8896AB),
                      size: 20,
                    ),
                    const SizedBox(width: 12),

                    // Password TextField
                    Expanded(
                      child: TextField(
                        controller: viewModel.passwordController,
                        obscureText: !viewModel.isPasswordVisible,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                        cursorColor: const Color(0xFFE5B869),
                        decoration: const InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Color(0xFF5E6E87),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'OpenSans',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => viewModel.clearError(),
                        onSubmitted: (_) => _onSignInPressed(),
                      ),
                    ),

                    // Show / Hide Password Toggle
                    GestureDetector(
                      onTap: viewModel.togglePasswordVisibility,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          viewModel.isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF8896AB),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error message if any
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFF87171),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // SECURE SIGN IN Gold Button
              _buildSignInButton(viewModel),
            ],
          ),
        );
      },
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

  Widget _buildSignInButton(LoginViewModel viewModel) {
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
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: viewModel.isLoading ? null : _onSignInPressed,
          child: Center(
            child: viewModel.isLoading
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
                : const Text(
                    "SECURE SIGN IN",
                    style: TextStyle(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Forgot Password?
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Forgot Password tapped"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Color(0xFFE5B869),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
            ),
          ),

          // Create Account
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(CreateAccountScreen.routeName);
            },
            behavior: HitTestBehavior.opaque,
            child: Text(
              "Create Account",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
