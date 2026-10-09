import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/event_card.dart';
import '../../core/theme.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventListProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(eventListProvider.notifier).fetchEvents(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(context, ref, state.error!)
              : state.events.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: () => ref.read(eventListProvider.notifier).fetchEvents(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: state.events.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
                        itemBuilder: (context, index) {
                          final event = state.events[index];
                          return EventCard(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventDetailScreen(eventId: event.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: (authState.isAuthenticated && 
          ['clubAdmin', 'faculty', 'admin'].contains(authState.user?.role))
          ? FloatingActionButton.extended(
              heroTag: 'fab_events',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateEventScreen(),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
              label: Text(
                'New Event',
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
          Icon(Icons.event_busy_rounded, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No upcoming events',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Be the first to create one for your campus!',
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
              onPressed: () => ref.read(eventListProvider.notifier).fetchEvents(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
