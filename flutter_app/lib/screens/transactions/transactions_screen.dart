import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().fetchTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return LucideIcons.utensils;
      case 'shopping':
        return LucideIcons.shopping_bag;
      case 'transport':
      case 'travel':
        return LucideIcons.car;
      case 'home & bills':
      case 'bills':
      case 'utilities':
        return LucideIcons.house;
      case 'entertainment':
        return LucideIcons.film;
      default:
        return LucideIcons.landmark;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return const Color(0xFF16A34A);
      case 'shopping':
        return const Color(0xFF9333EA);
      case 'transport':
      case 'travel':
        return const Color(0xFF2563EB);
      case 'home & bills':
      case 'bills':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF0284C7);
    }
  }

  void _showStatementDialog() {
    String selectedPeriod = 'monthly';
    DateTimeRange? customRange;
    bool isGenerating = false;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkTheme ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
          final unselectedBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
          final chipBorder = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);

          return Padding(
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
                      child: const Icon(LucideIcons.file_text, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Download Statement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select timeframe or choose a custom date range for day-wise financial statement.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Period Selection Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Daily (Today)'),
                      selected: selectedPeriod == 'daily',
                      selectedColor: AppColors.primary,
                      backgroundColor: unselectedBg,
                      side: BorderSide(color: selectedPeriod == 'daily' ? AppColors.primary : chipBorder),
                      labelStyle: TextStyle(
                        color: selectedPeriod == 'daily' ? Colors.white : textColor,
                        fontWeight: selectedPeriod == 'daily' ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => setModalState(() => selectedPeriod = 'daily'),
                    ),
                    ChoiceChip(
                      label: const Text('Weekly'),
                      selected: selectedPeriod == 'weekly',
                      selectedColor: AppColors.primary,
                      backgroundColor: unselectedBg,
                      side: BorderSide(color: selectedPeriod == 'weekly' ? AppColors.primary : chipBorder),
                      labelStyle: TextStyle(
                        color: selectedPeriod == 'weekly' ? Colors.white : textColor,
                        fontWeight: selectedPeriod == 'weekly' ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => setModalState(() => selectedPeriod = 'weekly'),
                    ),
                    ChoiceChip(
                      label: const Text('Monthly'),
                      selected: selectedPeriod == 'monthly',
                      selectedColor: AppColors.primary,
                      backgroundColor: unselectedBg,
                      side: BorderSide(color: selectedPeriod == 'monthly' ? AppColors.primary : chipBorder),
                      labelStyle: TextStyle(
                        color: selectedPeriod == 'monthly' ? Colors.white : textColor,
                        fontWeight: selectedPeriod == 'monthly' ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => setModalState(() => selectedPeriod = 'monthly'),
                    ),
                    ChoiceChip(
                      label: const Text('Yearly'),
                      selected: selectedPeriod == 'yearly',
                      selectedColor: AppColors.primary,
                      backgroundColor: unselectedBg,
                      side: BorderSide(color: selectedPeriod == 'yearly' ? AppColors.primary : chipBorder),
                      labelStyle: TextStyle(
                        color: selectedPeriod == 'yearly' ? Colors.white : textColor,
                        fontWeight: selectedPeriod == 'yearly' ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => setModalState(() => selectedPeriod = 'yearly'),
                    ),
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.calendar_range,
                            size: 14,
                            color: selectedPeriod == 'custom' ? Colors.white : textColor,
                          ),
                          const SizedBox(width: 4),
                          Text('Custom Range'),
                        ],
                      ),
                      selected: selectedPeriod == 'custom',
                      selectedColor: AppColors.primary,
                      backgroundColor: unselectedBg,
                      side: BorderSide(color: selectedPeriod == 'custom' ? AppColors.primary : chipBorder),
                      labelStyle: TextStyle(
                        color: selectedPeriod == 'custom' ? Colors.white : textColor,
                        fontWeight: selectedPeriod == 'custom' ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) async {
                        final picked = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: customRange ?? DateTimeRange(
                            start: DateTime.now().subtract(const Duration(days: 30)),
                            end: DateTime.now(),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedPeriod = 'custom';
                            customRange = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),

                if (selectedPeriod == 'custom' && customRange != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '📅 Selected Range: ${customRange!.start.toString().split(' ').first} to ${customRange!.end.toString().split(' ').first}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.download, size: 18),
                  label: Text(
                    isGenerating ? 'Generating Statement...' : 'Generate ${selectedPeriod.toUpperCase()} Statement',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: isGenerating
                      ? null
                      : () async {
                          setModalState(() => isGenerating = true);
                          String? startIso;
                          String? endIso;
                          if (selectedPeriod == 'custom' && customRange != null) {
                            startIso = customRange!.start.toIso8601String();
                            endIso = customRange!.end.toIso8601String();
                          }

                          final statement = await context.read<TransactionsProvider>().fetchStatement(
                                selectedPeriod,
                                startDate: startIso,
                                endDate: endIso,
                              );
                          setModalState(() => isGenerating = false);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _showStatementPreview(statement);
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _buildMonthSelector(TransactionsProvider provider, bool isDark) {
    final now = DateTime.now();
    final months = [
      {
        'label': 'Current Month (${_getMonthName(now.month)})',
        'month': now.month,
        'year': now.year
      },
      {
        'label': _getMonthName(now.month == 1 ? 12 : now.month - 1),
        'month': now.month == 1 ? 12 : now.month - 1,
        'year': now.month == 1 ? now.year - 1 : now.year
      },
      {
        'label': _getMonthName((now.month - 2 <= 0) ? now.month - 2 + 12 : now.month - 2),
        'month': (now.month - 2 <= 0) ? now.month - 2 + 12 : now.month - 2,
        'year': (now.month - 2 <= 0) ? now.year - 1 : now.year
      },
      {
        'label': _getMonthName((now.month - 3 <= 0) ? now.month - 3 + 12 : now.month - 3),
        'month': (now.month - 3 <= 0) ? now.month - 3 + 12 : now.month - 3,
        'year': (now.month - 3 <= 0) ? now.year - 1 : now.year
      },
      {
        'label': 'All Time',
        'month': null,
        'year': null
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final m = months[index];
          final isSelected = provider.selectedMonth == m['month'] && provider.selectedYear == m['year'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(m['label'] as String),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              side: BorderSide(
                color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) {
                provider.setSelectedMonth(m['month'] as int?, m['year'] as int?);
              },
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[(month - 1) % 12];
  }

  void _showStatementPreview(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayWise = (data['day_wise_breakdown'] as List<dynamic>?) ?? [];
    final userEmail = data['email'] ?? 'user@example.com';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Row(
          children: [
            const Icon(LucideIcons.file_check, color: AppColors.success, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${data['period'] ?? ''} Statement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account: ${data['user_name'] ?? 'User'} ($userEmail)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Range: ${data['date_range'] ?? ''} | Generated: ${data['generated_at'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Income', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('+ ${Formatters.formatCurrency((data['total_income'] as num?)?.toDouble() ?? 0.0)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Expense', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('- ${Formatters.formatCurrency((data['total_expense'] as num?)?.toDouble() ?? 0.0)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Day-Wise Breakdown (${dayWise.length} days):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: 6),

              SizedBox(
                height: 220,
                child: dayWise.isEmpty
                    ? const Center(child: Text('No transactions recorded for this period.', style: TextStyle(fontSize: 13, color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: dayWise.length,
                        itemBuilder: (context, i) {
                          final dayData = dayWise[i];
                          final dayTx = (dayData['transactions'] as List<dynamic>?) ?? [];
                          final dayInc = (dayData['day_income'] as num?)?.toDouble() ?? 0.0;
                          final dayExp = (dayData['day_expense'] as num?)?.toDouble() ?? 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                            ),
                            child: ExpansionTile(
                              dense: true,
                              title: Text(
                                dayData['display_date'] ?? dayData['date'] ?? '',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                              subtitle: Row(
                                children: [
                                  if (dayInc > 0)
                                    Text('+₹${dayInc.toStringAsFixed(0)} ', style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                                  if (dayExp > 0)
                                    Text('-₹${dayExp.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              children: dayTx.map((t) {
                                final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                                return ListTile(
                                  dense: true,
                                  title: Text(t['name'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                                  subtitle: Text(t['category'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  trailing: Text(
                                    Formatters.formatCurrency(amt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: amt >= 0 ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          // Action 1: Download Excel (.xlsx)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A), // Excel Green
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.file_spreadsheet, size: 16),
            label: const Text('Download Excel (.xlsx)'),
            onPressed: () {
              Navigator.pop(ctx);
              _exportStatementToExcel(data);
            },
          ),
          // Action 2: Copy / Text Statement
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              side: BorderSide(color: isDark ? AppColors.primaryLight : AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text('Copy Text'),
            onPressed: () {
              final buffer = StringBuffer();
              final incStr = Formatters.formatCurrency((data['total_income'] as num?)?.toDouble() ?? 0.0);
              final expStr = Formatters.formatCurrency((data['total_expense'] as num?)?.toDouble() ?? 0.0);
              final netStr = Formatters.formatCurrency((data['net_savings'] as num?)?.toDouble() ?? 0.0);

              buffer.writeln('=== FIM ${data['period']} FINANCIAL STATEMENT ===');
              buffer.writeln('Account Holder: ${data['user_name']} ($userEmail)');
              buffer.writeln('Statement Range: ${data['date_range']}');
              buffer.writeln('Generated On: ${data['generated_at']}');
              buffer.writeln('Total Income: $incStr');
              buffer.writeln('Total Expense: $expStr');
              buffer.writeln('Net Savings: $netStr');
              buffer.writeln('===================================');

              for (var day in dayWise) {
                final dInc = Formatters.formatCurrency((day['day_income'] as num?)?.toDouble() ?? 0.0);
                final dExp = Formatters.formatCurrency((day['day_expense'] as num?)?.toDouble() ?? 0.0);
                buffer.writeln('\n📅 ${day['display_date']} (In: $dInc | Out: $dExp)');
                for (var t in (day['transactions'] as List<dynamic>)) {
                  final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  final status = (t['payment_status']?.toString().toLowerCase() == 'credit') ? '+' : '-';
                  buffer.writeln('  • ${t['name']} [${t['category']}]: $status${Formatters.formatCurrency(amt)}');
                }
              }

              Clipboard.setData(ClipboardData(text: buffer.toString()));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statement summary copied to clipboard!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportStatementToExcel(Map<String, dynamic> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Financial Statement'];
      excel.setDefaultSheet('Financial Statement');

      // Title header
      sheet.appendRow([TextCellValue('FIM — Financial Intelligence Manager Statement')]);
      sheet.appendRow([TextCellValue('')]);

      // Summary Info
      sheet.appendRow([TextCellValue('Account Name:'), TextCellValue(data['user_name']?.toString() ?? '')]);
      sheet.appendRow([TextCellValue('Email:'), TextCellValue(data['email']?.toString() ?? '')]);
      sheet.appendRow([TextCellValue('Statement Range:'), TextCellValue(data['date_range']?.toString() ?? '')]);
      sheet.appendRow([TextCellValue('Generated At:'), TextCellValue(data['generated_at']?.toString() ?? '')]);
      sheet.appendRow([
        TextCellValue('Total Income (₹):'),
        DoubleCellValue((data['total_income'] as num?)?.toDouble() ?? 0.0)
      ]);
      sheet.appendRow([
        TextCellValue('Total Expense (₹):'),
        DoubleCellValue((data['total_expense'] as num?)?.toDouble() ?? 0.0)
      ]);
      sheet.appendRow([
        TextCellValue('Net Savings (₹):'),
        DoubleCellValue((data['net_savings'] as num?)?.toDouble() ?? 0.0)
      ]);
      sheet.appendRow([TextCellValue('')]);

      // Column Headers
      sheet.appendRow([
        TextCellValue('Date & Time'),
        TextCellValue('Description / Title'),
        TextCellValue('Category'),
        TextCellValue('Type'),
        TextCellValue('Amount (₹)'),
        TextCellValue('Payment Status'),
      ]);

      final txns = (data['transactions'] as List<dynamic>?) ?? [];
      for (var t in txns) {
        final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final isCredit = t['payment_status']?.toString().toLowerCase() == 'credit' || amt > 0;
        sheet.appendRow([
          TextCellValue(t['when']?.toString() ?? ''),
          TextCellValue(t['name']?.toString() ?? ''),
          TextCellValue(t['category']?.toString() ?? ''),
          TextCellValue(isCredit ? 'Credit' : 'Debit'),
          DoubleCellValue(amt.abs()),
          TextCellValue(t['payment_status']?.toString() ?? (isCredit ? 'credit' : 'debit')),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final period = data['period']?.toString().replaceAll(' ', '_') ?? 'Export';
        final filename = 'FIM_Statement_${period}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(fileBytes);

        final xFile = XFile(file.path);
        await Share.shareXFiles([xFile], text: 'FIM Financial Statement (.xlsx)');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excel statement saved and shared: $filename'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEditTransactionDialog(TransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: transaction.name);
    final amountController = TextEditingController(text: transaction.amount.abs().toStringAsFixed(0));
    String category = transaction.category;
    String type = transaction.isCredit ? 'income' : 'expense';

    final categories = [
      'Food', 'Shopping', 'Transport', 'Bills', 'Utilities', 'Entertainment', 'Salary', 'Savings', 'Other'
    ];
    if (!categories.contains(category)) {
      categories.add(category);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Text(
            'Edit ${type == 'income' ? 'Income' : 'Expense'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Expense')),
                        selected: type == 'expense',
                        selectedColor: AppColors.error,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: type == 'expense' ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setDialogState(() => type = 'expense'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Income')),
                        selected: type == 'income',
                        selectedColor: AppColors.success,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: type == 'income' ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setDialogState(() => type = 'income'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Title / Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: const Icon(LucideIcons.indian_rupee),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newAmt = double.tryParse(amountController.text.trim()) ?? 0.0;
                if (newName.isEmpty || newAmt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid name and amount.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final updated = await context.read<TransactionsProvider>().updateTransaction(
                  transaction.id,
                  {
                    'name': newName,
                    'amount': newAmt,
                    'category': category,
                    'type': type,
                    'payment_status': type == 'income' ? 'credit' : 'debit',
                  },
                );

                if (mounted) {
                  if (updated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update transaction.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(String category, double currentTarget) {
    final controller = TextEditingController(text: currentTarget > 0 ? currentTarget.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Budget for $category', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set monthly budget limit to receive alerts when spending reaches 80% or exceeds this target.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Budget Limit (₹)',
                hintText: 'Enter monthly budget target',
                prefixIcon: const Icon(LucideIcons.indian_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newTarget = double.tryParse(controller.text) ?? 0.0;
              if (newTarget >= 0) {
                Navigator.pop(ctx);
                final success = await context.read<TransactionsProvider>().updateBudget(category, newTarget);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget for $category updated to ₹${newTarget.toStringAsFixed(0)}!'), backgroundColor: AppColors.success),
                  );
                }
              }
            },
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }

  void _showSelectCategoryBudgetDialog(List<Map<String, dynamic>> budgets) {
    final standardCategories = ['Food & Dining', 'Shopping', 'Transport', 'Home & Bills', 'Entertainment', 'Healthcare', 'Others'];

    final Set<String> allCategoryNames = {};
    for (final b in budgets) {
      if (b['name'] != null && (b['name'] as String).isNotEmpty) {
        allCategoryNames.add(b['name'] as String);
      }
    }
    allCategoryNames.addAll(standardCategories);

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkTheme ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Category Budget Limit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a category to set or edit its monthly target budget limit.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allCategoryNames.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final catName = allCategoryNames.elementAt(index);
                    final existingBudget = budgets.firstWhere(
                      (b) => (b['name'] as String?)?.toLowerCase() == catName.toLowerCase(),
                      orElse: () => <String, dynamic>{},
                    );
                    final target = (existingBudget['budget'] as num?)?.toDouble() ?? 0.0;
                    final spent = (existingBudget['spent'] as num?)?.toDouble() ?? 0.0;
                    final icon = _getCategoryIcon(catName);
                    final color = _getCategoryColor(catName);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      title: Text(
                        catName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        target > 0
                            ? 'Spent: ₹${spent.toStringAsFixed(0)} / Target: ₹${target.toStringAsFixed(0)}'
                            : 'No limit set yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          target > 0 ? 'Edit' : 'Set Limit',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSetBudgetDialog(catName, target);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txProvider = context.watch<TransactionsProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final allTx = txProvider.transactions;
    final expenses = allTx.where((t) => !t.isCredit).toList();
    final income = allTx.where((t) => t.isCredit).toList();
    final budgets = txProvider.budgets;

    // Detect Budget Alerts (spent >= 80% or >= 100%)
    final alerts = budgets.where((b) {
      final spent = (b['spent'] as num?)?.toDouble() ?? 0.0;
      final target = (b['budget'] as num?)?.toDouble() ?? 0.0;
      return target > 0 && spent >= (target * 0.8);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF6F9FE),
      // Floating Action Button at Bottom for User-Friendly Add Expense
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add-transaction'),
          backgroundColor: AppColors.primary.withValues(alpha: 0.90),
          elevation: 4,
          icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
          label: Text(
            locProvider.t('add.transaction', defaultText: 'Add Expense'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            locProvider.t('transactions.title', defaultText: 'Expenses & Income'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locProvider.t('transactions.subtitle', defaultText: 'Track cash flow and manage expenses better'),
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Download Statement Icon Button
                  InkWell(
                    onTap: _showStatementDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.arrow_down_to_line, size: 20, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Month Selector Bar (Select particular month expenses)
            _buildMonthSelector(txProvider, isDark),

            // Tab Bar Navigation Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${locProvider.t('tab.all', defaultText: 'All')} (${allTx.length})'),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${locProvider.t('tab.expenses', defaultText: 'Expenses')} (${expenses.length})'),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${locProvider.t('tab.income', defaultText: 'Income')} (${income.length})'),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area with Bottom Padding for Smooth Scrolling
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => txProvider.fetchTransactions(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 160), // 160px bottom padding for smooth scrolling
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Budget Alert Warning Banners (Notifies when 80% or 100% reached)
                      if (alerts.isNotEmpty)
                        ...alerts.map((b) {
                          final spent = (b['spent'] as num?)?.toDouble() ?? 0.0;
                          final target = (b['budget'] as num?)?.toDouble() ?? 0.0;
                          final isExceeded = spent >= target;
                          final pct = (spent / target * 100).toStringAsFixed(0);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isExceeded ? AppColors.error.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isExceeded ? AppColors.error : Colors.amber),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isExceeded ? LucideIcons.triangle_alert : LucideIcons.bell_ring,
                                  color: isExceeded ? AppColors.error : Colors.amber.shade900,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isExceeded
                                        ? '⚠️ Exceeded ${b['name']} Budget! (Spent ₹${spent.toStringAsFixed(0)} / Limit ₹${target.toStringAsFixed(0)})'
                                        : '⚡ Budget Alert: You have reached $pct% of your ${b['name']} budget target!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isExceeded ? AppColors.error : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      // Total Inflow / Outflow Summary Card (Resets per selected month)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Total Inflow
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(LucideIcons.arrow_down_left, color: Color(0xFF16A34A), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Monthly Inflow', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '+ ${Formatters.formatCurrency(txProvider.totalIncome)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('${income.length} Transactions', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(height: 36, width: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                            const SizedBox(width: 14),

                            // Total Outflow
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(LucideIcons.arrow_up_right, color: Color(0xFFDC2626), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Monthly Outflow', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '- ${Formatters.formatCurrency(txProvider.totalExpense)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('${expenses.length} Transactions', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category Budget Limits Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category Budget Limits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showSelectCategoryBudgetDialog(budgets),
                            child: const Text(
                              'Tap to set limit',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Scrollable Category Budget Cards
                      SizedBox(
                        height: 138,
                        child: budgets.isEmpty
                            ? const Center(child: Text('No budget categories set.', style: TextStyle(fontSize: 12, color: Colors.grey)))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: budgets.length,
                                itemBuilder: (context, i) {
                                  final b = budgets[i];
                                  final name = b['name'] as String;
                                  final spent = (b['spent'] as num?)?.toDouble() ?? 0.0;
                                  final target = (b['budget'] as num?)?.toDouble() ?? 0.0;
                                  final progress = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
                                  final icon = _getCategoryIcon(name);
                                  final catColor = _getCategoryColor(name);

                                  return GestureDetector(
                                    onTap: () => _showSetBudgetDialog(name, target),
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: catColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(icon, color: catColor, size: 18),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                target > 0
                                                    ? '₹${spent.toStringAsFixed(0)} / ₹${target.toStringAsFixed(0)}'
                                                    : '₹${spent.toStringAsFixed(0)}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    target > 0 && spent >= target ? AppColors.error : catColor,
                                                  ),
                                                  minHeight: 4,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  '${(progress * 100).toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: target > 0 && spent >= target ? AppColors.error : catColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Tab Content List View with Auto Height
                      Builder(
                        builder: (context) {
                          List<dynamic> targetList;
                          if (_tabController.index == 1) {
                            targetList = expenses;
                          } else if (_tabController.index == 2) {
                            targetList = income;
                          } else {
                            targetList = allTx;
                          }
                          return _buildTabContent(targetList, txProvider, isDark);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _filterListByCategory(List<TransactionModel> rawList) {
    if (_selectedCategory == 'All') return rawList;
    final targetCat = _selectedCategory.toLowerCase();
    return rawList.where((t) {
      final cat = t.category.toLowerCase();
      if (cat == targetCat) return true;
      if (targetCat.contains('food') && cat.contains('food')) return true;
      if (targetCat.contains('bills') && (cat.contains('bill') || cat.contains('home'))) return true;
      if (targetCat.contains('transport') && (cat.contains('transport') || cat.contains('car') || cat.contains('travel'))) return true;
      return cat.contains(targetCat);
    }).toList();
  }

  Widget _buildCategoryFilterChips(bool isDark) {
    final categories = ['All', 'Food & Dining', 'Shopping', 'Transport', 'Home & Bills', 'Entertainment', 'Healthcare', 'Others'];
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = cat;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            side: BorderSide(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(List<dynamic> list, TransactionsProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }

    final typedList = list.cast<TransactionModel>();
    final filteredList = _filterListByCategory(typedList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tabController.index == 1
                  ? 'Expense Records (${filteredList.length})'
                  : (_tabController.index == 2 ? 'Income Records (${filteredList.length})' : 'All Transactions (${filteredList.length})'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            if (_selectedCategory != 'All')
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = 'All'),
                child: const Text(
                  'Reset Category',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),

        // Horizontal Category Filter Chips
        _buildCategoryFilterChips(isDark),

        if (filteredList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.clipboard_list, size: 54, color: AppColors.primary),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(LucideIcons.search, size: 24, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _selectedCategory != 'All'
                        ? 'No records for "$_selectedCategory"'
                        : 'No records found for this period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedCategory != 'All'
                        ? 'Try selecting "All" or a different category filter.'
                        : 'Log your daily expenses, food, shopping, or income.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 22),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    onPressed: () => context.push('/add-transaction'),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text(
                      'Add Expense',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final tx = filteredList[index];
              return TransactionTile(
                transaction: tx,
                onEdit: () => _showEditTransactionDialog(tx),
                onDelete: () => provider.deleteTransaction(tx.id),
              );
            },
          ),
      ],
    );
  }
}
