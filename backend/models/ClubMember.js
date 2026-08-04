const mongoose = require('mongoose');

const clubMemberSchema = new mongoose.Schema(
  {
    clubId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Club',
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    role: {
      type: String,
      enum: ['member', 'coordinator', 'admin'],
      default: 'member',
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Compound unique index to prevent duplicate memberships
clubMemberSchema.index({ clubId: 1, userId: 1 }, { unique: true });

const ClubMember = mongoose.model('ClubMember', clubMemberSchema);

module.exports = ClubMember;
