const mongoose = require('mongoose');

const clubSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Club name is required'],
      unique: true,
      trim: true,
      minlength: [2, 'Club name must be at least 2 characters'],
      maxlength: [100, 'Club name cannot exceed 100 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
    },
    category: {
      type: String,
      trim: true,
      default: 'General',
    },
    bannerUrl: {
      type: String,
      default: '',
    },
    coordinatorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Coordinator ID is required'],
    },
    memberCount: {
      type: Number,
      default: 1, // Coordinator is initial member
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// name already indexed via unique:true
clubSchema.index({ category: 1 });

const Club = mongoose.model('Club', clubSchema);

module.exports = Club;
