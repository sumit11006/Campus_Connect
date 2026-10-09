import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/post_provider.dart';
import '../../core/theme.dart';
import '../../design_system/app_card.dart';
import '../../widgets/event_card.dart';
import '../../design_system/post_card.dart';
import '../../widgets/section_header.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventListProvider.notifier).fetchEvents();
      ref.read(postListProvider.notifier).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final eventState = ref.watch(eventListProvider);
    final postState = ref.watch(postListProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(eventListProvider.notifier).fetchEvents();
          await ref.read(postListProvider.notifier).fetchPosts();
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        user?.name.split(' ').first ?? 'Student',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                ),
                const SizedBox(width: AppTheme.spacingSm),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority Content: Important Announcement
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                      child: AppCard(
                        hasShadow: false,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            Icon(Icons.campaign, color: theme.colorScheme.primary, size: 28),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Campus Registration Open',
                                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Complete your semester registration before Friday.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Upcoming Events
                    const SectionHeader(
                      title: 'Upcoming Events',
                      actionText: 'See All',
                    ),
                    if (eventState.isLoading)
                      const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                    else if (eventState.events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                        child: Text('No upcoming events.'),
                      )
                    else
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                          itemCount: eventState.events.length > 3 ? 3 : eventState.events.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 300,
                              child: Padding(
                                padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                                child: EventCard(
                                  event: eventState.events[index],
                                  onTap: () {
                                    // Handle tap if needed, wait for Phase 3
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Quick Actions
                    const SectionHeader(title: 'Quick Actions'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAction(context, Icons.edit, 'Post'),
                          _buildAction(context, Icons.search, 'Find Club'),
                          _buildAction(context, Icons.map, 'Map'),
                          _buildAction(context, Icons.more_horiz, 'More'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Recent Activity Header
                    const SectionHeader(title: 'Recent Activity'),
                  ],
                ),
              ),
            ),

            // Recent Activity Feed
            if (postState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (postState.posts.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No recent activity.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = postState.posts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingXs),
                      child: PostCard(
                        post: post,
                        onLike: () {
                          if (!authState.isAuthenticated) return;
                          ref.read(postListProvider.notifier).toggleLike(post.id);
                        },
                        onComment: () {
                          // Standard comment interaction
                        },
                      ),
                    );
                  },
                  childCount: postState.posts.length > 5 ? 5 : postState.posts.length,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacing2xl),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open create post
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: AppTheme.shadowSubtle,
          ),
          child: IconButton(
            icon: Icon(icon, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
