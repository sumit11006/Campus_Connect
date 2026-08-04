const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  getConversations,
  getOrCreateConversation,
  getMessages,
  sendMessage,
  searchMessages,
} = require('../controllers/chatController');

// All chat routes require authentication
router.use(auth);

// GET /api/chat/search — Search across messages
router.get('/search', searchMessages);

// GET /api/chat/conversations
router.get('/conversations', getConversations);

// POST /api/chat/conversations — Create/get 1-on-1 or group chat
router.post('/conversations', getOrCreateConversation);

// GET /api/chat/conversations/:id/messages
router.get('/conversations/:id/messages', getMessages);

// POST /api/chat/conversations/:id/messages
router.post('/conversations/:id/messages', sendMessage);

module.exports = router;
