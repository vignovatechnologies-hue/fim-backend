import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _initialSavedController = TextEditingController(text: '0');
  final _etaController = TextEditingController();

  DateTime? _selectedTargetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _initialSavedController.dispose();
    _etaController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _selectTargetDate() async {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: DateTime(now.year + 15),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceDark,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
        _etaController.text = "${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final savingsProvider = context.read<SavingsProvider>();
    final success = await savingsProvider.addGoal({
      'name': _nameController.text.trim(),
      'target_amount': double.tryParse(_targetController.text) ?? 0.0,
      'saved_amount': double.tryParse(_initialSavedController.text) ?? 0.0,
      'eta': _etaController.text.trim().isNotEmpty ? _etaController.text.trim() : null,
      'color': 'emerald',
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal created!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingsProvider = context.watch<SavingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Savings Goal'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left),
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
                CustomTextField(
                  controller: _nameController,
                  label: 'Goal Name',
                  hint: 'e.g. Emergency Fund, New Car, Dream Vacation',
                  prefixIcon: LucideIcons.target,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Goal name is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _targetController,
                  label: 'Target Amount (₹)',
                  hint: 'Enter target goal amount',
                  prefixIcon: LucideIcons.indian_rupee,
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Target amount is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _initialSavedController,
                  label: 'Already Saved (₹)',
                  hint: 'Enter current saved amount',
                  prefixIcon: LucideIcons.indian_rupee,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Target Date Field with Interactive Calendar Picker
                GestureDetector(
                  onTap: _selectTargetDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _etaController,
                      label: 'Target Date / Timeline',
                      hint: 'Tap to select target date from calendar',
                      prefixIcon: LucideIcons.calendar,
                      suffixIcon: const Icon(LucideIcons.calendar_days, color: AppColors.accent, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: savingsProvider.isLoading ? 'Creating Goal...' : 'Create Goal',
                  isLoading: savingsProvider.isLoading,
                  onPressed: savingsProvider.isLoading ? () {} : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
