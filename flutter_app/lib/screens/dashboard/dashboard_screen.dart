import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/tab_navigation_provider.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/emi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  void _showNotificationCenter() {
    final dashProvider = context.read<DashboardProvider>();
    final stats = dashProvider.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  child: const Icon(LucideIcons.bell_ring, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notification Center',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification List
            if (stats.upcomingEmis.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.circle_check, color: AppColors.success, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All clear! No pending EMI reminders for this month.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...stats.upcomingEmis.map((loan) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar_clock, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upcoming EMI: ${loan.name}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Amount: ${Formatters.formatCurrency(loan.emi)} • Due soon',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 10),
            // Security Notification
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shield_check, color: AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FIM Cloud Sync & Encryption Active', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('Your financial records and loans are synced securely with Neon DB.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;
    final dashProvider = context.watch<DashboardProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final stats = dashProvider.stats;

    final greeting = locProvider.t('dashboard.hello', defaultText: 'Hello');
    final firstName = user?.name.split(' ').first ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dashProvider.fetchDashboardData(),
          color: AppColors.primary,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          displacement: 40.0,
          strokeWidth: 3.0,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dashProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                      color: AppColors.primary,
                    ),
                  ),
                // Top User Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $firstName 👋',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locProvider.t('dashboard.hub', defaultText: 'Your Financial Intelligence Hub'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showNotificationCenter,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: const Icon(LucideIcons.bell, size: 20, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Portfolio Balance Card (Tap redirects to Expenses & Income tab)
                GestureDetector(
                  onTap: () => context.read<TabNavigationProvider>().selectTab(2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locProvider.t('total.net.balance', defaultText: 'Total Net Balance'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.shield_check, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    locProvider.t('protected', defaultText: 'Protected'),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatCurrency(stats.totalBalance),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<TabNavigationProvider>().selectTab(2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locProvider.t('monthly.income', defaultText: 'Monthly Income'),
                                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+ ${Formatters.formatCurrency(stats.monthlyIncome)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<TabNavigationProvider>().selectTab(2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locProvider.t('monthly.expenses', defaultText: 'Monthly Expenses'),
                                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '- ${Formatters.formatCurrency(stats.monthlyExpense)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
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
                  ),
                ),
                const SizedBox(height: 20),

                // 2x2 Metric Grid (Debt, EMIs -> EMIs Tab; Savings, Goals -> Savings Tab)
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: locProvider.t('total.outstanding.debt', defaultText: 'Total Debt'),
                        amount: Formatters.formatCurrency(stats.totalDebt),
                        icon: LucideIcons.credit_card,
                        iconColor: AppColors.error,
                        subtitle: locProvider.t('across.all.loans', defaultText: 'Across all loans'),
                        onTap: () => context.read<TabNavigationProvider>().selectTab(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: locProvider.t('monthly.emi.total', defaultText: 'Monthly EMI Due'),
                        amount: Formatters.formatCurrency(stats.monthlyEmiTotal),
                        icon: LucideIcons.calendar_clock,
                        iconColor: AppColors.warning,
                        subtitle: locProvider.t('this.billing.cycle', defaultText: 'This billing cycle'),
                        onTap: () => context.read<TabNavigationProvider>().selectTab(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: locProvider.t('accumulated.savings', defaultText: 'Accumulated Savings'),
                        amount: Formatters.formatCurrency(stats.totalSavings),
                        icon: LucideIcons.piggy_bank,
                        iconColor: AppColors.success,
                        subtitle: locProvider.t('safe.reserve', defaultText: 'Safe reserve'),
                        onTap: () => context.read<TabNavigationProvider>().selectTab(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: locProvider.t('active.goals', defaultText: 'Active Goals'),
                        amount: '${stats.savingsGoals.length} Goals',
                        icon: LucideIcons.target,
                        iconColor: AppColors.secondary,
                        subtitle: locProvider.t('in.progress', defaultText: 'In progress'),
                        onTap: () => context.read<TabNavigationProvider>().selectTab(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upcoming EMIs Section
                if (stats.upcomingEmis.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locProvider.t('upcoming.emis', defaultText: 'Upcoming EMIs'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<TabNavigationProvider>().selectTab(1),
                        child: Text(
                          '${stats.upcomingEmis.length} ${locProvider.t('active.count', defaultText: 'Active')}',
                          style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...stats.upcomingEmis.take(2).map((loan) => EmiCard(loan: loan)),
                  const SizedBox(height: 12),
                ],

                // Recent Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locProvider.t('recent.activity', defaultText: 'Recent Activity'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<TabNavigationProvider>().selectTab(2),
                      child: Text(
                        '${locProvider.t('latest.count', defaultText: 'Latest')} ${stats.recentTransactions.length}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (stats.recentTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      locProvider.t('no.transactions', defaultText: 'No transactions yet. Start logging expenses or income!'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                else
                  ...stats.recentTransactions.take(4).map(
                        (tx) => TransactionTile(transaction: tx),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
