import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FIM Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last updated: August 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 16),
            Text(
              '1. Information We Collect\n'
              'FIM collects information you provide directly, such as your name, email, loan details, and transaction records to calculate EMI schedules and provide financial insights.\n\n'
              '2. Data Security\n'
              'All user records and sensitive parameters are encrypted in transit via SSL/TLS and stored securely in PostgreSQL databases.\n\n'
              '3. Third-Party Integrations\n'
              'We use Razorpay for payment processing and Gemini AI for automated financial analytics. Your data is never sold to third parties.\n\n'
              '4. Your Rights\n'
              'You can request deletion of your account and all associated loan/financial logs at any time from the Profile section.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FIM Terms of Service',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last updated: August 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 16),
            Text(
              '1. Acceptance of Terms\n'
              'By accessing and using FIM (Financial Intelligence Manager), you agree to be bound by these Terms of Service.\n\n'
              '2. Financial Disclaimer\n'
              'FIM provides smart management tools, EMI payoff calculations, and AI suggestions for informational purposes. It does not constitute formal licensed investment or legal advice.\n\n'
              '3. User Responsibilities\n'
              'You are responsible for safeguarding your login credentials and ensuring the accuracy of logged financial obligations.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
