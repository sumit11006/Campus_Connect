import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _users = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.dio.get('/users/search?q=$query');

      if (response.data['success'] == true) {
        final list = response.data['users'] as List;
        if (!mounted) return;
        setState(() {
          _users = list.map((e) => User.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search users')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startChat(User targetUser) async {
    try {
      final chatService = ChatService(apiService: ref.read(apiServiceProvider));
      final conversation = await chatService.getOrCreateConversation(
        recipientId: targetUser.id,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
              title: targetUser.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start chat')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            hintStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          onChanged: _searchUsers,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'Find someone',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        'Search for a user to start a chat.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: _users.length,
                  separatorBuilder: (ctx, i) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    
                    String avatarFullUrl = '';
                    if (user.avatarUrl.isNotEmpty) {
                      avatarFullUrl = user.avatarUrl.startsWith('http')
                          ? user.avatarUrl
                          : '${AppConstants.uploadBaseUrl}${user.avatarUrl}';
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: avatarFullUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarFullUrl)
                            : null,
                        child: avatarFullUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(user.email, style: theme.textTheme.bodySmall),
                      trailing: Icon(Icons.chat_bubble_outline_rounded, color: theme.colorScheme.primary),
                      onTap: () => _startChat(user),
                    );
                  },
                ),
    );
  }
}
