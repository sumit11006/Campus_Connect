const { validationResult, body } = require('express-validator');
const Post = require('../models/Post');
const Comment = require('../models/Comment');
const Like = require('../models/Like');

const createPostValidation = [
  body('content')
    .trim()
    .notEmpty().withMessage('Post content is required')
    .isLength({ max: 2000 }).withMessage('Content max 2000 characters'),
];

const commentValidation = [
  body('text')
    .trim()
    .notEmpty().withMessage('Comment text is required')
    .isLength({ max: 500 }).withMessage('Comment max 500 characters'),
];

// GET /api/posts
const getAllPosts = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await Post.find()
      .populate('authorId', 'name email avatarUrl role branch')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments();

    // Map user like status if authenticated
    let userLikedPostIds = new Set();
    if (req.user) {
      const postIds = posts.map((p) => p._id);
      const userLikes = await Like.find({
        userId: req.user.id,
        postId: { $in: postIds },
      });
      userLikedPostIds = new Set(userLikes.map((l) => l.postId.toString()));
    }

    const formattedPosts = posts.map((post) => {
      const pObj = post.toObject();
      pObj.isLiked = userLikedPostIds.has(post._id.toString());
      return pObj;
    });

    res.status(200).json({
      success: true,
      count: formattedPosts.length,
      total,
      page,
      pages: Math.ceil(total / limit),
      posts: formattedPosts,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/posts/:id
const getPostById = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id)
      .populate('authorId', 'name email avatarUrl role branch');

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    let isLiked = false;
    if (req.user) {
      const like = await Like.findOne({
        postId: post._id,
        userId: req.user.id,
      });
      isLiked = !!like;
    }

    const pObj = post.toObject();
    pObj.isLiked = isLiked;

    res.status(200).json({
      success: true,
      post: pObj,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/posts
const createPost = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { content } = req.body;
    let imageUrl = req.body.imageUrl || '';

    // Handle image file if uploaded via Multer
    if (req.file) {
      imageUrl = `/uploads/${req.file.filename}`;
    }

    const post = new Post({
      authorId: req.user.id,
      content,
      imageUrl,
    });

    await post.save();
    await post.populate('authorId', 'name email avatarUrl role branch');

    const pObj = post.toObject();
    pObj.isLiked = false;

    res.status(201).json({
      success: true,
      message: 'Post created successfully',
      post: pObj,
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/posts/:id
const deletePost = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Check ownership or admin role
    if (post.authorId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this post',
      });
    }

    await Post.findByIdAndDelete(req.params.id);
    await Comment.deleteMany({ postId: req.params.id });
    await Like.deleteMany({ postId: req.params.id });

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/posts/:id/like
const toggleLike = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    const existingLike = await Like.findOne({
      postId: post._id,
      userId: req.user.id,
    });

    let isLiked = false;

    if (existingLike) {
      // Unlike
      await Like.findByIdAndDelete(existingLike._id);
      post.likesCount = Math.max(0, post.likesCount - 1);
      isLiked = false;
    } else {
      // Like
      await Like.create({
        postId: post._id,
        userId: req.user.id,
      });
      post.likesCount += 1;
      isLiked = true;
    }

    await post.save();

    res.status(200).json({
      success: true,
      likesCount: post.likesCount,
      isLiked,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/posts/:id/comments
const addComment = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    const comment = new Comment({
      postId: post._id,
      authorId: req.user.id,
      text: req.body.text,
    });

    await comment.save();
    await comment.populate('authorId', 'name email avatarUrl role');

    post.commentsCount += 1;
    await post.save();

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
      comment,
      commentsCount: post.commentsCount,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/posts/:id/comments
const getPostComments = async (req, res, next) => {
  try {
    const comments = await Comment.find({ postId: req.params.id })
      .populate('authorId', 'name email avatarUrl role branch')
      .sort({ createdAt: 1 });

    res.status(200).json({
      success: true,
      count: comments.length,
      comments,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllPosts,
  getPostById,
  createPost,
  deletePost,
  toggleLike,
  addComment,
  getPostComments,
  createPostValidation,
  commentValidation,
};
