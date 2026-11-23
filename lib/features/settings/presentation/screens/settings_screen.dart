import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/core/constants/api_constants.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _buildThemeTile(
                  context,
                  title: 'Light Theme',
                  icon: Icons.light_mode_outlined,
                  isSelected: settings.themeMode == ThemeMode.light,
                  onTap: () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  context,
                  title: 'Dark Theme',
                  icon: Icons.dark_mode_outlined,
                  isSelected: settings.themeMode == ThemeMode.dark,
                  onTap: () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  context,
                  title: 'System Default',
                  icon: Icons.settings_brightness_outlined,
                  isSelected: settings.themeMode == ThemeMode.system,
                  onTap: () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Network & Server Host',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dns_outlined, color: AppColors.primary),
              title: const Text('API Base URL'),
              subtitle: Text(
                ApiConstants.baseUrl,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _editServerHost(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Danger Zone',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.priorityUrgent),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.priorityUrgent, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Permanently remove your account and all data'),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Task Manager v1.0.0 (Production Build)\nBuilt with Flutter & Node.js',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
          : const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  void _editServerHost(BuildContext context, WidgetRef ref) {
    final currentHost = ref.read(settingsProvider).serverHost;
    final controller = TextEditingController(text: currentHost);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Server Host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For physical Android devices on the same Wi-Fi, enter your PC\'s local IP address (e.g. 10.10.28.100). Leave blank for default.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Host or IP',
                hintText: '10.10.28.100',
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
            onPressed: () {
              ref.read(settingsProvider.notifier).setServerHost(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to delete your account? All tasks and personal data will be wiped permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
