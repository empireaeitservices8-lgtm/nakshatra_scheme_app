import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../widgets/nakshathra_logo.dart';
import '../../login/view/login_screen.dart';
import '../view_model/create_account_view_model.dart';

class CreateAccountScreen extends StatefulWidget {
  static const String routeName = '/create-account';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final CreateAccountViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateAccountViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    final success = await _viewModel.registerSchemeAccount();
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF131A29),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE5B869), width: 1.2),
          ),
          title: const Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFE5B869), size: 28),
              SizedBox(width: 10),
              Text(
                "Registration Successful",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
          content: Text(
            "Welcome to Nakshathra Gold Scheme! Your account has been registered for ${_viewModel.selectedScheme.name}. You can now sign in to manage your gold portfolio.",
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13.5,
              fontFamily: 'OpenSans',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B869),
                foregroundColor: const Color(0xFF0F1420),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                "GO TO SIGN IN",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateAccountViewModel>.value(
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
              child: Column(
                children: [
                  // App Bar / Top Navigation
                  _buildTopBar(context),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          // Brand Header
                          const NakshathraBrandHeader(),

                          const SizedBox(height: 24),

                          // Title & Subtitle
                          Text(
                            "Scheme Registration",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              fontFamily: 'OpenSans',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Start your gold investment journey today",
                            style: TextStyle(
                              color: Color(0xFF909BB0),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'OpenSans',
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Main Registration Card
                          _buildRegistrationCard(context),

                          const SizedBox(height: 24),

                          // Bottom Sign In Navigation
                          _buildBottomSignInLink(context),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFE5B869),
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF131A29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222C3E)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: Color(0xFFE5B869), size: 14),
                SizedBox(width: 6),
                Text(
                  "100% BIS Hallmarked",
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
          const SizedBox(width: 48), // Balancing width for back button
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context) {
    return Consumer<CreateAccountViewModel>(
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
              // Gold Header Badge
              const Text(
                "NEW MEMBER ENROLLMENT",
                style: TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  fontFamily: 'OpenSans',
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Personal Information
              _buildSectionTitle("PERSONAL DETAILS"),
              const SizedBox(height: 10),

              // Full Name Field
              _buildInputField(
                controller: viewModel.nameController,
                hintText: "Full Name (as per Aadhaar/PAN)",
                icon: Icons.person_outline_rounded,
                onChanged: (_) => viewModel.clearError(),
              ),

              const SizedBox(height: 14),

              // Phone Number Field with Country Code & Flag
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
                    _buildFlagBadge(),
                    const SizedBox(width: 8),
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
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF8896AB),
                      size: 20,
                    ),
                    Container(
                      height: 22,
                      width: 1,
                      color: const Color(0xFF2E3D56),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
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
                          hintText: "Mobile Number",
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

              const SizedBox(height: 14),

              // Email Field (Optional)
              _buildInputField(
                controller: viewModel.emailController,
                hintText: "Email Address (Optional)",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => viewModel.clearError(),
              ),

              const SizedBox(height: 22),

              // Section 2: Scheme Plan Selection
              _buildSectionTitle("SELECT GOLD SCHEME"),
              const SizedBox(height: 10),

              // Scheme Dropdown Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF28344A),
                    width: 1.1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SchemeOption>(
                    value: viewModel.selectedScheme,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A2234),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFE5B869),
                    ),
                    items: viewModel.availableSchemes.map((scheme) {
                      return DropdownMenuItem<SchemeOption>(
                        value: scheme,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              color: Color(0xFFE5B869),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${scheme.name} (${scheme.duration})",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                  Text(
                                    scheme.description,
                                    style: const TextStyle(
                                      color: Color(0xFF8896AB),
                                      fontSize: 11,
                                      fontFamily: 'OpenSans',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (scheme) {
                      if (scheme != null) {
                        viewModel.selectScheme(scheme);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Monthly Installment Amount Label
              const Text(
                "Monthly Installment Amount (₹)",
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 8),

              // Quick Amount Preset Chips
              Row(
                children: List.generate(viewModel.presetAmounts.length, (index) {
                  final amount = viewModel.presetAmounts[index];
                  final isSelected = viewModel.selectedAmountIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < viewModel.presetAmounts.length - 1 ? 6 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => viewModel.selectPresetAmount(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE5B869)
                                : const Color(0xFF1A2234),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE5B869)
                                  : const Color(0xFF28344A),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "₹$amount",
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0F1420)
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),

              // Custom Amount Input
              _buildInputField(
                controller: viewModel.amountController,
                hintText: "Enter installment amount (Min ₹500)",
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  viewModel.clearError();
                },
              ),

              const SizedBox(height: 22),

              // Section 3: Security & Password
              _buildSectionTitle("SECURITY"),
              const SizedBox(height: 10),

              // Password Field
              _buildPasswordField(
                controller: viewModel.passwordController,
                hintText: "Create Password (min 6 chars)",
                isVisible: viewModel.isPasswordVisible,
                onToggleVisibility: viewModel.togglePasswordVisibility,
                onChanged: (_) => viewModel.clearError(),
              ),

              const SizedBox(height: 14),

              // Confirm Password Field
              _buildPasswordField(
                controller: viewModel.confirmPasswordController,
                hintText: "Confirm Password",
                isVisible: viewModel.isConfirmPasswordVisible,
                onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
                onChanged: (_) => viewModel.clearError(),
              ),

              const SizedBox(height: 22),

              // Section 4: Nominee Details (Optional)
              _buildSectionTitle("NOMINEE DETAILS (OPTIONAL)"),
              const SizedBox(height: 10),

              _buildInputField(
                controller: viewModel.nomineeNameController,
                hintText: "Nominee Name",
                icon: Icons.family_restroom_rounded,
                onChanged: (_) => viewModel.clearError(),
              ),

              const SizedBox(height: 16),

              // Terms & Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: viewModel.agreedToTerms,
                      onChanged: viewModel.toggleTermsAgreement,
                      activeColor: const Color(0xFFE5B869),
                      checkColor: const Color(0xFF0F1420),
                      side: const BorderSide(color: Color(0xFF5E6E87), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.toggleTermsAgreement(!viewModel.agreedToTerms),
                      child: const Text(
                        "I agree to Nakshathra Gold Savings Scheme Terms & Conditions and declare that all details provided are accurate.",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          height: 1.4,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Error Message
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 14),
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

              // Submit Action Button
              _buildRegisterButton(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFCBD5E1),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        fontFamily: 'OpenSans',
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
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
          Icon(icon, color: const Color(0xFF8896AB), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'OpenSans',
              ),
              cursorColor: const Color(0xFFE5B869),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF5E6E87),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OpenSans',
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
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
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF8896AB),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !isVisible,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'OpenSans',
              ),
              cursorColor: const Color(0xFFE5B869),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF5E6E87),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OpenSans',
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          GestureDetector(
            onTap: onToggleVisibility,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF8896AB),
                size: 20,
              ),
            ),
          ),
        ],
      ),
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
          Expanded(child: Container(color: const Color(0xFFFF9933))),
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
          Expanded(child: Container(color: const Color(0xFF138808))),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(CreateAccountViewModel viewModel) {
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
          onTap: viewModel.isLoading ? null : _onRegisterPressed,
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
                    "CREATE SCHEME ACCOUNT",
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

  Widget _buildBottomSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already enrolled in a scheme? ",
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'OpenSans',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          },
          behavior: HitTestBehavior.opaque,
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Color(0xFFE5B869),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ],
    );
  }
}
