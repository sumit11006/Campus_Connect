require('dotenv').config();

const http = require('http');
const app = require('./app');
const connectDB = require('./config/db');
const fs = require('fs');
const path = require('path');
const { Server } = require('socket.io');

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, process.env.UPLOAD_DIR || 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log('📁 Created uploads directory');
}

// Create HTTP server
const server = http.createServer(app);

// ─── Socket.IO Setup ────────────────────────────────────────────────────────
const io = new Server(server, {
  cors: {
    origin: ['http://localhost:3000', 'http://localhost:5173', 'http://10.0.2.2:5000'],
    methods: ['GET', 'POST'],
  },
});
require('./sockets/chatSocket')(io);

const PORT = process.env.PORT || 5000;

// ─── Start Server ────────────────────────────────────────────────────────────
const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    // Start listening
    server.listen(PORT, () => {
      console.log(`
╔══════════════════════════════════════════════════╗
║                                                  ║
║   🚀 CampusConnect API Server & Socket.IO        ║
║                                                  ║
║   Port:        ${PORT}                              ║
║   Environment: ${process.env.NODE_ENV || 'development'}                    ║
║   MongoDB:     Connected                         ║
║   Socket.IO:   Active                            ║
║                                                  ║
║   Health:      http://localhost:${PORT}/api/health   ║
║                                                  ║
╚══════════════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Rejection:', err.message);
  server.close(() => process.exit(1));
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err.message);
  process.exit(1);
});

startServer();
