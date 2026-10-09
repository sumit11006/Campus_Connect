import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../design_system/app_card.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationListProvider);
    final currentUser = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(conversationListProvider.notifier).fetchConversations(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(theme, ref, state.error!)
              : state.conversations.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(conversationListProvider.notifier)
                          .fetchConversations(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: state.conversations.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: AppTheme.spacingMd),
                        itemBuilder: (context, index) {
                          final item = state.conversations[index];
                          final title = item.getDisplayTitle(currentUser?.id ?? '');
                          final avatar = item.getDisplayAvatar(currentUser?.id ?? '');

                          String fullAvatarUrl = '';
                          if (avatar.isNotEmpty) {
                            fullAvatarUrl = avatar.startsWith('http')
                                ? avatar
                                : '${AppConstants.uploadBaseUrl}$avatar';
                          }

                          return AppCard(
                            padding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    conversationId: item.id,
                                    title: title,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: fullAvatarUrl.isNotEmpty
                                        ? CachedNetworkImageProvider(fullAvatarUrl)
                                        : null,
                                    child: fullAvatarUrl.isEmpty
                                        ? Text(
                                            title.isNotEmpty ? title[0].toUpperCase() : 'C',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppTheme.spacingMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (item.lastMessageAt != null)
                                              Text(
                                                timeFormat.format(item.lastMessageAt!),
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.lastMessage.isNotEmpty
                                              ? item.lastMessage
                                              : 'No messages yet',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_chat', // Fixes Hero tag collision exception
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Icons.chat_bubble_rounded, color: theme.colorScheme.onPrimary),
        label: Text('New Chat', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_rounded, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Start a conversation with a campus friend!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Oops! Something went wrong.', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingXs),
            Text(error, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton.icon(
              onPressed: () => ref.read(conversationListProvider.notifier).fetchConversations(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
