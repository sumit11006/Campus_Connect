const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const { ROLES } = require('../config/constants');
const {
  getAllEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  registerForEvent,
  unregisterFromEvent,
  getEventRegistrants,
  createEventValidation,
} = require('../controllers/eventController');

// GET /api/events
router.get('/', optionalAuth, getAllEvents);

// GET /api/events/:id
router.get('/:id', optionalAuth, getEventById);

// POST /api/events — Create event (clubAdmin, faculty, admin only)
router.post(
  '/',
  auth,
  roleCheck(ROLES.CLUB_ADMIN, ROLES.FACULTY, ROLES.ADMIN),
  createEventValidation,
  createEvent
);

// PUT /api/events/:id — Update event
router.put('/:id', auth, updateEvent);

// DELETE /api/events/:id — Delete event
router.delete('/:id', auth, deleteEvent);

// POST /api/events/:id/register
router.post('/:id/register', auth, registerForEvent);

// POST /api/events/:id/unregister
router.post('/:id/unregister', auth, unregisterFromEvent);

// GET /api/events/:id/registrants
router.get('/:id/registrants', auth, getEventRegistrants);

module.exports = router;
