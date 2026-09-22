import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_build_methods.dart';
import '../../login/view/login_screen.dart';
import '../model/support_faq_model.dart';
import '../model/transaction_receipt_model.dart';
import '../view/reset_password_screen.dart';
import '../view/support_faq_screen.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _faqSectionKey = GlobalKey();

  void _scrollToFaqSection() {
    final context = _faqSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        return RefreshIndicator(
          color: const Color(0xFFE5B869),
          onRefresh: () async {
            await Future.wait([
              viewModel.fetchSupportFaq(),
              viewModel.fetchTransactionReceipts(),
            ]);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 120, // space for floating bottom navbar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Screen Title
                const Text(
                  "Account Profile",
                  style: TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFamily: 'OpenSans',
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Main Profile Hero Card (Dark Navy)
                _buildHeroProfileCard(context, viewModel),

                const SizedBox(height: 28),

                // 3. Customer Support & FAQs Section (API Powered)
                Container(
                  key: _faqSectionKey,
                  child: _buildSupportFaqSection(context, viewModel),
                ),

                const SizedBox(height: 28),

                // 4. Transaction Receipts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Transaction Receipts",
                      style: TextStyle(
                        color: Color(0xFF0D1627),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    if (viewModel.isLoadingReceipts)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE5B869),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: viewModel.fetchTransactionReceipts,
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFF8E9DB5),
                          size: 20,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Transaction List (API-backed)
                if (viewModel.isLoadingReceipts)
                  ...[1, 2].map((_) => _buildReceiptShimmer())
                else if (viewModel.receiptItems.isEmpty &&
                    viewModel.receiptsErrorMessage != null)
                  _buildReceiptsError(viewModel)
                else if (viewModel.receiptItems.isEmpty)
                  _buildEmptyReceipts()
                else
                  ...viewModel.receiptItems.map(
                    (item) => _buildTransactionCard(context, item),
                  ),

                const SizedBox(height: 28),

                // 5. Security Settings Section
                const Text(
                  "Security Settings",
                  style: TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),

                const SizedBox(height: 14),

                // Security Settings Card
                _buildSecuritySettingsCard(context),

                const SizedBox(height: 28),

                // 6. Logout Securely Button
                _buildLogoutButton(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. HERO PROFILE CARD (DARK NAVY)
  // ==========================================
  Widget _buildHeroProfileCard(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1627).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // User Avatar & Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Gold Ring Border
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF142036),
                  border: Border.all(
                    color: const Color(0xFFE5B869),
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  viewModel.userInitials,
                  style: const TextStyle(
                    color: Color(0xFFE5B869),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${viewModel.memberId}",
                      style: const TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Member since: ${viewModel.memberSince}",
                      style: const TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Side-by-Side Gold Balance & Total Value Cards
          Row(
            children: [
              // Gold Balance Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF172338),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.formattedGoldBalance,
                        style: const TextStyle(
                          color: Color(0xFFE5B869),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Gold Balance",
                        style: TextStyle(
                          color: Color(0xFF8E9DB5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Total Value Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF172338),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.formattedTotalValue,
                        style: const TextStyle(
                          color: Color(0xFFE5B869),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Total Value",
                        style: TextStyle(
                          color: Color(0xFF8E9DB5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. CUSTOMER SUPPORT & FAQ SECTION (API)
  // ==========================================
  Widget _buildSupportFaqSection(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    final faqData = viewModel.supportFaq;
    final title = faqData?.title ?? "Customer Support & FAQ";
    final subtitle = faqData?.subtitle ??
        "Need help with your gold scheme account? Reach our executives instantly.";
    final hotline = faqData?.supportHotline;
    final helpdesk = faqData?.supportHelpdesk;
    final faqs = faqData?.faqs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'OpenSans',
              ),
            ),
            if (viewModel.isLoadingFaq)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE5B869),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF8E9DB5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans',
          ),
        ),

        const SizedBox(height: 16),

        // Quick Support Contact Channels Row
        Row(
          children: [
            // Hotline Card
            Expanded(
              child: _buildContactChannelCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF22C55E),
                iconBgColor: const Color(0xFFE8F8F0),
                title: hotline?.title ?? "Call Hotline",
                value: hotline?.displayText ?? hotline?.phoneNumber ?? "+971 4 123 4567",
                timing: hotline?.timing,
                onTap: () {
                  showToast("Dialing: ${hotline?.phoneNumber ?? '+971 4 123 4567'}");
                },
              ),
            ),

            const SizedBox(width: 12),

            // Helpdesk Email Card
            Expanded(
              child: _buildContactChannelCard(
                icon: Icons.mark_email_read_rounded,
                iconColor: const Color(0xFF38BDF8),
                iconBgColor: const Color(0xFFE0F2FE),
                title: helpdesk?.title ?? "Email Support",
                value: helpdesk?.displayText ?? helpdesk?.emailAddress ?? "support@nakshathragold.com",
                onTap: () {
                  showToast("Emailing: ${helpdesk?.emailAddress ?? 'support@nakshathragold.com'}");
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // FAQs Accordion List
        if (faqs.isNotEmpty)
          ...faqs.map((faq) => _buildFaqTile(context, viewModel, faq))
        else if (!viewModel.isLoadingFaq)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "No FAQs currently available.",
                style: TextStyle(
                  color: Color(0xFF8E9DB5),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactChannelCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    String? timing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (timing != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timing,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(
    BuildContext context,
    ProfileViewModel viewModel,
    FaqItemModel faq,
  ) {
    final faqId = faq.id ?? faq.question.hashCode;
    final isExpanded = viewModel.isFaqExpanded(faqId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? const Color(0xFFE5B869).withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? const Color(0xFFE5B869).withOpacity(0.06)
                : const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => viewModel.toggleFaq(faqId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            "Q",
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          faq.question ?? "Frequently Asked Question",
                          style: const TextStyle(
                            color: Color(0xFF0D1627),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isExpanded ? 0.5 : 0.0,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded && (faq.answer?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        faq.answer!,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. TRANSACTION CARD (API-backed)
  // ==========================================
  Widget _buildTransactionCard(
    BuildContext context,
    TransactionReceiptItem item,
  ) {
    final isCredit = item.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showToast("Receipt: ${item.title}");
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Direction icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCredit
                        ? const Color(0xFFE8F8F0)
                        : const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCredit
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isCredit
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Title & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF0D1627),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      if (item.paidDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.paidDate,
                          style: const TextStyle(
                            color: Color(0xFF8E9DB5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount + Download icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.amount,
                      style: TextStyle(
                        color: isCredit
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    if (item.downloadUrl != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => showToast("Downloading receipt..."),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_rounded,
                                color: Color(0xFF64748B),
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "PDF",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyReceipts() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "No transaction receipts found.",
          style: TextStyle(
            color: Color(0xFF8E9DB5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptsError(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.receiptsErrorMessage ?? "Failed to load receipts",
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
          TextButton(
            onPressed: viewModel.fetchTransactionReceipts,
            child: const Text(
              "Retry",
              style: TextStyle(
                color: Color(0xFFE5B869),
                fontWeight: FontWeight.w700,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. SECURITY SETTINGS CARD
  // ==========================================
  Widget _buildSecuritySettingsCard(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications_none_rounded,
            title: "Notification Preferences",
            onTap: () => showToast("Notification Preferences"),
            isFirst: true,
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 60,
            endIndent: 16,
            color: Color(0xFFF1F5F9),
          ),
          _buildSettingTile(
            icon: Icons.shield_outlined,
            title: "Identity PIN & Security",
            onTap: () =>
                Navigator.pushNamed(context, ResetPasswordScreen.routeName),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 60,
            endIndent: 16,
            color: Color(0xFFF1F5F9),
          ),
          _buildSettingTile(
            icon: Icons.help_outline_rounded,
            title: "Support Ticket & FAQ",
            onTap: () => Navigator.pushNamed(context, SupportFaqScreen.routeName),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF0D1627),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. LOG OUT SECURELY BUTTON
  // ==========================================
  Widget _buildLogoutButton(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: viewModel.isLoggingOut
                ? null
                : () async {
                    final response = await viewModel.logout();
                    if (!context.mounted) return;
                    showToast(
                        response.result?.message ?? "Successfully logged out");
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF87171),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: viewModel.isLoggingOut
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "LOG OUT SECURELY",
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
