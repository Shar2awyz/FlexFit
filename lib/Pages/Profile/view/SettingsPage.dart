import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled6/services/settings_service.dart';
import 'package:untitled6/theme/app_colors.dart';
import 'package:untitled6/Pages/Components/app_route.dart';
import 'package:untitled6/Pages/Login/View/LoginScreen.dart';
import 'package:untitled6/services/services.dart';
import '../viewmodel/ProfileViewModel.dart';
import 'EditProfilePage.dart';
import 'ChangePasswordPage.dart';
import 'AboutPage.dart';
import 'package:untitled6/Pages/Social/view/SavedPostsPage.dart';

class SettingsPage extends StatelessWidget {
  final String userid;
  const SettingsPage({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final settingsService = context.watch<SettingsService>();
    final sw = MediaQuery.of(context).size.width;
    final user = vm.user;

    final displayName = user?.fullname.isNotEmpty == true ? user!.fullname : (user?.username ?? 'User');
    final photoUrl = user?.imageUrl;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: context.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 PROFILE HEADER SECTION (Centered)
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: context.accent.withValues(alpha: 0.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: sw * 0.13,
                    backgroundColor: Colors.white24,
                    child: ClipOval(
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              width: sw * 0.26,
                              height: sw * 0.26,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(Icons.person, size: sw * 0.13, color: Colors.white),
                            )
                          : Icon(Icons.person, size: sw * 0.13, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.accent,
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PRO PERFORMANCE MEMBER',
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Update Profile Button
            SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    appRoute((_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: EditProfilePage(userid: userid),
                        )),
                  ).then((updated) {
                    if (updated == true) {
                      vm.loadAll();
                    }
                  });
                },
                child: const Text(
                  'Update Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ⚙️ SETTINGS WRAPPED CARD LIST
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: Column(
                children: [
                  // Dark Mode
                  _buildSettingTile(
                    context: context,
                    leading: _buildLeadingIcon(context, Icons.nightlight_round),
                    title: 'Dark Mode',
                    subtitle: 'Active theme',
                    trailing: Switch.adaptive(
                      value: settingsService.isDark,
                      activeThumbColor: context.accent,
                      activeTrackColor: context.accent.withValues(alpha: 0.5),
                      onChanged: (value) => settingsService.toggleTheme(),
                    ),
                  ),
                  Divider(color: context.divider, height: 1, indent: 16, endIndent: 16),
                  
                  // Weight Unit
                  _buildSettingTile(
                    context: context,
                    leading: _buildLeadingIcon(context, Icons.fitness_center_rounded),
                    title: 'Weight Unit',
                    subtitle: '${settingsService.isKg ? 'KG' : 'LBS'} selected',
                    trailing: Container(
                      width: 110,
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.innerCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => settingsService.setWeightUnit(true),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: settingsService.isKg ? context.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'KG',
                                  style: TextStyle(
                                    color: settingsService.isKg ? Colors.white : context.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => settingsService.setWeightUnit(false),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !settingsService.isKg ? context.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LBS',
                                  style: TextStyle(
                                    color: !settingsService.isKg ? Colors.white : context.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: context.divider, height: 1, indent: 16, endIndent: 16),

                  // Security
                  _buildSettingTile(
                    context: context,
                    leading: _buildLeadingIcon(context, Icons.shield_outlined),
                    title: 'Security',
                    subtitle: 'Passwords & Biometrics',
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        appRoute((_) => const ChangePasswordPage()),
                      );
                    },
                  ),
                  Divider(color: context.divider, height: 1, indent: 16, endIndent: 16),

                  // Saved Posts
                  _buildSettingTile(
                    context: context,
                    leading: _buildLeadingIcon(context, Icons.bookmark_border_rounded),
                    title: 'Saved Posts',
                    subtitle: 'View your bookmarked posts',
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        appRoute((_) => SavedPostsPage(currentUserId: userid)),
                      );
                    },
                  ),
                  Divider(color: context.divider, height: 1, indent: 16, endIndent: 16),

                  // About FlexLog
                  _buildSettingTile(
                    context: context,
                    leading: _buildLeadingIcon(context, Icons.info_outline),
                    title: 'About FlexLog',
                    subtitle: 'v4.2.0 • Pro Performance',
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        appRoute((_) => const AboutPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 🚪 LOGOUT ACCOUNT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true || !context.mounted) return;

                  await supa().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    appRoute((_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent[100]),
                    const SizedBox(width: 8),
                    Text(
                      'LOGOUT ACCOUNT',
                      style: TextStyle(
                        color: Colors.redAccent[100],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.innerCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: context.accent, size: 20),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required Widget leading,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
