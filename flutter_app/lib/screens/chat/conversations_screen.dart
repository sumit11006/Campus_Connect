import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
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
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(conversationListProvider.notifier).fetchConversations(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(conversationListProvider.notifier)
                            .fetchConversations(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.conversations.isEmpty
                  ? const Center(
                      child: Text('No messages yet. Start a conversation!'),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(conversationListProvider.notifier)
                          .fetchConversations(),
                      child: ListView.separated(
                        itemCount: state.conversations.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
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

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              backgroundImage: fullAvatarUrl.isNotEmpty
                                  ? NetworkImage(fullAvatarUrl)
                                  : null,
                              child: fullAvatarUrl.isEmpty
                                  ? Text(
                                      title.isNotEmpty ? title[0].toUpperCase() : 'C',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              item.lastMessage.isNotEmpty
                                  ? item.lastMessage
                                  : 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: item.lastMessageAt != null
                                ? Text(
                                    timeFormat.format(item.lastMessageAt!),
                                    style: theme.textTheme.bodySmall,
                                  )
                                : null,
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
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        heroTag: null, // Fixes Hero tag collision exception
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
