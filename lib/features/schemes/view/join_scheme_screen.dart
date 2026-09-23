import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/join_scheme_model.dart';
import '../view_model/join_scheme_view_model.dart';
import 'checkout_screen.dart';

class JoinSchemeScreen extends StatefulWidget {
  static const String routeName = '/join-scheme';

  final int initialSchemeType; // 0: Fixed Weight, 1: Value Based

  const JoinSchemeScreen({
    super.key,
    this.initialSchemeType = 0,
  });

  @override
  State<JoinSchemeScreen> createState() => _JoinSchemeScreenState();
}

class _JoinSchemeScreenState extends State<JoinSchemeScreen> {
  late int _selectedSchemeType; // 0: Fixed Weight, 1: Value Based
  double _monthlyBudget = 5000.0;
  int _selectedDurationIndex = 0; // 0: 11 Months, 1: 18 Months, 2: 24 Months
  final TextEditingController _nomineeController = TextEditingController();
  late final JoinSchemeViewModel _viewModel;

  final List<String> _durations = const ["11 Months", "18 Months", "24 Months"];
  final List<int> _durationMonths = const [11, 18, 24];
  final double _goldRatePerGram = 7500.0;

  @override
  void initState() {
    super.initState();
    _selectedSchemeType = widget.initialSchemeType;
    _viewModel = JoinSchemeViewModel();
  }

  @override
  void dispose() {
    _nomineeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  double get _estGramsPerMonth => _monthlyBudget / _goldRatePerGram;

  int get _selectedDuration => _durationMonths[_selectedDurationIndex];

  String get _schemeTypeString =>
      _selectedSchemeType == 0 ? "fixed_weight" : "maturity_bonus";

  double get _totalDeposit => _monthlyBudget * _selectedDuration;
  double get _bonusBenefit => _monthlyBudget; // 1 month bonus
  double get _totalMaturityValue => _totalDeposit + _bonusBenefit;

  Future<void> _handleJoinScheme() async {
    final nominee = _nomineeController.text.trim();
    if (nominee.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter nominee full name"),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Call Join Scheme API
    final response = await _viewModel.submitJoinScheme(
      schemeType: _schemeTypeString,
      monthlyInstallment: _monthlyBudget,
      duration: _selectedDuration,
      nominee: nominee,
    );

    if (!mounted) return;

    if (response != null && response.isSuccess) {
      final data = response.result?.data;
      final schemeTitle = _selectedSchemeType == 0
          ? "Fixed Weight Gold Savings"
          : "Value Based Gold Savings";
      final amountToPay = data?.firstInstallmentAmount?.toDouble() ?? _monthlyBudget;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.result?.message ?? "Scheme enrollment created successfully!",
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Navigate to Checkout Screen for paying first installment
      Navigator.pushReplacementNamed(
        context,
        CheckoutScreen.routeName,
        arguments: CheckoutScreenParams(
          title: "First Installment",
          subtitle: "$schemeTitle (${data?.duration ?? _selectedDuration} Months)",
          amount: amountToPay,
        ),
      );
    } else {
      final errorMsg = _viewModel.errorMessage ?? "Failed to join scheme. Please try again.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
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
                "Join New Scheme",
                style: TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 18,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Select Scheme Type
                          const Text(
                            "Select Scheme Type",
                            style: TextStyle(
                              color: Color(0xFF0D1627),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'OpenSans',
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Scheme Type Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildSchemeTypeCard(
                                  index: 0,
                                  title: "Fixed Weight",
                                  subtitle: "Gold weight hedge",
                                  icon: Icons.scale_rounded,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildSchemeTypeCard(
                                  index: 1,
                                  title: "Value Based",
                                  subtitle: "Redeem with bonus",
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 2. Calculator Card (Dynamically changes based on Fixed Weight vs Value Based)
                          _selectedSchemeType == 0
                              ? _buildFixedWeightCalculatorCard()
                              : _buildValueBasedCalculatorCard(),

                          // 3. New Section: Value Based Exclusive Benefits & Perks (Shown only for Value Based)
                          if (_selectedSchemeType == 1) ...[
                            const SizedBox(height: 24),
                            _buildValueBasedBenefitsSection(),
                          ],

                          const SizedBox(height: 24),

                          // 4. Duration (Months) Section
                          const Text(
                            "Duration (Months)",
                            style: TextStyle(
                              color: Color(0xFF0D1627),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'OpenSans',
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Duration Selector Pills
                          Row(
                            children: List.generate(
                              _durations.length,
                              (index) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index < _durations.length - 1 ? 10 : 0,
                                  ),
                                  child: _buildDurationPill(index),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 5. Nominee Details Section
                          const Text(
                            "Nominee Details",
                            style: TextStyle(
                              color: Color(0xFF0D1627),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'OpenSans',
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Nominee Input Field
                          _buildNomineeInput(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Join Button
                  _buildBottomButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. SCHEME TYPE SELECTION CARD
  // ==========================================
  Widget _buildSchemeTypeCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedSchemeType == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSchemeType = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D1627) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0D1627).withOpacity(0.08)
                  : const Color(0xFF0F172A).withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon Badge + Selection Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D1627) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? const Color(0xFFE5B869) : const Color(0xFF0D1627),
                      size: 20,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D1627),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 20, height: 20),
              ],
            ),

            const SizedBox(height: 14),

            // Scheme Title
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFamily: 'OpenSans',
              ),
            ),

            const SizedBox(height: 4),

            // Scheme Subtitle
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
        ),
      ),
    );
  }

  // ==========================================
  // 2A. FIXED WEIGHT CALCULATOR CARD (DARK NAVY)
  // ==========================================
  Widget _buildFixedWeightCalculatorCard() {
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          // Header Label
          const Text(
            "ESTIMATED GOLD ACCUMULATION",
            style: TextStyle(
              color: Color(0xFF8E9DB5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontFamily: 'OpenSans',
            ),
          ),

          const SizedBox(height: 14),

          // Accumulation Value Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF142036),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5B869).withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                "~${_estGramsPerMonth.toStringAsFixed(3)} grams / month",
                style: const TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Custom Slider
          _buildBudgetSlider(),

          // Slider Labels
          _buildBudgetSliderLabels(),
        ],
      ),
    );
  }

  // ==========================================
  // 2B. VALUE BASED CALCULATOR CARD (DARK NAVY)
  // ==========================================
  Widget _buildValueBasedCalculatorCard() {
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          // Header Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ESTIMATED MATURITY VALUE",
                style: TextStyle(
                  color: Color(0xFF8E9DB5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontFamily: 'OpenSans',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B869).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFE5B869).withOpacity(0.4),
                  ),
                ),
                child: const Text(
                  "+1 MONTH BONUS",
                  style: TextStyle(
                    color: Color(0xFFE5B869),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Total Value Highlight Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF142036),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5B869).withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Maturity Value",
                      style: TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${_totalMaturityValue.toInt()}",
                      style: const TextStyle(
                        color: Color(0xFFE5B869),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Bonus Added",
                      style: TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+₹${_bonusBenefit.toInt()}",
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Summary Metrics Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildValueMetric("Your Deposit", "₹${_totalDeposit.toInt()}"),
              Container(width: 1, height: 28, color: Colors.white.withOpacity(0.08)),
              _buildValueMetric("Jeweler Bonus", "₹${_bonusBenefit.toInt()}"),
              Container(width: 1, height: 28, color: Colors.white.withOpacity(0.08)),
              _buildValueMetric("Duration", "$_selectedDuration Mos"),
            ],
          ),

          const SizedBox(height: 16),

          // Custom Slider
          _buildBudgetSlider(),

          // Slider Labels
          _buildBudgetSliderLabels(),
        ],
      ),
    );
  }

  Widget _buildValueMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9DB5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. NEW SECTION: VALUE BASED BENEFITS & PERKS
  // ==========================================
  Widget _buildValueBasedBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Value-Based Scheme Perks",
              style: TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'OpenSans',
              ),
            ),
            Text(
              "Exclusive",
              style: TextStyle(
                color: Color(0xFFD97706),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Perk Card 1: 1 Month Free Bonus
        _buildPerkCard(
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFE5B869),
          iconBgColor: const Color(0xFFFEF3C7),
          title: "1 Month Free Bonus Installment",
          description: "Get 1 full installment credited by Nakshathra Gold upon scheme maturity.",
          badge: "100% Bonus",
        ),

        const SizedBox(height: 10),

        // Perk Card 2: Zero Making Charges
        _buildPerkCard(
          icon: Icons.auto_awesome_rounded,
          iconColor: const Color(0xFF38BDF8),
          iconBgColor: const Color(0xFFE0F2FE),
          title: "0% Value Addition / Making Charges",
          description: "Save up to 18% making charges on your purchase of gold & diamond jewellery.",
          badge: "VA 0%",
        ),

        const SizedBox(height: 10),

        // Perk Card 3: Flexible Jewellery Redemption
        _buildPerkCard(
          icon: Icons.diamond_rounded,
          iconColor: const Color(0xFFEC4899),
          iconBgColor: const Color(0xFFFCE7F3),
          title: "Redeem on Gold, Diamond & Platinum",
          description: "Flexible redemption across 22K/18K Gold, Polki, Diamond, and Platinum collections.",
          badge: "Flexible",
        ),

        const SizedBox(height: 10),

        // Perk Card 4: BIS Hallmarked Guarantee
        _buildPerkCard(
          icon: Icons.verified_user_rounded,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFFE8F8F0),
          title: "100% BIS 916 Hallmarked Gold",
          description: "Lifetime exchange warranty and guaranteed purity on all redeemed jewellery.",
          badge: "Guaranteed",
        ),
      ],
    );
  }

  Widget _buildPerkCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
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
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8E9DB5),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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
  // SHARED BUDGET SLIDER & LABELS
  // ==========================================
  Widget _buildBudgetSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        activeTrackColor: const Color(0xFFE5B869),
        inactiveTrackColor: const Color(0xFF24334B),
        thumbColor: const Color(0xFFE5B869),
        overlayColor: const Color(0xFFE5B869).withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10.0,
          elevation: 4,
        ),
        trackShape: const _JoinScreenTrackShape(),
      ),
      child: Slider(
        value: _monthlyBudget,
        min: 5000,
        max: 50000,
        onChanged: (val) {
          setState(() {
            _monthlyBudget = (val / 500).round() * 500.0;
          });
        },
      ),
    );
  }

  Widget _buildBudgetSliderLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "₹5,000",
            style: TextStyle(
              color: Color(0xFF8E9DB5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
          Text(
            "Monthly Installment: ₹${_monthlyBudget.toInt()}",
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
          const Text(
            "₹50,000",
            style: TextStyle(
              color: Color(0xFF8E9DB5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. DURATION SELECTOR PILL
  // ==========================================
  Widget _buildDurationPill(int index) {
    final isSelected = _selectedDurationIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDurationIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D1627) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5B869) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D1627).withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          _durations[index],
          style: TextStyle(
            color: isSelected ? const Color(0xFFE5B869) : const Color(0xFF64748B),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. NOMINEE INPUT FIELD
  // ==========================================
  Widget _buildNomineeInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            color: Color(0xFF8E9DB5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _nomineeController,
              cursorColor: const Color(0xFF0D1627),
              style: const TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
              decoration: const InputDecoration(
                hintText: "Full Name of Nominee",
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OpenSans',
                ),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. BOTTOM ACTION BUTTON
  // ==========================================
  Widget _buildBottomButton(BuildContext context) {
    final isLoading = _viewModel.isLoading;

    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 18,
      ),
      child: Material(
        color: isLoading ? const Color(0xFF1E2B42) : const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _handleJoinScheme,
          child: Container(
            width: double.infinity,
            height: 54,
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFFE5B869),
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "JOIN & PAY FIRST INSTALLMENT",
                    style: TextStyle(
                      color: Color(0xFFE5B869),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      fontFamily: 'OpenSans',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Track shape with discrete tick dots
class _JoinScreenTrackShape extends RoundedRectSliderTrackShape {
  const _JoinScreenTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final dotPaint = Paint()
      ..color = const Color(0xFF64748B).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    const dotCount = 9;
    final step = trackRect.width / (dotCount - 1);

    for (int i = 0; i < dotCount; i++) {
      final dx = trackRect.left + (step * i);
      final dy = trackRect.center.dy;
      if ((dx - thumbCenter.dx).abs() > 8) {
        context.canvas.drawCircle(Offset(dx, dy), 1.6, dotPaint);
      }
    }
  }
}
