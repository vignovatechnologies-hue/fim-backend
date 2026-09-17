import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/loan_model.dart';

class EmiCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback? onTogglePaid;
  final VoidCallback? onDelete;

  const EmiCard({
    super.key,
    required this.loan,
    this.onTogglePaid,
    this.onDelete,
  });

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = loan.progressPercentage;
    final orig = loan.originalAmount ?? (loan.emi * loan.totalTenure);
    final paidAmount = orig > loan.leftAmount ? orig - loan.leftAmount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: loan.paidThisMonth
              ? AppColors.success.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          width: loan.paidThisMonth ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Category Icon, Title, Subtitle, and 3-dots Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.landmark, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${loan.type} Loan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            ' • Due on ',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            _getOrdinal(loan.dueDay),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // 3-Dots Action Button
              if (onDelete != null)
                IconButton(
                  icon: const Icon(LucideIcons.ellipsis_vertical, size: 18, color: Colors.grey),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Metrics Row (Monthly EMI | Remaining Principal | Tenure)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly EMI', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    Formatters.formatCurrency(loan.emi),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(height: 28, width: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remaining Principal', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    Formatters.formatCurrency(loan.leftAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(height: 28, width: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Tenure', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    '${loan.paidTenure}/${loan.totalTenure} mo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Already Paid vs Need to Pay Container Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.circle_check, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Already Paid', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(paidAmount),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 26, width: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.circle_alert, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Need to Pay', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(loan.leftAmount),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Progress Repaid Status & Mark as Paid Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Repaid',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loan.paidTenure} of ${loan.totalTenure} EMIs paid',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              if (onTogglePaid != null)
                InkWell(
                  onTap: onTogglePaid,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: loan.paidThisMonth
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          loan.paidThisMonth ? LucideIcons.circle_check : LucideIcons.calendar_check,
                          size: 15,
                          color: loan.paidThisMonth ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loan.paidThisMonth ? 'Paid for this Month' : 'Mark as Paid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: loan.paidThisMonth ? AppColors.success : AppColors.primary,
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
}
