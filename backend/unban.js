const mongoose = require('mongoose');
const User = require('./models/User');

const unban = async () => {
  try {
    await mongoose.connect('mongodb://localhost:27017/campusconnect');
    await User.updateOne({ email: 'admin@example.com' }, { isActive: true });
    console.log('Unbanned admin user successfully.');
    process.exit(0);
  } catch(e) {
    console.error(e);
    process.exit(1);
  }
};

unban();
