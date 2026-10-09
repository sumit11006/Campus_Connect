import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/club_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/club_card.dart';
import '../../core/theme.dart';
import 'club_detail_screen.dart';
import 'create_club_screen.dart';

class ClubsListScreen extends ConsumerWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubListProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Clubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(clubListProvider.notifier).fetchClubs(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(context, ref, state.error!)
              : state.clubs.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: () => ref.read(clubListProvider.notifier).fetchClubs(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: state.clubs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
                        itemBuilder: (context, index) {
                          final club = state.clubs[index];
                          return ClubCard(
                            club: club,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClubDetailScreen(clubId: club.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: (authState.isAuthenticated && 
          ['faculty', 'admin'].contains(authState.user?.role))
          ? FloatingActionButton.extended(
              heroTag: 'fab_clubs',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateClubScreen(),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
              label: Text(
                'New Club',
                style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_rounded, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No campus clubs found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Be the first to create one!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Oops! Something went wrong.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton.icon(
              onPressed: () => ref.read(clubListProvider.notifier).fetchClubs(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
