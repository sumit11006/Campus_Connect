const Note = require('../models/Note');

// GET /api/notes
const getAllNotes = async (req, res, next) => {
  try {
    const { subject } = req.query;
    const query = {};
    if (subject) query.subject = new RegExp(subject, 'i');

    const notes = await Note.find(query)
      .populate('uploaderId', 'name email avatarUrl branch')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: notes.length,
      notes,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/notes
const createNote = async (req, res, next) => {
  try {
    const { title, subject, description } = req.body;
    let fileUrl = req.body.fileUrl || '';

    if (req.file) {
      fileUrl = `/uploads/${req.file.filename}`;
    }

    if (!fileUrl) {
      return res.status(400).json({
        success: false,
        message: 'PDF file is required.',
      });
    }

    const note = new Note({
      uploaderId: req.user.id,
      title,
      subject,
      description: description || '',
      fileUrl,
    });

    await note.save();
    await note.populate('uploaderId', 'name email avatarUrl branch');

    res.status(201).json({
      success: true,
      message: 'Note uploaded successfully',
      note,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllNotes,
  createNote,
};
