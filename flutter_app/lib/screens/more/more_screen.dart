import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final items = [
      MoreMenuItem(
        icon: Icons.picture_as_pdf,
        color: Colors.orange,
        label: 'Notes & Resources',
        subtitle: 'Share and download lecture notes',
        route: '/notes',
      ),
      MoreMenuItem(
        icon: Icons.search_off,
        color: Colors.red,
        label: 'Lost & Found',
        subtitle: 'Report or find lost campus items',
        route: '/lost-found',
      ),
      MoreMenuItem(
        icon: Icons.person,
        color: Colors.blue,
        label: 'My Profile',
        subtitle: 'View and edit your profile',
        route: '/profile',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.subtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => context.push(item.route),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreMenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final String route;

  const MoreMenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.route,
  });
}
