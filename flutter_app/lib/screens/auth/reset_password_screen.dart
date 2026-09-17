import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showStatusDialog(String title, String message, bool isSuccess) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? LucideIcons.mail_check : LucideIcons.triangle_alert,
                color: isSuccess ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showStatusDialog('Email Required', 'Please enter your registered email address.', false);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(email);
    if (!mounted) return;

    if (success) {
      setState(() => _codeSent = true);
      _showStatusDialog(
        'Reset Code Sent!',
        'We sent a 6-digit password recovery code to $email. Please check your inbox or spam folder.',
        true,
      );
    } else {
      final err = authProvider.errorMessage ?? 'No account found for this email address.';
      _showStatusDialog('Reset Error', err, false);
    }
  }

  void _handleResetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showStatusDialog('Fields Required', 'Please fill in all fields (email, code, new password, confirm password) to update your password.', false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showStatusDialog('Passwords Do Not Match', 'New password and confirm password fields must match exactly. Please check your entries.', false);
      return;
    }

    if (newPassword.length < 4) {
      _showStatusDialog('Password Too Short', 'Password must be at least 4 characters long.', false);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please sign in with your new password.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/login');
    } else {
      final err = authProvider.errorMessage ?? 'Password reset failed. Please check your verification code.';
      _showStatusDialog('Reset Failed', err, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'Enter the 6-digit code sent to your email, then enter and confirm your new password.'
                    : 'Enter your registered email address to receive a password recovery code.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              if (!_codeSent) ...[
                CustomButton(
                  text: authProvider.isLoading ? 'Sending Code...' : 'Send Reset Code',
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading ? () {} : _handleSendCode,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _codeSent = true),
                    child: const Text(
                      'Already have a recovery code? Enter code',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],

              if (_codeSent) ...[
                CustomTextField(
                  controller: _codeController,
                  label: 'Reset Code',
                  hint: '123456',
                  prefixIcon: LucideIcons.key_round,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: '••••••••',
                  prefixIcon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? LucideIcons.eye_off : LucideIcons.eye, size: 18),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: '••••••••',
                  prefixIcon: LucideIcons.shield_check,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? LucideIcons.eye_off : LucideIcons.eye, size: 18),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                if (_newPasswordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final p1 = _newPasswordController.text;
                      final p2 = _confirmPasswordController.text;
                      final isLengthValid = p1.length >= 4;
                      final isMatch = p1 == p2 && p2.isNotEmpty;
                      final isMismatch = p2.isNotEmpty && p1 != p2;

                      if (!isLengthValid && p1.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.shield_alert, size: 16, color: Colors.amber),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Password must be at least 4 characters long.',
                                  style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isMatch) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.circle_check, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Passwords match perfectly!',
                                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isMismatch) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.circle_alert, size: 16, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Passwords do not match. Please verify both fields.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
                const SizedBox(height: 24),

                CustomButton(
                  text: authProvider.isLoading ? 'Updating Password...' : 'Update Password',
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading ? () {} : _handleResetPassword,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _codeSent = false),
                    child: const Text(
                      'Need a new recovery code? Request again',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
