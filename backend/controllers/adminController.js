const User = require('../models/User');
const Club = require('../models/Club');
const Event = require('../models/Event');
const Post = require('../models/Post');
const Comment = require('../models/Comment');
const Message = require('../models/Message');

// GET /api/admin/stats — Analytics summary
const getStats = async (req, res, next) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalClubs = await Club.countDocuments();
    const totalEvents = await Event.countDocuments();
    const totalPosts = await Post.countDocuments();
    const totalMessages = await Message.countDocuments();

    // User breakdown by role
    const students = await User.countDocuments({ role: 'student' });
    const faculty = await User.countDocuments({ role: 'faculty' });
    const clubAdmins = await User.countDocuments({ role: 'clubAdmin' });
    const admins = await User.countDocuments({ role: 'admin' });

    res.status(200).json({
      success: true,
      stats: {
        totalUsers,
        totalClubs,
        totalEvents,
        totalPosts,
        totalMessages,
        roles: {
          students,
          faculty,
          clubAdmins,
          admins,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/admin/activity — Recent platform activity
const getRecentActivity = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const [recentUsers, recentPosts, recentEvents] = await Promise.all([
      User.find().select('name email role createdAt').sort({ createdAt: -1 }).limit(4),
      Post.find().populate('authorId', 'name role').sort({ createdAt: -1 }).limit(4),
      Event.find().select('title createdAt').sort({ createdAt: -1 }).limit(2),
    ]);

    const activities = [
      ...recentUsers.map(u => ({
        type: 'user',
        name: u.name,
        desc: `Joined as ${u.role}`,
        time: u.createdAt,
        color: '#7c3aed',
      })),
      ...recentPosts.map(p => ({
        type: 'post',
        name: p.authorId?.name || 'Unknown',
        desc: `Posted: "${(p.content || '').slice(0, 40)}..."`,
        time: p.createdAt,
        color: '#ec4899',
      })),
      ...recentEvents.map(e => ({
        type: 'event',
        name: e.title,
        desc: 'New event created',
        time: e.createdAt,
        color: '#06b6d4',
      })),
    ]
      .sort((a, b) => new Date(b.time) - new Date(a.time))
      .slice(0, limit);

    res.status(200).json({ success: true, activities });
  } catch (error) {
    next(error);
  }
};

// GET /api/admin/users — List all users (paginated)
const getAllUsers = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const users = await User.find()
      .select('-passwordHash')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments();

    res.status(200).json({
      success: true,
      count: users.length,
      total,
      page,
      pages: Math.ceil(total / limit),
      users,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/admin/users/:id/role — Change user role
const updateUserRole = async (req, res, next) => {
  try {
    const { role } = req.body;
    const allowedRoles = ['student', 'faculty', 'clubAdmin', 'admin'];

    if (!allowedRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        message: `Invalid role. Must be one of: ${allowedRoles.join(', ')}`,
      });
    }

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { role },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      message: `Role updated to ${role}`,
      user,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/admin/users/:id/toggle-active — Ban/Unban user
const toggleUserStatus = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (req.user.id.toString() === user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You cannot ban or deactivate your own account',
      });
    }

    if (user.email === 'admin@example.com') {
      return res.status(403).json({
        success: false,
        message: 'The super admin account cannot be deactivated.',
      });
    }

    user.isActive = !user.isActive;
    await user.save();

    res.status(200).json({
      success: true,
      message: `User account ${user.isActive ? 'activated' : 'deactivated'}`,
      user,
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/admin/clubs/:id — Delete club
const deleteClub = async (req, res, next) => {
  try {
    const club = await Club.findByIdAndDelete(req.params.id);
    if (!club) {
      return res.status(404).json({
        success: false,
        message: 'Club not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Club deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/admin/events/:id — Delete event
const deleteEvent = async (req, res, next) => {
  try {
    const event = await Event.findByIdAndDelete(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/admin/posts/:id — Delete post
const deletePost = async (req, res, next) => {
  try {
    const post = await Post.findByIdAndDelete(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    // Also delete associated comments
    await Comment.deleteMany({ postId: req.params.id });

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getStats,
  getRecentActivity,
  getAllUsers,
  updateUserRole,
  toggleUserStatus,
  deleteClub,
  deleteEvent,
  deletePost,
};
