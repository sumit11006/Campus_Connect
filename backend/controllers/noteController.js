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

// DELETE /api/notes/:id
const deleteNote = async (req, res, next) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }

    const isOwner = note.uploaderId.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this note.' });
    }

    await Note.findByIdAndDelete(req.params.id);

    res.status(200).json({ success: true, message: 'Note deleted successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllNotes,
  createNote,
  deleteNote,
};
