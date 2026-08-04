const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

const TEST_MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/campusconnect_test';

describe('Chat Endpoints', () => {
  let token1 = '';
  let token2 = '';
  let user2Id = '';
  let conversationId = '';

  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(TEST_MONGO_URI);
    }
    await User.deleteMany({ email: /chattest.*@example\.com/ });
    await Conversation.deleteMany({});
    await Message.deleteMany({});

    // Register User 1
    const res1 = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Chat User One',
        email: 'chattest1@example.com',
        password: 'password123',
        role: 'student',
      });
    token1 = res1.body.token;

    // Register User 2
    const res2 = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Chat User Two',
        email: 'chattest2@example.com',
        password: 'password123',
        role: 'student',
      });
    token2 = res2.body.token;
    user2Id = res2.body.user._id;
  });

  afterAll(async () => {
    await User.deleteMany({ email: /chattest.*@example\.com/ });
    await Conversation.deleteMany({});
    await Message.deleteMany({});
    await mongoose.connection.close();
  });

  it('POST /api/chat/conversations should create or get a 1-on-1 conversation', async () => {
    const res = await request(app)
      .post('/api/chat/conversations')
      .set('Authorization', `Bearer ${token1}`)
      .send({
        recipientId: user2Id,
        isGroup: false,
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.conversation).toBeDefined();
    conversationId = res.body.conversation._id;
  });

  it('GET /api/chat/conversations should list user conversations', async () => {
    const res = await request(app)
      .get('/api/chat/conversations')
      .set('Authorization', `Bearer ${token1}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.conversations.length).toBeGreaterThan(0);
  });

  it('POST /api/chat/conversations/:id/messages should send a message', async () => {
    const res = await request(app)
      .post(`/api/chat/conversations/${conversationId}/messages`)
      .set('Authorization', `Bearer ${token1}`)
      .send({
        content: 'Hello from User 1!',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.message.content).toBe('Hello from User 1!');
  });

  it('GET /api/chat/conversations/:id/messages should return messages list', async () => {
    const res = await request(app)
      .get(`/api/chat/conversations/${conversationId}/messages`)
      .set('Authorization', `Bearer ${token2}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.messages.length).toBe(1);
  });
});
