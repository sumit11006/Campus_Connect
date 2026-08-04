const LostFound = require('../models/LostFound');

// GET /api/lostfound
const getLostFoundItems = async (req, res, next) => {
  try {
    const { type } = req.query;
    const query = {};
    if (type) query.type = type;

    const items = await LostFound.find(query)
      .populate('reporterId', 'name email avatarUrl branch')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: items.length,
      items,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/lostfound
const createLostFoundItem = async (req, res, next) => {
  try {
    const { type, itemName, description, location } = req.body;
    let imageUrl = req.body.imageUrl || '';

    if (req.file) {
      imageUrl = `/uploads/${req.file.filename}`;
    }

    const item = new LostFound({
      reporterId: req.user.id,
      type,
      itemName,
      description,
      location,
      imageUrl,
    });

    await item.save();
    await item.populate('reporterId', 'name email avatarUrl branch');

    res.status(201).json({
      success: true,
      message: 'Item reported successfully',
      item,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/lostfound/:id/resolve
const resolveItem = async (req, res, next) => {
  try {
    const item = await LostFound.findById(req.params.id);
    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found',
      });
    }

    item.isResolved = true;
    await item.save();

    res.status(200).json({
      success: true,
      message: 'Item marked as resolved',
      item,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getLostFoundItems,
  createLostFoundItem,
  resolveItem,
};
