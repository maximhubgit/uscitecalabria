import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uscitecalabria/logic/providers/theme_provider.dart';
import 'package:uscitecalabria/logic/providers/auth_provider.dart';
import 'package:uscitecalabria/utils/constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      width: 160,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 32),
                const SizedBox(height: 6),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.folder,
            label: 'Gruppi',
            onTap: () => context.go('/groups'),
          ),
          _DrawerItem(
            icon: Icons.receipt_long,
            label: 'Voci',
            onTap: () => context.go('/entries'),
          ),
          _DrawerItem(
            icon: Icons.list_alt,
            label: 'Movimenti',
            onTap: () => context.go('/all-transactions'),
          ),
          const Divider(),
          _DrawerItem(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            label: 'Tema',
            onTap: () {
              ref.read(themeModeProvider.notifier).setTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Esci',
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
