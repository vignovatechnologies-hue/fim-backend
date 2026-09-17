class ApiEndpoints {
  // Live Vercel Production Backend URL
  static const String productionBaseUrl = 'https://fim-backend-vignova.vercel.app';

  // Default dynamic base URL resolution
  static String get defaultBaseUrl {
    return productionBaseUrl;
  }

  // Auth Endpoints (Exact Backend Routes)
  static const String signin = '/api/auth/signin';
  static const String signup = '/api/auth/signup';
  static const String verify = '/api/auth/verify';
  static const String resend = '/api/auth/resend';
  static const String requestReset = '/api/auth/request-reset';
  static const String reset = '/api/auth/reset';

  // Dashboard
  static const String dashboardSummary = '/api/dashboard/summary';
  static const String dashboardStats = '/api/dashboard/summary';

  // Loans / EMIs
  static const String loans = '/api/loans';
  static String loanDetails(int id) => '/api/loans/$id';
  static String payLoan(int id) => '/api/loans/$id/pay';
  static String unpayLoan(int id) => '/api/loans/$id/unpay';

  // Transactions / Expenses & Income
  static const String transactions = '/api/transactions';
  static String transactionDetails(int id) => '/api/transactions/$id';
  static const String budgets = '/api/budgets';

  // Savings Goals
  static const String savings = '/api/savings';
  static String depositSavings(int id) => '/api/savings/$id/add-money';

  // AI Insights
  static const String insights = '/api/insights';
  static const String insightsAsk = '/api/insights/ask';

  // Profile & Banks & Settings
  static const String profile = '/api/user/profile';
  static const String banks = '/api/user/banks';
  static String bankDetails(int id) => '/api/user/banks/$id';
  static const String photo = '/api/user/photo';
  static const String reminders = '/api/user/reminders';
  static const String health = '/health';
}
