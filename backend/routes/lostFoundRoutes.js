const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const { uploadImage } = require('../middleware/upload');
const {
  getLostFoundItems,
  createLostFoundItem,
  resolveItem,
  deleteItem,
} = require('../controllers/lostFoundController');

// GET /api/lostfound
router.get('/', optionalAuth, getLostFoundItems);

// POST /api/lostfound
router.post('/', auth, uploadImage.single('image'), createLostFoundItem);

// PUT /api/lostfound/:id/resolve
router.put('/:id/resolve', auth, resolveItem);

// DELETE /api/lostfound/:id
router.delete('/:id', auth, deleteItem);

module.exports = router;
