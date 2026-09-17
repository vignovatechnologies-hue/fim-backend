import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../providers/tab_navigation_provider.dart';
import '../providers/localization_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'emis/emis_screen.dart';
import 'transactions/transactions_screen.dart';
import 'savings/savings_screen.dart';
import 'insights/insights_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final PageController _pageController;

  final List<Widget> _screens = const [
    DashboardScreen(),
    EmisScreen(),
    TransactionsScreen(),
    SavingsScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final navProvider = context.read<TabNavigationProvider>();
    _pageController = PageController(initialPage: navProvider.currentIndex);
    navProvider.setPageController(_pageController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    final navProvider = context.read<TabNavigationProvider>();
    navProvider.selectTab(index);
    if (index == 0) {
      context.read<DashboardProvider>().fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navProvider = context.watch<TabNavigationProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final currentIndex = navProvider.currentIndex;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            navProvider.updateIndexFromSwipe(index);
            if (index == 0) {
              context.read<DashboardProvider>().fetchDashboardData();
            }
          },
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, LucideIcons.layout_dashboard, locProvider.t('nav.overview', defaultText: 'Overview'), isDark, currentIndex),
                  _buildNavItem(1, LucideIcons.landmark, locProvider.t('nav.emis', defaultText: 'EMIs'), isDark, currentIndex),
                  _buildNavItem(2, LucideIcons.arrow_left_right, locProvider.t('nav.expenses', defaultText: 'Expenses'), isDark, currentIndex),
                  _buildNavItem(3, LucideIcons.piggy_bank, locProvider.t('nav.savings', defaultText: 'Savings'), isDark, currentIndex),
                  _buildNavItem(4, LucideIcons.sparkles, locProvider.t('nav.insights', defaultText: 'AI Insights'), isDark, currentIndex),
                  _buildNavItem(5, LucideIcons.user, locProvider.t('nav.profile', defaultText: 'Profile'), isDark, currentIndex),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark, int currentIndex) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white60 : Colors.black45),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white60 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
