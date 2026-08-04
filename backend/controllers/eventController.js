const { validationResult, body } = require('express-validator');
const Event = require('../models/Event');
const Registration = require('../models/Registration');

const createEventValidation = [
  body('title')
    .trim()
    .notEmpty().withMessage('Event title is required')
    .isLength({ min: 2, max: 120 }).withMessage('Title 2-120 chars'),
  body('description')
    .trim()
    .notEmpty().withMessage('Description is required'),
  body('date')
    .notEmpty().withMessage('Date is required')
    .isISO8601().withMessage('Valid date format required'),
  body('location')
    .trim()
    .notEmpty().withMessage('Location is required'),
];

// GET /api/events
const getAllEvents = async (req, res, next) => {
  try {
    const { clubId, upcoming } = req.query;
    const query = {};

    if (clubId) {
      query.clubId = clubId;
    }

    if (upcoming === 'true') {
      query.date = { $gte: new Date() };
    }

    const events = await Event.find(query)
      .populate('createdBy', 'name email avatarUrl')
      .populate('clubId', 'name category bannerUrl')
      .sort({ date: 1 });

    res.status(200).json({
      success: true,
      count: events.length,
      events,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/events/:id
const getEventById = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('createdBy', 'name email avatarUrl')
      .populate('clubId', 'name category bannerUrl');

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    let isRegistered = false;
    if (req.user) {
      const reg = await Registration.findOne({
        eventId: event._id,
        userId: req.user.id,
      });
      isRegistered = !!reg;
    }

    res.status(200).json({
      success: true,
      event,
      isRegistered,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/events
const createEvent = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { title, description, date, location, clubId, imageUrl, capacity } = req.body;

    const event = new Event({
      title,
      description,
      date,
      location,
      clubId: clubId || null,
      createdBy: req.user.id,
      imageUrl: imageUrl || '',
      capacity: capacity ? parseInt(capacity) : null,
    });

    await event.save();

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      event,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/events/:id/register
const registerForEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    if (event.capacity && event.registrationCount >= event.capacity) {
      return res.status(400).json({
        success: false,
        message: 'Event registration is full.',
      });
    }

    const existing = await Registration.findOne({
      eventId: event._id,
      userId: req.user.id,
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'You are already registered for this event.',
      });
    }

    await Registration.create({
      eventId: event._id,
      userId: req.user.id,
    });

    event.registrationCount += 1;
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Registered for event successfully',
      registrationCount: event.registrationCount,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/events/:id/unregister
const unregisterFromEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    const reg = await Registration.findOneAndDelete({
      eventId: event._id,
      userId: req.user.id,
    });

    if (!reg) {
      return res.status(400).json({
        success: false,
        message: 'You are not registered for this event.',
      });
    }

    event.registrationCount = Math.max(0, event.registrationCount - 1);
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Unregistered from event successfully',
      registrationCount: event.registrationCount,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/events/:id/registrants
const getEventRegistrants = async (req, res, next) => {
  try {
    const registrants = await Registration.find({ eventId: req.params.id })
      .populate('userId', 'name email avatarUrl role branch year')
      .sort({ registeredAt: 1 });

    res.status(200).json({
      success: true,
      count: registrants.length,
      registrants,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllEvents,
  getEventById,
  createEvent,
  registerForEvent,
  unregisterFromEvent,
  getEventRegistrants,
  createEventValidation,
};
