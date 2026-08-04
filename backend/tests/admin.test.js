const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');

const TEST_MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/campusconnect_test';

describe('Admin Endpoints', () => {
  let adminToken = '';
  let studentToken = '';
  let studentId = '';

  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(TEST_MONGO_URI);
    }
    await User.deleteMany({ email: /admintest.*@example\.com/ });

    // Register Super Admin
    const adminRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Super Admin',
        email: 'admintest1@example.com',
        password: 'password123',
        role: 'admin',
      });
    adminToken = adminRes.body.token;

    // Manually promote role in DB if register defaults to student
    await User.findByIdAndUpdate(adminRes.body.user._id, { role: 'admin' });

    // Register regular student
    const studentRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Regular Student',
        email: 'admintest2@example.com',
        password: 'password123',
        role: 'student',
      });
    studentToken = studentRes.body.token;
    studentId = studentRes.body.user._id;
  });

  afterAll(async () => {
    await User.deleteMany({ email: /admintest.*@example\.com/ });
    await mongoose.connection.close();
  });

  it('GET /api/admin/stats should fail for non-admin user', async () => {
    const res = await request(app)
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.statusCode).toBe(403);
  });

  it('GET /api/admin/stats should return analytics stats for admin', async () => {
    const res = await request(app)
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.stats.totalUsers).toBeGreaterThan(0);
  });

  it('PUT /api/admin/users/:id/role should update user role', async () => {
    const res = await request(app)
      .put(`/api/admin/users/${studentId}/role`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ role: 'faculty' });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.user.role).toBe('faculty');
  });

  it('PUT /api/admin/users/:id/toggle-active should deactivate user account', async () => {
    const res = await request(app)
      .put(`/api/admin/users/${studentId}/toggle-active`)
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.user.isActive).toBe(false);
  });
});
