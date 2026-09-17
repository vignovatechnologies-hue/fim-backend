import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bank_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/language_selector_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  void _showNotificationCenter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                  'Notifications & Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification item 1
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
                        Text(
                          'Account & Data Encrypted',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your profile preferences and bank details are stored securely.',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Notification item 2
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.circle_check, color: AppColors.success, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMI Reminders System Active',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Automated push & daily payment notifications are enabled.',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  Future<void> _pickAndSaveImage(ImageSource source, BuildContext dialogCtx) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';

        if (dialogCtx.mounted) {
          Navigator.pop(dialogCtx);
        }

        if (mounted) {
          final success = await context.read<ProfileProvider>().updateProfile({'photo_data': base64Image});
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Custom profile photo updated!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAvatarSelectionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urlController = TextEditingController();

    final presetAvatars = [
      '👨‍💼', '👩‍💼', '🧑‍💻', '👩‍💻', '🦸‍♂️', '🦸‍♀️', '💼', '🚀', '⭐', '🔥', '👑', '🎯',
    ];

    final presetImages = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.camera, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Update Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload your own image from device, camera, URL or presets:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Upload your own image buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(LucideIcons.image, size: 16),
                      label: const Text('Gallery / Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      onPressed: () => _pickAndSaveImage(ImageSource.gallery, ctx),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(LucideIcons.camera, size: 16),
                      label: const Text('Take Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      onPressed: () => _pickAndSaveImage(ImageSource.camera, ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Custom Image URL Input
              CustomTextField(
                controller: urlController,
                label: 'Or Custom Image URL',
                hint: 'https://example.com/my-photo.jpg',
                prefixIcon: LucideIcons.link,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(LucideIcons.check, size: 16),
                label: const Text('Save Custom Image URL', style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () async {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    Navigator.pop(ctx);
                    final success = await context.read<ProfileProvider>().updateProfile({'photo_data': url});
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom profile photo updated!'), backgroundColor: AppColors.success),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Preset Profile Photos
              Text(
                'Preset Photos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: presetImages.map((imgUrl) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await context.read<ProfileProvider>().updateProfile({'photo_data': imgUrl});
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile photo updated!'), backgroundColor: AppColors.success),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Preset Avatars
              Text(
                'Avatar Symbols',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presetAvatars.map((emoji) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await context.read<ProfileProvider>().updateProfile({'photo_data': emoji});
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile avatar updated!'), backgroundColor: AppColors.success),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ProfileProvider>().updateProfile({'photo_data': ''});
            },
            child: const Text('Reset to Initials', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String? photoData, String? userName) {
    final hasPhoto = photoData != null && photoData.trim().isNotEmpty;
    if (!hasPhoto) {
      final initial = (userName != null && userName.isNotEmpty) ? userName[0].toUpperCase() : 'Y';
      return Text(
        initial,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
      );
    }

    final data = photoData.trim();
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(data),
        backgroundColor: AppColors.primary,
      );
    }

    if (data.startsWith('data:image') || (data.length > 100 && !data.contains(' '))) {
      try {
        final cleanBase64 = data.contains(',') ? data.split(',').last : data;
        final bytes = base64Decode(cleanBase64);
        return CircleAvatar(
          radius: 32,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: AppColors.primary,
        );
      } catch (_) {}
    }

    return Text(data, style: const TextStyle(fontSize: 30));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final user = authProvider.user;
    final liveProfile = profileProvider.profile;
    final photoData = liveProfile?.photoData ?? user?.photoData;
    final isRemindersEnabled = liveProfile?.remindersEnabled ?? true;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF6F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header with Clickable Bell Icon Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locProvider.t('profile.title', defaultText: 'My Profile & Settings'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locProvider.t('profile.subtitle', defaultText: 'Manage your profile, accounts & preferences'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  // Top Right Clickable Notification Bell Button
                  GestureDetector(
                    onTap: _showNotificationCenter,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.bell, size: 20, color: AppColors.primary),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // User Profile Card
              InkWell(
                onTap: _showEditProfileDialog,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                      GestureDetector(
                        onTap: _showAvatarSelectionDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _buildProfileAvatar(photoData, user?.name),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(LucideIcons.camera, color: AppColors.primary, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'user@example.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _showAvatarSelectionDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      locProvider.t('profile.change_photo', defaultText: 'Change Photo'),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(LucideIcons.pencil, size: 11, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Linked Bank Accounts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locProvider.t('profile.linked_banks', defaultText: 'Linked Bank Accounts'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddBankDialog,
                    child: Row(
                      children: [
                        const Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          locProvider.t('profile.add_bank', defaultText: 'Add Bank'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (profileProvider.banks.isEmpty)
                GestureDetector(
                  onTap: _showAddBankDialog,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(LucideIcons.landmark, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locProvider.t('profile.no_banks', defaultText: 'No bank accounts linked yet.'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                locProvider.t('profile.no_banks_sub', defaultText: 'Add your bank account to track transactions.'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                )
              else
                ...profileProvider.banks.map(
                  (bank) => InkWell(
                    onTap: () => _showBankDetailsDialog(bank),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.landmark, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text('A/C: ${bank.maskedAcc} • IFSC: ${bank.ifscCode ?? "N/A"}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevron_right, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Settings & Compliance Section
              Text(
                locProvider.t('settings.compliance', defaultText: 'Settings & Compliance'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              Container(
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
                child: Column(
                  children: [
                    // App Language Selector Item
                    _buildSettingsRow(
                      icon: LucideIcons.globe,
                      iconBg: const Color(0xFFFDF4FF),
                      iconColor: const Color(0xFFC026D3),
                      title: locProvider.t('language.preference', defaultText: 'App Language'),
                      subtitle: locProvider.t('language.preference_sub', defaultText: 'Change app language (English, हिन्दी, తెలుగు)'),
                      onTap: () => showLanguageSelectorDialog(context),
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),

                    // Privacy Policy Item
                    _buildSettingsRow(
                      icon: LucideIcons.shield_check,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: locProvider.t('privacy.policy', defaultText: 'Privacy Policy'),
                      subtitle: locProvider.t('privacy.policy_sub', defaultText: 'Read our privacy policy'),
                      onTap: () => context.push('/privacy-policy'),
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),

                    // Terms of Use Item
                    _buildSettingsRow(
                      icon: LucideIcons.file_text,
                      iconBg: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF9333EA),
                      title: locProvider.t('terms.of.use', defaultText: 'Terms of Use'),
                      subtitle: locProvider.t('terms.of.use_sub', defaultText: 'Read our terms and conditions'),
                      onTap: () => context.push('/terms-of-use'),
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),

                    // EMI Reminder Notifications Switch Item
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(LucideIcons.bell, color: Color(0xFF16A34A), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locProvider.t('emi.reminders', defaultText: 'EMI Reminder Notifications'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isRemindersEnabled
                                      ? locProvider.t('emi.reminders_enabled', defaultText: 'Enabled • Daily reminders active')
                                      : locProvider.t('emi.reminders_disabled', defaultText: 'Disabled'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isRemindersEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) async {
                              final provider = context.read<ProfileProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await provider.toggleReminders();
                              if (success && mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(val ? 'EMI Reminders Enabled!' : 'EMI Reminders Disabled.'),
                                    backgroundColor: val ? AppColors.success : Colors.grey[700],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bottom Actions: Sign Out & Delete Account
              CustomButton(
                text: locProvider.t('sign.out', defaultText: 'Sign Out'),
                icon: LucideIcons.log_out,
                backgroundColor: AppColors.primary,
                onPressed: _confirmLogout,
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: isDark ? Colors.transparent : Colors.white,
                ),
                icon: const Icon(LucideIcons.user_x, size: 18),
                label: Text(
                  locProvider.t('delete.account', defaultText: 'Delete Account'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                onPressed: _confirmAccountDeletion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBankDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final accController = TextEditingController();
    final ifscController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: const Text('Add Bank Account', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: nameController, label: 'Bank Name', hint: 'e.g. HDFC Bank'),
            const SizedBox(height: 12),
            CustomTextField(controller: accController, label: 'Account Number', hint: 'e.g. 1234567890'),
            const SizedBox(height: 12),
            CustomTextField(controller: ifscController, label: 'IFSC Code', hint: 'e.g. HDFC0001234'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final bankName = nameController.text.trim();
              final accNum = accController.text.trim();
              final ifsc = ifscController.text.trim();

              if (bankName.isEmpty || accNum.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter bank name and account number.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final provider = context.read<ProfileProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);

              final success = await provider.addBank({
                'bank_name': bankName,
                'account_number': accNum,
                'ifsc_code': ifsc,
              });

              if (mounted) {
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Bank account linked successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  final err = provider.errorMessage ?? 'Failed to link bank account.';
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Bank'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your name',
            ),
            const SizedBox(height: 12),
            Text(
              'Email: ${user?.email ?? ''}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
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
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await context.read<ProfileProvider>().updateProfile({'name': newName});
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBankDetailsDialog(BankModel bank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.landmark, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Bank Account Details',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildBankDetailRow('Bank Name', bank.name, isDark),
                  const Divider(height: 20),
                  _buildBankDetailRow('Masked Account', bank.maskedAcc, isDark),
                  const Divider(height: 20),
                  _buildBankDetailRow('IFSC Code', bank.ifscCode ?? 'N/A', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delete Bank Account Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(LucideIcons.trash_2, size: 18),
              label: const Text('Delete / Unlink Bank Account', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDeleteBank(bank);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteBank(BankModel bank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.triangle_alert, color: AppColors.error, size: 20),
            SizedBox(width: 10),
            Text('Unlink Bank Account?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${bank.name}" (${bank.maskedAcc}) from your account?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final provider = context.read<ProfileProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);

              final success = await provider.deleteBank(bank.id);
              if (mounted) {
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Bank account deleted successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete bank account.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    final locProvider = context.read<LocalizationProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locProvider.t('dialog.sign_out_title', defaultText: 'Sign Out')),
        content: Text(locProvider.t('dialog.sign_out_msg', defaultText: 'Are you sure you want to sign out of SMART-EMI?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locProvider.t('cancel', defaultText: 'Cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: Text(locProvider.t('sign.out', defaultText: 'Sign Out')),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion() {
    final locProvider = context.read<LocalizationProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locProvider.t('dialog.delete_account_title', defaultText: 'Delete Account')),
        content: Text(locProvider.t('dialog.delete_account_msg', defaultText: 'Are you sure you want to delete your account? This action is permanent.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locProvider.t('cancel', defaultText: 'Cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: Text(locProvider.t('delete.account', defaultText: 'Delete Permanently')),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
