const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');
const Note = require('../models/Note');
const LostFound = require('../models/LostFound');

const TEST_MONGO_URI = process.env.MONGO_URI || 'mongodb://mongodb:27017/campusconnect_test';

describe('Extra Modules (Notes & LostFound)', () => {
  let token = '';

  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(TEST_MONGO_URI);
    }
    await User.deleteMany({ email: /extratest.*@example\.com/ });
    await Note.deleteMany({});
    await LostFound.deleteMany({});

    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Extra Tester',
        email: 'extratest1@example.com',
        password: 'password123',
        role: 'student',
      });
    token = res.body.token;
  });

  afterAll(async () => {
    await User.deleteMany({ email: /extratest.*@example\.com/ });
    await Note.deleteMany({});
    await LostFound.deleteMany({});
    await mongoose.connection.close();
  });

  it('GET /api/notes should return notes list', async () => {
    const res = await request(app).get('/api/notes');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.notes)).toBe(true);
  });

  it('GET /api/lostfound should return lost & found items list', async () => {
    const res = await request(app).get('/api/lostfound');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.items)).toBe(true);
  });

  it('POST /api/lostfound should report a lost item', async () => {
    const res = await request(app)
      .post('/api/lostfound')
      .set('Authorization', `Bearer ${token}`)
      .send({
        type: 'lost',
        itemName: 'Blue Backpack',
        description: 'Contains laptop and notebooks.',
        location: 'Library 2nd Floor',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.item.itemName).toBe('Blue Backpack');
  });
});
