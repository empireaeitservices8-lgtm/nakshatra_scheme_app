import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/app_build_methods.dart';
import '../../../utils/url_launcher_helper.dart';
import '../model/support_faq_model.dart';
import '../repo/profile_repository.dart';

class SupportFaqScreen extends StatefulWidget {
  static const String routeName = '/support-faq';

  const SupportFaqScreen({super.key});

  @override
  State<SupportFaqScreen> createState() => _SupportFaqScreenState();
}

class _SupportFaqScreenState extends State<SupportFaqScreen> {
  final ProfileRepository _repository = ProfileRepository();
  SupportFaqDataModel? _supportFaq;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<int> _expandedFaqIds = {};

  @override
  void initState() {
    super.initState();
    _fetchSupportFaq();
  }

  Future<void> _fetchSupportFaq() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repository.getSupportFaq();
      if (response.isSuccess && response.result?.data != null) {
        setState(() {
          _supportFaq = response.result!.data;
          _isLoading = false;
          // Expand first FAQ by default if available
          if (_supportFaq!.faqs.isNotEmpty && _supportFaq!.faqs.first.id != null) {
            _expandedFaqIds.add(_supportFaq!.faqs.first.id!);
          }
        });
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? "Failed to load support & FAQ.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleFaq(int id) {
    setState(() {
      if (_expandedFaqIds.contains(id)) {
        _expandedFaqIds.remove(id);
      } else {
        _expandedFaqIds.add(id);
      }
    });
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
          title: Text(
            _supportFaq?.title ?? "Customer Support & FAQ",
            style: const TextStyle(
              color: Color(0xFF0D1627),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF0D1627),
                size: 22,
              ),
              onPressed: _fetchSupportFaq,
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE5B869),
        ),
      );
    }

    if (_errorMessage != null && _supportFaq == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE11D48),
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchSupportFaq,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1627),
                  foregroundColor: const Color(0xFFE5B869),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final title = _supportFaq?.title ?? "Customer Support & FAQ";
    final subtitle = _supportFaq?.subtitle ??
        "Need help with your gold scheme account? Reach our executives instantly.";
    final hotline = _supportFaq?.supportHotline;
    final helpdesk = _supportFaq?.supportHelpdesk;
    final faqs = _supportFaq?.faqs ?? [];

    final hotlinePhone = hotline?.phoneNumber ?? "+971 4 123 4567";
    final helpdeskEmail = helpdesk?.emailAddress ?? "support@nakshathragold.com";

    return RefreshIndicator(
      color: const Color(0xFFE5B869),
      onRefresh: _fetchSupportFaq,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Header
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8E9DB5),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                fontFamily: 'OpenSans',
              ),
            ),

            const SizedBox(height: 20),

            // Two Contact Action Cards (Side-by-side as shown in design)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Phone Hotline Card
                Expanded(
                  child: _buildContactChannelCard(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF22C55E),
                    iconBgColor: const Color(0xFFE8F8F0),
                    title: hotline?.title ?? "Call Support Hotline",
                    value: hotline?.displayText ?? "$hotlinePhone (9 AM - 9 PM)",
                    timing: hotline?.timing ?? "9 AM - 9 PM",
                    onTap: () {
                      UrlLauncherHelper.launchPhoneCaller(hotlinePhone);
                    },
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Email Helpdesk Card
                Expanded(
                  child: _buildContactChannelCard(
                    icon: Icons.mark_email_read_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    iconBgColor: const Color(0xFFE0F2FE),
                    title: helpdesk?.title ?? "Email Support Helpdesk",
                    value: helpdesk?.displayText ?? helpdeskEmail,
                    timing: null,
                    onTap: () {
                      UrlLauncherHelper.launchEmailClient(
                        helpdeskEmail,
                        subject: "Support Request - Nakshathra Gold Scheme",
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQs List Section
            if (faqs.isNotEmpty) ...[
              ...faqs.map((faq) => _buildFaqTile(faq)),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    "No FAQs currently available.",
                    style: TextStyle(
                      color: Color(0xFF8E9DB5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0D1627),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'OpenSans',
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'OpenSans',
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (timing != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5),
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

  Widget _buildFaqTile(FaqItemModel faq) {
    final faqId = faq.id ?? faq.question.hashCode;
    final isExpanded = _expandedFaqIds.contains(faqId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            onTap: () => _toggleFaq(faqId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Center(
                          child: Text(
                            "Q",
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 13,
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'OpenSans',
                            height: 1.3,
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
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
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
                          height: 1.45,
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
}
