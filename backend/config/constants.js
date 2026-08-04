module.exports = {
  // User roles
  ROLES: {
    STUDENT: 'student',
    FACULTY: 'faculty',
    CLUB_ADMIN: 'clubAdmin',
    ADMIN: 'admin',
  },

  // Allowed roles for registration
  ALLOWED_REGISTRATION_ROLES: ['student', 'faculty'],

  // File upload limits (in bytes)
  MAX_IMAGE_SIZE: 5 * 1024 * 1024, // 5MB
  MAX_DOCUMENT_SIZE: 10 * 1024 * 1024, // 10MB

  // Allowed file types
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
  ALLOWED_DOCUMENT_TYPES: ['application/pdf'],

  // Pagination defaults
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100,

  // Lost & Found types
  LOST_FOUND_TYPES: ['lost', 'found'],
};
