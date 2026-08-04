const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');
const Club = require('../models/Club');
const Event = require('../models/Event');

const TEST_MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/campusconnect_test';

describe('Clubs & Events Endpoints', () => {
  let token = '';
  let clubId = '';
  let eventId = '';

  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(TEST_MONGO_URI);
    }
    await User.deleteMany({ email: /clubtest.*@example\.com/ });
    await Club.deleteMany({ name: /Test Club/ });
    await Event.deleteMany({ title: /Test Event/ });

    // Register a test user
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Club Coordinator',
        email: 'clubtest1@example.com',
        password: 'password123',
        role: 'student',
      });
    token = res.body.token;
  });

  afterAll(async () => {
    await User.deleteMany({ email: /clubtest.*@example\.com/ });
    await Club.deleteMany({ name: /Test Club/ });
    await Event.deleteMany({ title: /Test Event/ });
    await mongoose.connection.close();
  });

  it('GET /api/clubs should return list of clubs', async () => {
    const res = await request(app).get('/api/clubs');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.clubs)).toBe(true);
  });

  it('POST /api/clubs should create a new club', async () => {
    const res = await request(app)
      .post('/api/clubs')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'Test Club Tech 2026',
        description: 'A club dedicated to open source and tech innovations.',
        category: 'Technology',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.club.name).toBe('Test Club Tech 2026');
    clubId = res.body.club._id;
  });

  it('POST /api/clubs/:id/join should join user to club', async () => {
    // Create another user to join
    const userRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Club Member',
        email: 'clubtest2@example.com',
        password: 'password123',
        role: 'student',
      });
    const memberToken = userRes.body.token;

    const res = await request(app)
      .post(`/api/clubs/${clubId}/join`)
      .set('Authorization', `Bearer ${memberToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.memberCount).toBe(2);
  });

  it('POST /api/events should create a new event', async () => {
    const res = await request(app)
      .post('/api/events')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Test Event Hackathon',
        description: '24-hour campus hackathon event.',
        date: new Date(Date.now() + 86400000).toISOString(),
        location: 'Auditorium A',
        clubId: clubId,
        capacity: 50,
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.event.title).toBe('Test Event Hackathon');
    eventId = res.body.event._id;
  });

  it('POST /api/events/:id/register should register user for event', async () => {
    const res = await request(app)
      .post(`/api/events/${eventId}/register`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.registrationCount).toBe(1);
  });
});
