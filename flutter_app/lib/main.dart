import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/api/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/loan_service.dart';
import 'services/transaction_service.dart';
import 'services/savings_service.dart';
import 'services/insights_service.dart';
import 'services/profile_service.dart';
import 'services/localization_service.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/loans_provider.dart';
import 'providers/transactions_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/tab_navigation_provider.dart';
import 'providers/localization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  final storageService = await StorageService.init();

  // Initialize API Client
  final apiClient = ApiClient(storageService);

  // Initialize Services
  final authService = AuthService(apiClient, storageService);
  final dashboardService = DashboardService(apiClient);
  final loanService = LoanService(apiClient);
  final transactionService = TransactionService(apiClient);
  final savingsService = SavingsService(apiClient);
  final insightsService = InsightsService(apiClient);
  final profileService = ProfileService(apiClient);
  final localizationService = LocalizationService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, storageService),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(dashboardService),
        ),
        ChangeNotifierProvider<LoansProvider>(
          create: (_) => LoansProvider(loanService),
        ),
        ChangeNotifierProvider<TransactionsProvider>(
          create: (_) => TransactionsProvider(transactionService),
        ),
        ChangeNotifierProvider<SavingsProvider>(
          create: (_) => SavingsProvider(savingsService),
        ),
        ChangeNotifierProvider<InsightsProvider>(
          create: (_) => InsightsProvider(insightsService),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(profileService),
        ),
        ChangeNotifierProvider<TabNavigationProvider>(
          create: (_) => TabNavigationProvider(),
        ),
        ChangeNotifierProvider<LocalizationProvider>(
          create: (_) => LocalizationProvider(localizationService),
        ),
      ],
      child: const FimApp(),
    ),
  );
}

class FimApp extends StatefulWidget {
  const FimApp({super.key});

  @override
  State<FimApp> createState() => _FimAppState();
}

class _FimAppState extends State<FimApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();

    return MaterialApp.router(
      title: 'FIM — Smart EMI Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locProvider.currentLocale,
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final insets = mediaQuery.viewInsets;
        final clampedInsets = insets.copyWith(
          bottom: insets.bottom < 0 ? 0.0 : insets.bottom,
          top: insets.top < 0 ? 0.0 : insets.top,
          left: insets.left < 0 ? 0.0 : insets.left,
          right: insets.right < 0 ? 0.0 : insets.right,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(viewInsets: clampedInsets),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
