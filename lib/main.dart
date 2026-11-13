//import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageEstimatorApp());
}

// Alias for backwards compatibility with tests and templates
typedef MyApp = BaggageEstimatorApp;

// Custom Aviation Color Palette
class AppColors {
  static const Color primaryTeal = Color(0xFF0F2C38);
  static const Color accentCoral = Color(0xFFE05A47);
  static const Color warmSand = Color(0xFFF6F4EF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softMint = Color(0xFFE6F2EF);
  static const Color mutedSlate = Color(0xFF5C6F78);
  static const Color borderLight = Color(0xFFDCE2E5);
}

class BaggageEstimatorApp extends StatelessWidget {
  const BaggageEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroWeigh · Baggage Estimator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.warmSand,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
          secondary: AppColors.accentCoral,
          surface: AppColors.cardSurface,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ─── Main Shell with Custom Navigation ───
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.luggage_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(_selectedIndex == 0 ? 'Baggage Fee Estimator' : 'About'),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: AppColors.cardSurface,
          indicatorColor: AppColors.accentCoral.withOpacity(0.15),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.scale_outlined, color: AppColors.mutedSlate),
              selectedIcon: Icon(Icons.scale_rounded, color: AppColors.accentCoral),
              label: 'Estimator',
            ),
            NavigationDestination(
              icon: Icon(Icons.badge_outlined, color: AppColors.mutedSlate),
              selectedIcon: Icon(Icons.badge_rounded, color: AppColors.accentCoral),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Calculator Screen ───
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _rateController = TextEditingController();

  String _selectedClass = 'Economy';

  double _excessWeight = 0;
  double _excessCharge = 0;
  double _serviceTax = 0;
  double _totalPayable = 0;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final double weight = double.parse(_weightController.text);
    final double rate = double.parse(_rateController.text);
    final double allowance = _selectedClass == 'Economy' ? 20.0 : 40.0;

    setState(() {
      _excessWeight = (weight - allowance) > 0 ? (weight - allowance) : 0.0;
      _excessCharge = _excessWeight * rate;
      _serviceTax = _excessCharge * 0.08;
      _totalPayable = _excessCharge + _serviceTax;
      _hasCalculated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Baggage fee updated.'),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _weightController.clear();
    _rateController.clear();
    setState(() {
      _selectedClass = 'Economy';
      _hasCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All fields cleared.'),
        backgroundColor: AppColors.mutedSlate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentAllowance = _selectedClass == 'Economy' ? 20 : 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Guide Strip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.accentCoral, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Estimate',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter baggage weight, pick cabin class, and key in the airline rate (RM/kg). 8% SST applies on excess weight.',
                          style: TextStyle(
                            color: Color(0xFFD0DCE0),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Cabin Class Selector (Side-by-Side Cards)
            const Text(
              'CABIN CLASS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.mutedSlate,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildClassCard(
                    title: 'Economy',
                    allowanceText: '20 kg free',
                    icon: Icons.airline_seat_recline_normal_rounded,
                    isSelected: _selectedClass == 'Economy',
                    onTap: () => setState(() => _selectedClass = 'Economy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildClassCard(
                    title: 'Business',
                    allowanceText: '40 kg free',
                    icon: Icons.airline_seat_flat_rounded,
                    isSelected: _selectedClass == 'Business',
                    onTap: () => setState(() => _selectedClass = 'Business'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Input Form Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BAGGAGE & RATE DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Weight Input
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Total Checked Weight',
                      hintText: 'e.g. 25.5',
                      suffixText: 'kg',
                      filled: true,
                      fillColor: AppColors.warmSand.withOpacity(0.6),
                      prefixIcon: const Icon(Icons.luggage, color: AppColors.primaryTeal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter checked baggage weight';
                      }
                      final num = double.tryParse(value);
                      if (num == null) return 'Invalid number format';
                      if (num <= 0) return 'Weight must exceed 0 kg';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Rate Input
                  TextFormField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Excess Rate per kg',
                      hintText: 'e.g. 18.00',
                      prefixText: 'RM ',
                      filled: true,
                      fillColor: AppColors.warmSand.withOpacity(0.6),
                      prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.primaryTeal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter excess rate per kg';
                      }
                      final num = double.tryParse(value);
                      if (num == null) return 'Invalid rate format';
                      if (num <= 0) return 'Rate must exceed RM 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Allowance Reminder
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 17, color: AppColors.primaryTeal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_selectedClass includes $currentAllowance kg free allowance. Excess is taxed at 8%.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                    backgroundColor: AppColors.cardSurface,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.restart_alt_rounded, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateFee,
                    icon: const Icon(Icons.calculate_rounded, size: 20),
                    label: const Text(
                      'Calculate Fee',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Boarding Pass Style Receipt Output
            if (_hasCalculated) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ticket Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'BAGGAGE FEE RECEIPT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentCoral,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedClass.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Breakdown Body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_excessWeight == 0)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.softMint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Color(0xFF1B7A5E), size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Within free baggage allowance. Zero extra charges!',
                                      style: TextStyle(
                                        color: Color(0xFF1B7A5E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildReceiptLine(
                            title: 'Excess Weight',
                            note: 'Checked weight minus $currentAllowance kg allowance',
                            amount: '${_excessWeight.toStringAsFixed(2)} kg',
                          ),
                          const SizedBox(height: 12),
                          _buildReceiptLine(
                            title: 'Excess Charge',
                            note: '${_excessWeight.toStringAsFixed(2)} kg × RM ${_rateController.text}',
                            amount: 'RM ${_excessCharge.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          _buildReceiptLine(
                            title: 'Service Tax (8%)',
                            note: '8% SST on excess charge',
                            amount: 'RM ${_serviceTax.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),

                    // Dashed Ticket Perforation
                    const _DashedDivider(),

                    // Total Payable Footer
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL PAYABLE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppColors.mutedSlate,
                                ),
                              ),
                              Text(
                                'Inclusive of 8% tax',
                                style: TextStyle(fontSize: 11, color: AppColors.mutedSlate),
                              ),
                            ],
                          ),
                          Text(
                            'RM ${_totalPayable.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentCoral,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String title,
    required String allowanceText,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.accentCoral : AppColors.primaryTeal,
                  size: 24,
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Colors.white : AppColors.mutedSlate,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isSelected ? Colors.white : AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              allowanceText,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFFBFD0D6) : AppColors.mutedSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptLine({
    required String title,
    required String note,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primaryTeal,
                ),
              ),
              Text(
                note,
                style: const TextStyle(fontSize: 11, color: AppColors.mutedSlate),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.primaryTeal,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.borderLight),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── About Screen ───
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String _repoUrl = 'https://github.com/blqsayb/baggage.git';

  Future<void> _openGitHub(BuildContext context) async {
    final uri = Uri.parse(_repoUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $_repoUrl')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: $_repoUrl')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // App Identity Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.luggage_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Baggy · Baggage Fee Estimator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Release v1.0.0',
                    style: TextStyle(color: Color(0xFFD0DCE0), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Developer Credentials Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEVELOPER CREDENTIALS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.mutedSlate,
                  ),
                ),
                const Divider(height: 22, color: AppColors.borderLight),
                _buildInfoRow('Name', 'NUR BALQIS BINTI MD AYUB'),
                _buildInfoRow('Matric No', '2025228256'),
                _buildInfoRow('Course', 'Bachelor of Computer Science (Netcentric Computing)'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Source Repository Card
          Material(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openGitHub(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softMint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.code_rounded, color: AppColors.primaryTeal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Source Code Repository',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _repoUrl,
                            style: const TextStyle(
                              color: AppColors.accentCoral,
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_outward_rounded, size: 18, color: AppColors.mutedSlate),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Footer
          const Text(
            '© 2026 NUR BALQIS BINTI MD AYUB · All Rights Reserved',
            style: TextStyle(color: AppColors.mutedSlate, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mobile Technology Individual Assignment · Baggage Fee Estimator App',
            style: TextStyle(color: AppColors.mutedSlate, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedSlate, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}