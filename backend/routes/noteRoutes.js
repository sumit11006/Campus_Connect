const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const { uploadDocument } = require('../middleware/upload');
const { getAllNotes, createNote } = require('../controllers/noteController');

// GET /api/notes
router.get('/', optionalAuth, getAllNotes);

// POST /api/notes (PDF upload)
router.post('/', auth, uploadDocument.single('file'), createNote);

module.exports = router;
