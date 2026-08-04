const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const { ROLES } = require('../config/constants');
const {
  getAllEvents,
  getEventById,
  createEvent,
  registerForEvent,
  unregisterFromEvent,
  getEventRegistrants,
  createEventValidation,
} = require('../controllers/eventController');

// GET /api/events
router.get('/', optionalAuth, getAllEvents);

// GET /api/events/:id
router.get('/:id', optionalAuth, getEventById);

// POST /api/events — Create event (clubAdmin, faculty, admin)
router.post(
  '/',
  auth,
  roleCheck(ROLES.CLUB_ADMIN, ROLES.FACULTY, ROLES.ADMIN, ROLES.STUDENT),
  createEventValidation,
  createEvent
);

// POST /api/events/:id/register
router.post('/:id/register', auth, registerForEvent);

// POST /api/events/:id/unregister
router.post('/:id/unregister', auth, unregisterFromEvent);

// GET /api/events/:id/registrants
router.get('/:id/registrants', auth, getEventRegistrants);

module.exports = router;
