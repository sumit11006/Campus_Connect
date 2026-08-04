const { validationResult, body } = require('express-validator');
const Club = require('../models/Club');
const ClubMember = require('../models/ClubMember');
const User = require('../models/User');

const createClubValidation = [
  body('name')
    .trim()
    .notEmpty().withMessage('Club name is required')
    .isLength({ min: 2, max: 100 }).withMessage('Name must be 2-100 characters'),
  body('description')
    .trim()
    .notEmpty().withMessage('Description is required')
    .isLength({ max: 1000 }).withMessage('Description max 1000 characters'),
  body('category')
    .optional()
    .trim(),
];

// GET /api/clubs
const getAllClubs = async (req, res, next) => {
  try {
    const clubs = await Club.find({ isActive: true })
      .populate('coordinatorId', 'name email avatarUrl branch')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: clubs.length,
      clubs,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/clubs/:id
const getClubById = async (req, res, next) => {
  try {
    const club = await Club.findById(req.params.id)
      .populate('coordinatorId', 'name email avatarUrl branch');

    if (!club) {
      return res.status(404).json({
        success: false,
        message: 'Club not found',
      });
    }

    // Check if user is a member if authenticated
    let isMember = false;
    if (req.user) {
      const membership = await ClubMember.findOne({
        clubId: club._id,
        userId: req.user.id,
      });
      isMember = !!membership;
    }

    res.status(200).json({
      success: true,
      club,
      isMember,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/clubs
const createClub = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { name, description, category, bannerUrl } = req.body;

    const existing = await Club.findOne({ name });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'A club with this name already exists.',
      });
    }

    const club = new Club({
      name,
      description,
      category: category || 'General',
      bannerUrl: bannerUrl || '',
      coordinatorId: req.user.id,
      memberCount: 1,
    });

    await club.save();

    // Automatically add coordinator as member
    await ClubMember.create({
      clubId: club._id,
      userId: req.user.id,
      role: 'coordinator',
    });

    // Optionally promote user role to clubAdmin if student
    if (req.user.role === 'student') {
      await User.findByIdAndUpdate(req.user.id, { role: 'clubAdmin' });
    }

    res.status(201).json({
      success: true,
      message: 'Club created successfully',
      club,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/clubs/:id/join
const joinClub = async (req, res, next) => {
  try {
    const club = await Club.findById(req.params.id);
    if (!club) {
      return res.status(404).json({
        success: false,
        message: 'Club not found',
      });
    }

    const existingMembership = await ClubMember.findOne({
      clubId: club._id,
      userId: req.user.id,
    });

    if (existingMembership) {
      return res.status(400).json({
        success: false,
        message: 'You are already a member of this club.',
      });
    }

    await ClubMember.create({
      clubId: club._id,
      userId: req.user.id,
      role: 'member',
    });

    club.memberCount += 1;
    await club.save();

    res.status(200).json({
      success: true,
      message: 'Successfully joined club',
      memberCount: club.memberCount,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/clubs/:id/leave
const leaveClub = async (req, res, next) => {
  try {
    const club = await Club.findById(req.params.id);
    if (!club) {
      return res.status(404).json({
        success: false,
        message: 'Club not found',
      });
    }

    const membership = await ClubMember.findOneAndDelete({
      clubId: club._id,
      userId: req.user.id,
    });

    if (!membership) {
      return res.status(400).json({
        success: false,
        message: 'You are not a member of this club.',
      });
    }

    club.memberCount = Math.max(0, club.memberCount - 1);
    await club.save();

    res.status(200).json({
      success: true,
      message: 'Successfully left club',
      memberCount: club.memberCount,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/clubs/:id/members
const getClubMembers = async (req, res, next) => {
  try {
    const members = await ClubMember.find({ clubId: req.params.id })
      .populate('userId', 'name email avatarUrl role branch year')
      .sort({ joinedAt: 1 });

    res.status(200).json({
      success: true,
      count: members.length,
      members,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllClubs,
  getClubById,
  createClub,
  joinClub,
  leaveClub,
  getClubMembers,
  createClubValidation,
};
