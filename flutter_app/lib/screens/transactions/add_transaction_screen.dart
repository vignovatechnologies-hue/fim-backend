import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isExpense = true;
  String _category = 'Food';

  final List<String> _expenseCategories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Home',
    'Bills',
    'Healthcare',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gift',
    'Other Income',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid transaction amount greater than ₹0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final signedAmount = _isExpense ? -rawAmount.abs() : rawAmount.abs();

    final txProvider = context.read<TransactionsProvider>();
    final success = await txProvider.addTransaction({
      'name': _nameController.text.trim(),
      'category': _category,
      'amount': signedAmount,
      'payment_status': _isExpense ? 'debit' : 'credit',
      'when': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    if (success) {
      context.read<DashboardProvider>().fetchDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_isExpense ? "Expense" : "Income"} recorded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = txProvider.errorMessage ?? 'Failed to record transaction. Please check network.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $err'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txProvider = context.watch<TransactionsProvider>();
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expense vs Income Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = true;
                            _category = _expenseCategories.first;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isExpense ? AppColors.error : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _isExpense ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = false;
                            _category = _incomeCategories.first;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isExpense ? AppColors.success : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: !_isExpense ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  controller: _amountController,
                  label: 'Amount (₹)',
                  hint: 'Enter transaction amount',
                  prefixIcon: LucideIcons.indian_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Amount is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nameController,
                  label: 'Description / Payee',
                  hint: 'e.g. Grocery store, Swiggy, Salary',
                  prefixIcon: LucideIcons.file_text,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Description is required' : null,
                ),
                const SizedBox(height: 20),

                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentCategories.map((cat) {
                    final isSelected = _category == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: _isExpense ? AppColors.primary : AppColors.success,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Save Transaction',
                  isLoading: txProvider.isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
