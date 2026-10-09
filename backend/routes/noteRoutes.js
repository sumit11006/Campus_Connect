const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const { ROLES } = require('../config/constants');
const { uploadDocument } = require('../middleware/upload');
const { getAllNotes, createNote, deleteNote } = require('../controllers/noteController');

// GET /api/notes
router.get('/', optionalAuth, getAllNotes);

// POST /api/notes (PDF upload — faculty, clubAdmin, admin only)
router.post('/', auth, roleCheck(ROLES.FACULTY, ROLES.CLUB_ADMIN, ROLES.ADMIN), uploadDocument.single('file'), createNote);

// DELETE /api/notes/:id
router.delete('/:id', auth, deleteNote);

module.exports = router;
