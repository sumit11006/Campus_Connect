# 🎓 CampusConnect

**CampusConnect** is a full-stack campus management platform that connects students, faculty, clubs, and administrators through a single, modern ecosystem. It streamlines communication, event management, campus communities, and day-to-day student engagement with a secure and scalable architecture.

The project consists of three core components:

* 📱 **Flutter Mobile App** – Cross-platform application for students and faculty.
* 💻 **Admin Web Panel** – Web dashboard for administrators to manage users, events, clubs, and campus content.
* ⚙️ **Node.js Backend** – RESTful API with real-time communication powered by Socket.IO.

---

# ✨ Features

### 🔐 Role-Based Access Control (RBAC)

* Separate dashboards and permissions for Students, Faculty, Admins, and Super Admins.
* Secure authorization for accessing protected resources.

### 💬 Real-Time Chat

* One-to-one messaging.
* Group conversations.
* Instant message delivery using Socket.IO.

### 📰 Campus Feed

* Share announcements, updates, and posts.
* Support for both text and image content.
* Keep the campus community informed in real time.

### 📅 Event Management

* Create and manage campus events.
* Browse upcoming events.
* RSVP and receive event updates.

### 👥 Clubs & Communities

* Dedicated pages for student organizations.
* Member management.
* Club announcements and activities.

### 🎒 Lost & Found

* Report lost belongings.
* Browse found items posted by other users.
* Help reconnect students with their belongings.

### 🎨 Modern User Experience

* Responsive UI across devices.
* Smooth animations.
* Dark and Light theme support.
* Clean and intuitive interface.

---

# 🛠 Tech Stack

## 📱 Mobile Application

* **Framework:** Flutter (Dart)
* **State Management:** Riverpod
* **Networking:** Dio
* **Real-Time Communication:** Socket.IO Client

## ⚙️ Backend

* **Runtime:** Node.js
* **Framework:** Express.js
* **Database:** MongoDB with Mongoose
* **Authentication:** JWT & bcryptjs
* **Real-Time Communication:** Socket.IO

## 💻 Admin Web Panel

* **Framework:** React.js (Vite)
* **Styling:** Tailwind CSS
* **Icons:** Lucide React
* **Routing:** React Router DOM

---

# 🏗 Architecture

![Architecture Diagram](assets/architecture.png)

---

# 🚀 Getting Started

## Prerequisites

Make sure you have the following installed:

* Node.js (v16 or later)
* MongoDB (Local or MongoDB Atlas)
* Flutter SDK

---

## 1. Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file inside the backend directory and add:

```env
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
```

Start the backend server:

```bash
npm run dev
```

---

## 2. Admin Panel Setup

```bash
cd admin_panel
npm install
npm run dev
```

---

## 3. Flutter App Setup

```bash
cd flutter_app
flutter pub get
flutter run
```

---

# 🔒 Security

* Passwords are securely hashed using **bcryptjs** before being stored.
* Protected API routes require **JWT Bearer Authentication**.
* Role-based authorization ensures users can only access resources permitted for their role.
* Sensitive configuration values such as database credentials and JWT secrets are stored in **`.env`** files and excluded from version control.

---

# 📂 Project Structure

```text
CampusConnect/
│
├── backend/          # Node.js + Express API
├── flutter_app/      # Flutter mobile application
├── admin_panel/      # React admin dashboard
├── assets/           # Images and architecture diagrams
└── README.md
```

---

# 🌟 Future Enhancements

* Push Notifications
* Attendance Management
* Timetable & Academic Calendar
* Assignment Submission
* Online Polls & Surveys
* Campus Marketplace
* AI-powered Campus Assistant

---

# 📄 License

This project is developed for educational purposes and can be extended for production use with additional security, scalability, and deployment configurations.
