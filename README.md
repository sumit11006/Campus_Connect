<div align="center">

<img src="https://via.placeholder.com/1200x300/02569B/FFFFFF?text=CampusConnect+Ecosystem" alt="CampusConnect Banner" width="100%" style="border-radius: 12px;"/>

# 🎓 CampusConnect

**A Next-Generation Full-Stack Campus Management Ecosystem**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Socket.IO](https://img.shields.io/badge/Socket.IO-010101?style=for-the-badge&logo=socket.io&logoColor=white)](https://socket.io/)

[Features](#-key-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Getting Started](#-getting-started)

</div>

<br/>

> **CampusConnect** bridges the gap between students, faculty, club administrators, and university management. By unifying communication, event planning, and campus communities into a single, highly responsive platform, it transforms day-to-day student engagement and campus life.

---

## 📖 Overview

The ecosystem is built upon a highly scalable, real-time architecture consisting of three core interconnected components:

1. 📱 **Mobile Client** (Flutter) – A cross-platform, native-feeling application designed for students and faculty on the go.
2. 💻 **Admin Dashboard** (React/Vite) – A powerful, secure web interface for university staff to moderate content and manage the community.
3. ⚙️ **Backend Server** (Node.js) – A robust REST API equipped with WebSocket capabilities for instant data synchronization.

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| **🔐 Role-Based Access Control** | Military-grade RBAC providing isolated, secure dashboard views tailored for Students, Faculty, Admins, and Super Admins. |
| **💬 Real-Time Chat Engine** | Lightning-fast 1-on-1 and group messaging powered by Socket.IO, featuring typing indicators and instant delivery. |
| **📰 Dynamic Campus Feed** | A central hub for announcements. Users can broadcast text and rich-media posts to keep the entire community informed. |
| **📅 Event Orchestration** | End-to-end event management. Seamlessly create, discover, and RSVP to campus events with automated roster updates. |
| **👥 Club Hub** | Dedicated micro-communities for student organizations to manage memberships, host discussions, and broadcast activities. |
| **🎒 Digital Lost & Found** | A centralized noticeboard enabling users to report lost belongings and successfully reconnect them with their owners. |
| **🎨 Premium UI/UX** | Fluid micro-animations, adaptive Dark/Light themes, and a meticulously crafted interface that feels premium on any screen. |

---

## 🛠 Tech Stack

### 📱 Client Architecture
- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** Riverpod
- **Networking:** Dio
- **Real-Time Data:** Socket.IO Client

### ⚙️ Server Architecture
- **Runtime Environment:** [Node.js](https://nodejs.org/)
- **Web Framework:** Express.js
- **Database:** MongoDB & Mongoose ORM
- **Authentication:** JSON Web Tokens (JWT) & bcryptjs
- **WebSockets:** Socket.IO

### 💻 Web Architecture
- **Framework:** [React.js](https://react.dev/) (Vite)
- **Styling Engine:** Tailwind CSS
- **Iconography:** Lucide React
- **Client Routing:** React Router DOM

---

## 🏗 System Architecture

<div align="center">
  <img src="assets/architecture.png" alt="Architecture Diagram" width="85%" style="border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
  <br/>
  <i>A high-level view of the CampusConnect ecosystem topology.</i>
</div>

---

## 🚀 Getting Started

<details>
<summary><strong>👉 Click here to view Prerequisites</strong></summary>
<br/>

Before you begin, ensure you have the following installed on your machine:
* **Node.js** (v16.x or higher)
* **MongoDB** (Local instance running, or a MongoDB Atlas connection string)
* **Flutter SDK** (Configured for iOS/Android/Web)

</details>

<details>
<summary><strong>👉 1️⃣ Backend Server Setup</strong></summary>
<br/>

1. Navigate to the backend directory and install dependencies:
   ```bash
   cd backend
   npm install
   ```
2. Create a `.env` file in the root of the `backend` directory:
   ```env
   PORT=5000
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_super_secret_key
   ```
3. Initialize the development server:
   ```bash
   npm run dev
   ```

</details>

<details>
<summary><strong>👉 2️⃣ Admin Dashboard Setup</strong></summary>
<br/>

1. Navigate to the admin panel directory:
   ```bash
   cd admin_panel
   npm install
   ```
2. Start the Vite development server:
   ```bash
   npm run dev
   ```

</details>

<details>
<summary><strong>👉 3️⃣ Mobile Application Setup</strong></summary>
<br/>

1. Navigate to the flutter app directory:
   ```bash
   cd flutter_app
   flutter pub get
   ```
2. Launch the application on your connected device or emulator:
   ```bash
   flutter run
   ```

</details>

---

## 🔒 Security Posture

CampusConnect implements industry-standard security protocols to ensure data privacy:
* **Password Encryption:** All user passwords are cryptographically salted and hashed using **bcryptjs** prior to database insertion.
* **Stateless Authentication:** Protected routes utilize **JWT Bearer Authentication** with strict expiration and signature verification.
* **Granular Role Verification:** Middleware strictly enforces RBAC, guaranteeing users can only interact with endpoints mapped to their specific clearance level.
* **Environment Isolation:** Sensitive configurations (DB URIs, Secret Keys) are strictly isolated in local `.env` files and omitted from version control.

---

## 📂 Project Structure

```text
CampusConnect/
├── 📁 backend/          # Node.js + Express API & Socket.IO server
├── 📁 flutter_app/      # Cross-platform native mobile client
├── 📁 admin_panel/      # React/Vite administration dashboard
├── 📁 assets/           # Repository media, branding, and diagrams
└── 📄 README.md         # You are here
```

---

## 🌟 Future Roadmap

We are constantly expanding the platform to create the ultimate campus companion:
- [ ] 🔔 **Push Notifications** (Firebase Cloud Messaging integration)
- [ ] 📋 **Smart Attendance** (QR code generation and scanning)
- [ ] 📅 **Academic Calendar Sync** (Timetable integration)
- [ ] 📝 **Assignment Portal** (Submission and grading tracking)
- [ ] 📊 **Campus Pulse** (Online polls & surveys)
- [ ] 🛒 **Student Marketplace** (Peer-to-peer textbook and gear trading)
- [ ] 🤖 **AI Assistant** (RAG-powered campus knowledge base)

---

## 📄 License

This repository is developed for educational and portfolio purposes. It serves as a robust foundational template that can be scaled for production deployment.

<div align="center">
  <br/>
  <i>Engineered with ❤️ for the future of campus connectivity.</i>
</div>
