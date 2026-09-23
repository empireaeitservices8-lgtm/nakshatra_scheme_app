import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/sp_helper.dart';
import '../../../utils/app_build_methods.dart';
import '../model/reset_password_model.dart';
import '../repo/profile_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/reset-password';

  final int? userId;

  const ResetPasswordScreen({
    super.key,
    this.userId,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ProfileRepository _repository = ProfileRepository();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _currentFocus = FocusNode();
  final FocusNode _newFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    _clearError();

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your current password";
      });
      _currentFocus.requestFocus();
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your new password";
      });
      _newFocus.requestFocus();
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = "New password must be at least 6 characters";
      });
      _newFocus.requestFocus();
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please confirm your new password";
      });
      _confirmFocus.requestFocus();
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "New passwords do not match";
      });
      _confirmFocus.requestFocus();
      return;
    }

    if (currentPassword == newPassword) {
      setState(() {
        _errorMessage = "New password cannot be the same as current password";
      });
      _newFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final userId = widget.userId ?? await SpHelper.getUserId() ?? 1;
      final response = await _repository.resetPassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final message = response.result?.message ?? "Password reset successfully.";
        setState(() {
          _isLoading = false;
          _successMessage = message;
        });

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        showToast(message);

        // Show brief success dialog or pop back after short delay
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.error?.message ??
              response.result?.message ??
              "Failed to reset password. Please verify your current password.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "An unexpected error occurred: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "Reset Password",
            style: TextStyle(
              color: Color(0xFF0D1627),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Shield Card
                _buildSecurityHeaderCard(),

                const SizedBox(height: 20),

                // Form Card
                _buildFormCard(),

                const SizedBox(height: 20),

                // Security Tips Card
                _buildSecurityTipsCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Header Security Card
  // ==========================================
  Widget _buildSecurityHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1627),
            Color(0xFF16233B),
            Color(0xFF0F1A2E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1627).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7E294),
                  Color(0xFFE5B869),
                  Color(0xFFC79532),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5B869).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Color(0xFF0D1627),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Security",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'OpenSans',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Update your password to keep your gold savings account safe & protected.",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Form Card
  // ==========================================
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1627).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Password label
          _buildFieldLabel("CURRENT PASSWORD"),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _currentPasswordController,
            focusNode: _currentFocus,
            hintText: "Enter current password",
            isVisible: _isCurrentPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
              });
            },
            onSubmitted: (_) => _newFocus.requestFocus(),
          ),

          const SizedBox(height: 18),

          // New Password label
          _buildFieldLabel("NEW PASSWORD"),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _newPasswordController,
            focusNode: _newFocus,
            hintText: "Enter new password (min 6 chars)",
            isVisible: _isNewPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
            onSubmitted: (_) => _confirmFocus.requestFocus(),
          ),

          const SizedBox(height: 18),

          // Confirm Password label
          _buildFieldLabel("CONFIRM NEW PASSWORD"),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmFocus,
            hintText: "Re-enter new password",
            isVisible: _isConfirmPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            onSubmitted: (_) => _handleResetPassword(),
          ),

          // Error Message Banner
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFF87171),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFF87171),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success Message Banner
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF4ADE80),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8E9DB5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        fontFamily: 'OpenSans',
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xFFE5B869)
              : const Color(0xFF253347),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF7A8B9E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: !isVisible,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'OpenSans',
              ),
              cursorColor: const Color(0xFFE5B869),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF556882),
                  fontSize: 13.5,
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
              onChanged: (_) => _clearError(),
              onSubmitted: onSubmitted,
            ),
          ),
          GestureDetector(
            onTap: onToggleVisibility,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF7A8B9E),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
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
          onTap: _isLoading ? null : _handleResetPassword,
          child: Center(
            child: _isLoading
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF111724),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "RESET PASSWORD",
                        style: TextStyle(
                          color: Color(0xFF111724),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Security Tips Card
  // ==========================================
  Widget _buildSecurityTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFD4A346),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Password Security Guidelines",
                style: TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem("At least 6 characters with a combination of letters & numbers"),
          const SizedBox(height: 6),
          _buildTipItem("Avoid easily guessable sequences like '123456' or birth years"),
          const SizedBox(height: 6),
          _buildTipItem("Never share your password or OTP credentials with anyone"),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(
            Icons.circle,
            size: 5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ],
    );
  }
}

/// Backward compatibility alias
typedef ChangePasswordScreen = ResetPasswordScreen;
