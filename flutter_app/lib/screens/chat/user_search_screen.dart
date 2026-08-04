import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
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
        setState(() {
          _users = list.map((e) => User.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search users')),
      );
    } finally {
      setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by name or email...',
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
              ? const Center(child: Text('Search for a user to start a chat.'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    
                    String avatarFullUrl = '';
                    if (user.avatarUrl.isNotEmpty) {
                      avatarFullUrl = user.avatarUrl.startsWith('http')
                          ? user.avatarUrl
                          : '${AppConstants.uploadBaseUrl}${user.avatarUrl}';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatarFullUrl.isNotEmpty
                            ? NetworkImage(avatarFullUrl)
                            : null,
                        child: avatarFullUrl.isEmpty
                            ? Text(user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U')
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.chat_bubble_outline),
                      onTap: () => _startChat(user),
                    );
                  },
                ),
    );
  }
}
