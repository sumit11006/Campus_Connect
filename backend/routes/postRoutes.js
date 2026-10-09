const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const { uploadImage } = require('../middleware/upload');
const {
  getAllPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  toggleLike,
  addComment,
  getPostComments,
  createPostValidation,
  commentValidation,
} = require('../controllers/postController');

// GET /api/posts — Feed list
router.get('/', optionalAuth, getAllPosts);

// GET /api/posts/:id — Post details
router.get('/:id', optionalAuth, getPostById);

// POST /api/posts — Create post (with optional image upload)
router.post(
  '/',
  auth,
  uploadImage.single('image'),
  createPostValidation,
  createPost
);

// PUT /api/posts/:id — Update post
router.put('/:id', auth, updatePost);

// DELETE /api/posts/:id — Delete post
router.delete('/:id', auth, deletePost);

// POST /api/posts/:id/like — Toggle like
router.post('/:id/like', auth, toggleLike);

// GET /api/posts/:id/comments — Get comments
router.get('/:id/comments', optionalAuth, getPostComments);

// POST /api/posts/:id/comments — Add comment
router.post('/:id/comments', auth, commentValidation, addComment);

module.exports = router;
