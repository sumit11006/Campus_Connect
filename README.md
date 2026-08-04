# CampusConnect

CampusConnect is a comprehensive platform designed to bridge the gap between students, faculty, and administration within a university campus. It provides a centralized hub for communication, event management, club activities, and campus updates.

The project is structured into three main components:
1. **Flutter Mobile App**: A cross-platform app for students and faculty.
2. **Admin Web Panel**: A web-based dashboard for administrators and super-admins to manage users and content.
3. **Node.js Backend**: A secure REST API and WebSockets server powering the entire platform.

---

## ?? Key Features

* **Role-Based Access Control (RBAC)**: Distinct permissions for Students, Faculty, Admins, and Superadmins.
* **Real-Time Chat**: 1-on-1 and group messaging powered by Socket.IO.
* **Campus Feed**: Share text and image posts with the entire campus.
* **Events Management**: Create, browse, and RSVP to campus events.
* **Clubs & Communities**: Dedicated pages for student organizations, complete with member management.
* **Lost & Found**: A dedicated board to report lost items or find misplaced belongings.
* **Interactive UI**: Fluid animations, dark/light themes, and responsive layouts.

---

## ??? Tech Stack

### Mobile Application
* **Framework**: Flutter (Dart)
* **State Management**: Riverpod
* **Networking**: Dio
* **Real-time**: Socket.IO-client

### Backend API
* **Runtime**: Node.js
* **Framework**: Express.js
* **Database**: MongoDB & Mongoose
* **Authentication**: JSON Web Tokens (JWT) & bcryptjs
* **Real-time**: Socket.IO

### Admin Web Panel
* **Framework**: React.js (Vite)
* **Styling**: Tailwind CSS & Lucide Icons
* **Routing**: React Router DOM

---

### Architecture
![Architecture Diagram](assets/architecture.png)


## ?? Getting Started

### Prerequisites
* [Node.js](https://nodejs.org/) (v16+)
* [MongoDB](https://www.mongodb.com/) (Local or Atlas)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)

### 1. Backend Setup
\\\ash
cd backend
npm install
# Configure your .env file with MONGO_URI and JWT_SECRET
npm run dev
\\\

### 2. Admin Panel Setup
\\\ash
cd admin_panel
npm install
npm run dev
\\\

### 3. Flutter App Setup
\\\ash
cd flutter_app
flutter pub get
flutter run
\\\

---

## ?? Security
* Passwords are cryptographically hashed before storing.
* All sensitive routes are protected by JWT Bearer tokens.
* API endpoints validate user roles before granting administrative permissions.
* Configuration variables (like Database URIs) are strictly kept in \.env\ files and ignored by git.
