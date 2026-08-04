const multer = require('multer');
const path = require('path');
const { ALLOWED_IMAGE_TYPES, ALLOWED_DOCUMENT_TYPES, MAX_IMAGE_SIZE, MAX_DOCUMENT_SIZE } = require('../config/constants');

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '..', process.env.UPLOAD_DIR || 'uploads');
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: userId-timestamp-originalname
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const ext = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, ext)
      .replace(/[^a-zA-Z0-9]/g, '_')
      .substring(0, 50);
    cb(null, `${baseName}-${uniqueSuffix}${ext}`);
  },
});

// File filter for images
const imageFilter = (req, file, cb) => {
  if (ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. Allowed types: ${ALLOWED_IMAGE_TYPES.join(', ')}`), false);
  }
};

// File filter for documents (PDFs)
const documentFilter = (req, file, cb) => {
  if (ALLOWED_DOCUMENT_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. Allowed types: ${ALLOWED_DOCUMENT_TYPES.join(', ')}`), false);
  }
};

// File filter for both images and documents
const mixedFilter = (req, file, cb) => {
  const allAllowed = [...ALLOWED_IMAGE_TYPES, ...ALLOWED_DOCUMENT_TYPES];
  if (allAllowed.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. Allowed types: ${allAllowed.join(', ')}`), false);
  }
};

// Upload middleware for images (avatars, post images, lost&found)
const uploadImage = multer({
  storage,
  fileFilter: imageFilter,
  limits: { fileSize: MAX_IMAGE_SIZE },
});

// Upload middleware for documents (notes/PDFs)
const uploadDocument = multer({
  storage,
  fileFilter: documentFilter,
  limits: { fileSize: MAX_DOCUMENT_SIZE },
});

// Upload middleware for mixed content
const uploadMixed = multer({
  storage,
  fileFilter: mixedFilter,
  limits: { fileSize: MAX_DOCUMENT_SIZE },
});

module.exports = {
  uploadImage,
  uploadDocument,
  uploadMixed,
};
