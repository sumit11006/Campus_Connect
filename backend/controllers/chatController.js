const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const User = require('../models/User');

// GET /api/chat/conversations
const getConversations = async (req, res, next) => {
  try {
    const conversations = await Conversation.find({
      participantIds: req.user.id,
    })
      .populate('participantIds', 'name email avatarUrl role branch')
      .populate('clubId', 'name bannerUrl')
      .sort({ lastMessageAt: -1 });

    res.status(200).json({
      success: true,
      count: conversations.length,
      conversations,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/chat/conversations
const getOrCreateConversation = async (req, res, next) => {
  try {
    const { recipientId, isGroup, groupName, clubId } = req.body;

    if (!isGroup) {
      if (!recipientId) {
        return res.status(400).json({
          success: false,
          message: 'Recipient ID is required for 1-on-1 chats.',
        });
      }

      // Check if conversation already exists between these two users
      let conversation = await Conversation.findOne({
        isGroup: false,
        participantIds: { $all: [req.user.id, recipientId] },
      }).populate('participantIds', 'name email avatarUrl role branch');

      if (!conversation) {
        conversation = new Conversation({
          isGroup: false,
          participantIds: [req.user.id, recipientId],
        });
        await conversation.save();
        await conversation.populate('participantIds', 'name email avatarUrl role branch');
      }

      return res.status(200).json({
        success: true,
        conversation,
      });
    } else {
      // Group conversation
      let conversation = new Conversation({
        isGroup: true,
        groupName: groupName || 'Group Chat',
        clubId: clubId || null,
        participantIds: [req.user.id],
      });
      await conversation.save();
      await conversation.populate('participantIds', 'name email avatarUrl role branch');

      return res.status(201).json({
        success: true,
        conversation,
      });
    }
  } catch (error) {
    next(error);
  }
};

// GET /api/chat/conversations/:id/messages
const getMessages = async (req, res, next) => {
  try {
    const conversation = await Conversation.findById(req.params.id);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    // Verify participant
    if (!conversation.participantIds.some(id => id.toString() === req.user.id.toString())) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view messages in this conversation.',
      });
    }

    const messages = await Message.find({ conversationId: req.params.id })
      .populate('senderId', 'name email avatarUrl')
      .sort({ createdAt: 1 });

    res.status(200).json({
      success: true,
      count: messages.length,
      messages,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/chat/conversations/:id/messages
const sendMessage = async (req, res, next) => {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Message content is required.',
      });
    }

    const conversation = await Conversation.findById(req.params.id);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    const message = new Message({
      conversationId: conversation._id,
      senderId: req.user.id,
      content: content.trim(),
      readBy: [req.user.id],
    });

    await message.save();
    await message.populate('senderId', 'name email avatarUrl');

    // Update conversation last message
    conversation.lastMessage = content.trim();
    conversation.lastMessageAt = new Date();
    await conversation.save();

    res.status(201).json({
      success: true,
      message,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/chat/search
const searchMessages = async (req, res, next) => {
  try {
    const { q, conversationId, page = 1, limit = 20 } = req.query;
    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query (q) is required.',
      });
    }

    const filter = { $text: { $search: q } };
    if (conversationId) filter.conversationId = conversationId;

    // Additionally, ensure the user is part of the conversation if one isn't specified
    if (!conversationId) {
      const userConversations = await Conversation.find({ participantIds: req.user.id }).select('_id');
      const conversationIds = userConversations.map((c) => c._id);
      filter.conversationId = { $in: conversationIds };
    } else {
      // If a specific conversation is searched, verify user is a participant
      const conversation = await Conversation.findById(conversationId);
      if (!conversation || !conversation.participantIds.some(id => id.toString() === req.user.id.toString())) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to view messages in this conversation.',
        });
      }
    }

    const messages = await Message.find(filter, { score: { $meta: 'textScore' } })
      .sort({ score: { $meta: 'textScore' }, createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .populate('senderId', 'name email avatarUrl');

    res.status(200).json({
      success: true,
      count: messages.length,
      messages,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getConversations,
  getOrCreateConversation,
  getMessages,
  sendMessage,
  searchMessages,
};
