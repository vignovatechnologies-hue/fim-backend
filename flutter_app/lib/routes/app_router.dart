import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/emis/add_loan_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/savings/add_savings_goal_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';

class AuthStatusNotifier extends ChangeNotifier {
  final AuthProvider _authProvider;
  AuthStatus _lastStatus;

  AuthStatusNotifier(this._authProvider) : _lastStatus = _authProvider.status {
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authProvider.status != _lastStatus) {
      _lastStatus = _authProvider.status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthStatusNotifier(authProvider),
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify' ||
          state.matchedLocation == '/forgot-password';

      if (isSplash) return null;

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }
      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/add-loan',
        builder: (context, state) => const AddLoanScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/add-savings-goal',
        builder: (context, state) => const AddSavingsGoalScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-use',
        builder: (context, state) => const TermsOfUseScreen(),
      ),
    ],
  );
}
