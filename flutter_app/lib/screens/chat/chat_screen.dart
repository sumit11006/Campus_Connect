import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String title;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTyping = false;
  String _typingUser = '';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    final chatService = ref.read(chatServiceProvider);
    final apiService = ref.read(apiServiceProvider);
    final token = await apiService.getToken();

    if (token != null) {
      chatService.connectSocket(
        token,
        onMessageReceived: (message) {
          if (message.conversationId == widget.conversationId && mounted) {
            setState(() {
              _messages.add(message);
            });
            _scrollToBottom();
          }
        },
        onTypingReceived: (userId, isTyping) {
          if (mounted) {
            setState(() {
              _isTyping = isTyping;
              _typingUser = isTyping ? 'Someone' : '';
            });
          }
        },
      );
      chatService.joinRoom(widget.conversationId);
    }

    try {
      final list = await chatService.getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = list;
          _isLoading = false;
          _errorMessage = null;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatService = ref.read(chatServiceProvider);
    chatService.sendSocketMessage(widget.conversationId, text);
    _messageController.clear();
    chatService.sendTypingStatus(widget.conversationId, false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (_isTyping)
              Text(
                '$_typingUser is typing...',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage\n\nMake sure your backend is running and you restarted it.', textAlign: TextAlign.center))
                    : _messages.isEmpty
                        ? const Center(child: Text('Say hi! Start the conversation.'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.senderId == currentUserId;
                          return ChatBubble(
                            message: msg,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        final chatService = ref.read(chatServiceProvider);
                        chatService.sendTypingStatus(
                            widget.conversationId, text.isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    elevation: 0,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
