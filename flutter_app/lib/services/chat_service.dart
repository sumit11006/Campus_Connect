import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../core/constants.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'api_service.dart';

class ChatService {
  final ApiService apiService;
  socket_io.Socket? _socket;

  ChatService({required this.apiService});

  // ─── Socket.IO Initialization ─────────────────────────────────────────────
  void connectSocket(String token, {
    required Function(ChatMessage) onMessageReceived,
    required Function(String userId, bool isTyping) onTypingReceived,
  }) {
    if (_socket != null && _socket!.connected) return;

    _socket = socket_io.io(
      AppConstants.uploadBaseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.on('receive_message', (data) {
      if (data is Map<String, dynamic>) {
        final message = ChatMessage.fromJson(data);
        onMessageReceived(message);
      }
    });

    _socket!.on('user_typing', (data) {
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String? ?? '';
        final isTyping = data['isTyping'] as bool? ?? false;
        onTypingReceived(userId, isTyping);
      }
    });
  }

  void joinRoom(String conversationId) {
    _socket?.emit('join_room', conversationId);
  }

  void sendSocketMessage(String conversationId, String content) {
    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'content': content,
    });
  }

  void sendTypingStatus(String conversationId, bool isTyping) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ─── REST Endpoints ────────────────────────────────────────────────────────
  Future<List<ConversationItem>> getConversations() async {
    try {
      final response = await apiService.dio.get('/chat/conversations');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['conversations'] as List;
        return list.map((json) => ConversationItem.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch conversations');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<ConversationItem> getOrCreateConversation({
    String? recipientId,
    bool isGroup = false,
    String? groupName,
    String? clubId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'isGroup': isGroup,
      };
      if (recipientId != null) payload['recipientId'] = recipientId;
      if (groupName != null) payload['groupName'] = groupName;
      if (clubId != null) payload['clubId'] = clubId;

      final response = await apiService.dio.post(
        '/chat/conversations',
        data: payload,
      );
      final data = response.data;
      if (data['success'] == true) {
        return ConversationItem.fromJson(data['conversation']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get/create conversation');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response =
          await apiService.dio.get('/chat/conversations/$conversationId/messages');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['messages'] as List;
        return list.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch messages');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<List<ChatMessage>> searchMessages(String query, {String? conversationId, int page = 1, int limit = 20}) async {
    try {
      final queryParams = {
        'q': query,
        'page': page,
        'limit': limit,
      };
      if (conversationId != null) {
        queryParams['conversationId'] = conversationId;
      }

      final response = await apiService.dio.get(
        '/chat/search',
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data['success'] == true) {
        final list = data['messages'] as List;
        return list.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Search failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
