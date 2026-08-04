const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');
const Post = require('../models/Post');
const Comment = require('../models/Comment');
const Like = require('../models/Like');

const TEST_MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/campusconnect_test';

describe('Posts & Feed Endpoints', () => {
  let token = '';
  let postId = '';

  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(TEST_MONGO_URI);
    }
    await User.deleteMany({ email: /posttest.*@example\.com/ });
    await Post.deleteMany({ content: /Test Feed Post/ });

    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Post Author',
        email: 'posttest1@example.com',
        password: 'password123',
        role: 'student',
      });
    token = res.body.token;
  });

  afterAll(async () => {
    await User.deleteMany({ email: /posttest.*@example\.com/ });
    await Post.deleteMany({ content: /Test Feed Post/ });
    await Comment.deleteMany({});
    await Like.deleteMany({});
    await mongoose.connection.close();
  });

  it('GET /api/posts should return post feed', async () => {
    const res = await request(app).get('/api/posts');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.posts)).toBe(true);
  });

  it('POST /api/posts should create a new post', async () => {
    const res = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${token}`)
      .send({
        content: 'Test Feed Post: Hello CampusConnect!',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.post.content).toBe('Test Feed Post: Hello CampusConnect!');
    postId = res.body.post._id;
  });

  it('POST /api/posts/:id/like should toggle post like', async () => {
    const res = await request(app)
      .post(`/api/posts/${postId}/like`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.isLiked).toBe(true);
    expect(res.body.likesCount).toBe(1);
  });

  it('POST /api/posts/:id/comments should add a comment to post', async () => {
    const res = await request(app)
      .post(`/api/posts/${postId}/comments`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        text: 'Great post!',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.comment.text).toBe('Great post!');
  });
});
