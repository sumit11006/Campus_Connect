const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const { ROLES } = require('../config/constants');
const {
  getStats,
  getRecentActivity,
  getAllUsers,
  updateUserRole,
  toggleUserStatus,
  deleteClub,
  deleteEvent,
  deletePost,
} = require('../controllers/adminController');

// All admin routes require auth AND admin role
router.use(auth);
router.use(roleCheck(ROLES.ADMIN));

// GET /api/admin/stats
router.get('/stats', getStats);

// GET /api/admin/activity
router.get('/activity', getRecentActivity);

// GET /api/admin/users
router.get('/users', getAllUsers);

// PUT /api/admin/users/:id/role
router.put('/users/:id/role', updateUserRole);

// PUT /api/admin/users/:id/toggle-active
router.put('/users/:id/toggle-active', toggleUserStatus);

// DELETE /api/admin/clubs/:id
router.delete('/clubs/:id', deleteClub);

// DELETE /api/admin/events/:id
router.delete('/events/:id', deleteEvent);

// DELETE /api/admin/posts/:id
router.delete('/posts/:id', deletePost);

module.exports = router;
