const express = require('express');
const router = express.Router();
const { auth, optionalAuth } = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const { ROLES } = require('../config/constants');
const {
  getAllClubs,
  getClubById,
  createClub,
  joinClub,
  leaveClub,
  getClubMembers,
  createClubValidation,
} = require('../controllers/clubController');

// GET /api/clubs — Public / optional auth
router.get('/', optionalAuth, getAllClubs);

// GET /api/clubs/:id — Get details
router.get('/:id', optionalAuth, getClubById);

// POST /api/clubs — Create club (faculty, clubAdmin, admin)
router.post(
  '/',
  auth,
  roleCheck(ROLES.FACULTY, ROLES.CLUB_ADMIN, ROLES.ADMIN, ROLES.STUDENT), // allow student creation which elevates to clubAdmin
  createClubValidation,
  createClub
);

// POST /api/clubs/:id/join — Join club
router.post('/:id/join', auth, joinClub);

// POST /api/clubs/:id/leave — Leave club
router.post('/:id/leave', auth, leaveClub);

// GET /api/clubs/:id/members — List club members
router.get('/:id/members', auth, getClubMembers);

module.exports = router;
