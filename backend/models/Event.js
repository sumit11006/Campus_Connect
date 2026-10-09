const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Event title is required'],
      trim: true,
      minlength: [2, 'Title must be at least 2 characters'],
      maxlength: [120, 'Title cannot exceed 120 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
    },
    date: {
      type: Date,
      required: [true, 'Event date and time is required'],
    },
    location: {
      type: String,
      required: [true, 'Location/venue is required'],
      trim: true,
    },
    clubId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Club',
      required: false, // Optional: events can be campus-wide or club-specific
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    imageUrl: {
      type: String,
      default: '',
    },
    capacity: {
      type: Number,
      default: null, // Unlimited if null
    },
    registrationCount: {
      type: Number,
      default: 0,
    },
    priority: {
      type: String,
      enum: ['normal', 'featured', 'urgent'],
      default: 'normal',
    },
    isPinned: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

eventSchema.index({ date: 1 });
eventSchema.index({ clubId: 1 });
eventSchema.index({ createdBy: 1 });

const Event = mongoose.model('Event', eventSchema);

module.exports = Event;
