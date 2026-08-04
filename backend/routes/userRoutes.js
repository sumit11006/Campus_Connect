const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { uploadImage } = require('../middleware/upload');
const {
  getProfile,
  updateProfile,
  uploadAvatar,
  getUserById,
  updateProfileValidation,
  searchUsers,
} = require('../controllers/userController');

// GET /api/users/profile — Get own profile (authenticated)
router.get('/profile', auth, getProfile);

// PUT /api/users/profile — Update own profile (authenticated)
router.put('/profile', auth, updateProfileValidation, updateProfile);

// POST /api/users/profile/avatar — Upload avatar (authenticated)
router.post('/profile/avatar', auth, uploadImage.single('avatar'), uploadAvatar);

// GET /api/users/search — Search for users
router.get('/search', auth, searchUsers);

// GET /api/users/:id — Get a user's public profile
router.get('/:id', auth, getUserById);

module.exports = router;
