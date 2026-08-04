const jwt = require('jsonwebtoken');
const Message = require('../models/Message');
const Conversation = require('../models/Conversation');
const User = require('../models/User');

const activeUsers = new Map(); // userId -> socketId

module.exports = (io) => {
  // Middleware for socket auth via JWT handshake
  io.use(async (socket, next) => {
    try {
      const token =
        socket.handshake.auth.token || socket.handshake.headers.authorization;
      if (!token) {
        return next(new Error('Authentication required for socket connection'));
      }

      const cleanToken = token.replace('Bearer ', '');
      const decoded = jwt.verify(cleanToken, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);

      if (!user || !user.isActive) {
        return next(new Error('Invalid user or account deactivated'));
      }

      socket.user = {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
      };

      next();
    } catch (err) {
      next(new Error('Socket authentication failed: ' + err.message));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.user.id;
    activeUsers.set(userId, socket.id);
    console.log(`⚡ Socket connected: ${socket.user.name} (${socket.id})`);

    // Notify all clients of online status
    io.emit('user_connected', {
      userId,
      name: socket.user.name,
    });

    // Join conversation room
    socket.on('join_room', (conversationId) => {
      socket.join(conversationId);
      console.log(`👤 User ${socket.user.name} joined room: ${conversationId}`);
    });

    // Handle private / room message
    socket.on('send_message', async (data) => {
      try {
        const { conversationId, content } = data;
        if (!conversationId || !content || !content.trim()) return;

        const conversation = await Conversation.findById(conversationId);
        if (!conversation) return;

        const message = new Message({
          conversationId,
          senderId: userId,
          content: content.trim(),
          readBy: [userId],
        });

        await message.save();
        await message.populate('senderId', 'name email avatarUrl');

        conversation.lastMessage = content.trim();
        conversation.lastMessageAt = new Date();
        await conversation.save();

        // Broadcast to all participants in the room
        io.to(conversationId).emit('receive_message', message);
      } catch (err) {
        console.error('Error handling socket send_message:', err.message);
      }
    });

    // Typing indicators
    socket.on('typing', ({ conversationId, isTyping }) => {
      socket.to(conversationId).emit('user_typing', {
        userId,
        name: socket.user.name,
        isTyping,
      });
    });

    // Disconnect
    socket.on('disconnect', () => {
      activeUsers.delete(userId);
      console.log(`🔌 Socket disconnected: ${socket.user.name}`);
      io.emit('user_disconnected', { userId });
    });
  });
};
