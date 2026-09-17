import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/loans_provider.dart';
import '../../widgets/custom_button.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emiController = TextEditingController();
  final _leftAmountController = TextEditingController();
  final _rateController = TextEditingController();
  final _totalTenureController = TextEditingController();
  final _paidTenureController = TextEditingController();
  final _dueDayController = TextEditingController();

  String _loanType = 'Personal';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Personal', 'icon': LucideIcons.user},
    {'name': 'Home', 'icon': LucideIcons.house},
    {'name': 'Auto', 'icon': LucideIcons.car},
    {'name': 'Education', 'icon': LucideIcons.graduation_cap},
    {'name': 'Consumer', 'icon': LucideIcons.shopping_bag},
  ];

  @override
  void initState() {
    super.initState();
    _emiController.addListener(_updateSummary);
    _leftAmountController.addListener(_updateSummary);
    _totalTenureController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emiController.dispose();
    _leftAmountController.dispose();
    _rateController.dispose();
    _totalTenureController.dispose();
    _paidTenureController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    setState(() {});
  }

  double get _emi => double.tryParse(_emiController.text) ?? 0.0;
  double get _outstanding => double.tryParse(_leftAmountController.text) ?? 0.0;
  int get _months => int.tryParse(_totalTenureController.text) ?? 0;

  double get _totalPayment => _emi * _months;
  double get _totalInterest => _totalPayment > _outstanding ? _totalPayment - _outstanding : 0.0;

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final loansProvider = context.read<LoansProvider>();
    final success = await loansProvider.addLoan({
      'name': _nameController.text.trim(),
      'type': _loanType,
      'emi': _emi,
      'left_amount': _outstanding,
      'rate': double.tryParse(_rateController.text) ?? 0.0,
      'total_tenure': _months > 0 ? _months : 12,
      'paid_tenure': int.tryParse(_paidTenureController.text) ?? 0,
      'due_day': int.tryParse(_dueDayController.text) ?? 5,
      'logo': 'bank',
      'paid_this_month': false,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loan added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loansProvider = context.watch<LoansProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF6F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with 3D Receipt Badge (Fully Responsive Layout)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              } else {
                                context.go('/emis');
                              }
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                LucideIcons.arrow_left,
                                size: 20,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Add Loan / EMI',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Track your loan details and manage EMIs smartly',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Header Illustration Icon Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.receipt, color: Colors.white, size: 22),
                          SizedBox(width: 4),
                          Icon(LucideIcons.shield_check, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Loan Category Section
                Text(
                  'Loan Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _loanType == cat['name'];
                    return InkWell(
                      onTap: () => setState(() => _loanType = cat['name']),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected
                              ? null
                              : (isDark ? AppColors.surfaceDark : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.primary : const Color(0xFF2563EB)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textPrimaryDark : const Color(0xFF334155)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Loan / Lender Name
                Text(
                  'Loan / Lender Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'e.g., HDFC Home Loan, SBI Auto Loan',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.landmark, color: AppColors.primary, size: 18),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Loan name is required' : null,
                  ),
                ),
                const SizedBox(height: 18),

                // 2-Column Inputs Grid (Clean Layout without Double-Boxed Borders)
                Column(
                  children: [
                    // Row 1: EMI & Outstanding
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Monthly EMI (₹)',
                            controller: _emiController,
                            hint: 'Enter monthly EMI',
                            icon: LucideIcons.indian_rupee,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFEFF6FF),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Outstanding (₹)',
                            controller: _leftAmountController,
                            hint: 'Enter balance amount',
                            icon: LucideIcons.indian_rupee,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFEFF6FF),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Row 2: Rate & Due Day
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Interest Rate (%)',
                            controller: _rateController,
                            hint: 'Enter annual rate',
                            icon: LucideIcons.percent,
                            iconColor: const Color(0xFF16A34A),
                            iconBg: const Color(0xFFF0FDF4),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Due Day of Month',
                            controller: _dueDayController,
                            hint: 'Enter due day (1-31)',
                            icon: LucideIcons.calendar,
                            iconColor: const Color(0xFF9333EA),
                            iconBg: const Color(0xFFFAF5FF),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Row 3: Total Months & Paid Months
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Total Months',
                            controller: _totalTenureController,
                            hint: 'Enter total tenure',
                            icon: LucideIcons.clock,
                            iconColor: const Color(0xFF0284C7),
                            iconBg: const Color(0xFFF0F9FF),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildGridInputField(
                            label: 'Months Already Paid',
                            controller: _paidTenureController,
                            hint: 'Enter paid months',
                            icon: LucideIcons.circle_check,
                            iconColor: const Color(0xFFEA580C),
                            iconBg: const Color(0xFFFFF7ED),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // EMI Summary Card (Tap to View Details)
                InkWell(
                  onTap: _showEmiDetailsModal,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0F2942), const Color(0xFF063028)]
                            : [const Color(0xFFE0F2FE), const Color(0xFFECFDF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFBAE6FD),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.trending_up, color: AppColors.primary, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EMI Summary',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Stay on track and become debt free',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _showEmiDetailsModal,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View Details',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(LucideIcons.chevron_right, size: 12, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // 3 Summary Metrics Row (Scaled down for any screen)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Payment', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Formatters.formatCurrency(_totalPayment),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Interest', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Formatters.formatCurrency(_totalInterest),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF9333EA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('EMI per Month', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    Formatters.formatCurrency(_emi),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

                // Save Button
                CustomButton(
                  text: loansProvider.isLoading ? 'Saving Details...' : 'Save Loan Details',
                  icon: LucideIcons.save,
                  isLoading: loansProvider.isLoading,
                  onPressed: loansProvider.isLoading ? () {} : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.2) : iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  void _showEmiDetailsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emi = _emi;
    final outstanding = _outstanding;
    final months = _months;
    final totalPayment = _totalPayment;
    final totalInterest = _totalInterest;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final dueDay = int.tryParse(_dueDayController.text) ?? 5;

    final principalRatio = totalPayment > 0 ? (outstanding / totalPayment) : 0.0;
    final interestRatio = totalPayment > 0 ? (totalInterest / totalPayment) : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.calculator, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMI Calculation Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_nameController.text.isNotEmpty ? _nameController.text : "Loan"} ($_loanType Loan)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildEmiDetailRow('Monthly EMI', Formatters.formatCurrency(emi), AppColors.primary, isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Outstanding Principal', Formatters.formatCurrency(outstanding), isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A), isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Total Interest Payable', Formatters.formatCurrency(totalInterest), const Color(0xFF9333EA), isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Total Payment Amount', Formatters.formatCurrency(totalPayment), const Color(0xFF2563EB), isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Annual Interest Rate', '${rate.toStringAsFixed(1)}%', const Color(0xFF16A34A), isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Total Tenure', '$months Months', isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A), isDark),
                  const Divider(height: 18),
                  _buildEmiDetailRow('Monthly Due Day', '${dueDay}th of every month', const Color(0xFFEA580C), isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Visual Progress ratio bar (Principal vs Interest)
            if (totalPayment > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Principal (${(principalRatio * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  Text(
                    'Interest (${(interestRatio * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9333EA)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (principalRatio * 100).round() > 0 ? (principalRatio * 100).round() : 1,
                        child: Container(color: AppColors.primary),
                      ),
                      Expanded(
                        flex: (interestRatio * 100).round() > 0 ? (interestRatio * 100).round() : 1,
                        child: Container(color: const Color(0xFF9333EA)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmiDetailRow(String label, String value, Color valueColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
