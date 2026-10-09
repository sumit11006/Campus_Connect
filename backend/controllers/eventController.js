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
      .sort({ isPinned: -1, date: 1 });

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

// PUT /api/events/:id — Update event (creator or admin only)
const updateEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const isOwner = event.createdBy.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ success: false, message: 'Not authorized to edit this event.' });
    }

    const { title, description, date, location, imageUrl, capacity, priority, isPinned } = req.body;
    if (title) event.title = title;
    if (description) event.description = description;
    if (date) event.date = date;
    if (location) event.location = location;
    if (imageUrl !== undefined) event.imageUrl = imageUrl;
    if (capacity !== undefined) event.capacity = capacity ? parseInt(capacity) : null;
    if (priority !== undefined) event.priority = priority;
    if (isPinned !== undefined && (req.user.role === 'admin' || req.user.role === 'faculty')) {
      event.isPinned = isPinned;
    }

    await event.save();

    res.status(200).json({ success: true, message: 'Event updated successfully', event });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/events/:id — Delete event (creator or admin only)
const deleteEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const isOwner = event.createdBy.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this event.' });
    }

    await Event.findByIdAndDelete(req.params.id);
    // Also remove registrations
    const Registration = require('../models/Registration');
    await Registration.deleteMany({ eventId: req.params.id });

    res.status(200).json({ success: true, message: 'Event deleted successfully' });
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
  updateEvent,
  deleteEvent,
  registerForEvent,
  unregisterFromEvent,
  getEventRegistrants,
  createEventValidation,
};
