# 🚀 LinkUp — Real-Time 1-on-1 Creator Video Consultation & Discovery Platform

**LinkUp** is an enterprise-grade, full-stack real-time platform engineered for private 1-on-1 HD video calling, creator discovery, instant messaging, and a diamond coin wallet economy.

Built with **Flutter (Mobile & Web)**, a **Node.js + Express + TypeScript** real-time backend with **Prisma ORM & PostgreSQL 18**, and a **Vite + Tailwind CSS** admin dashboard.

---

## 🌟 Architecture Overview

```
                      ┌─────────────────────────────────────────┐
                      │             LinkUp Platform             │
                      └────────────────────┬────────────────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         │                                 │                                 │
         ▼                                 ▼                                 ▼
┌──────────────────┐             ┌──────────────────┐             ┌──────────────────┐
│  Flutter Client  │             │ Node.js Backend  │             │ Admin Dashboard  │
│  (Android & Web) │◄──REST/WS──►│  (Express + TS)  │◄──REST API──│  (Vite + React)  │
└────────┬─────────┘             └─────────┬────────┘             └──────────────────┘
         │                                 │
         │ P2P WebRTC HD Video             │ Prisma ORM
         ▼                                 ▼
┌──────────────────┐             ┌──────────────────┐
│ Peer Device / Web│             │  PostgreSQL 18   │
└──────────────────┘             └──────────────────┘
```

---

## 📱 Features Completed & Operational

### 1. 🎥 Real-Time WebRTC 1-on-1 HD Video & Audio Calling
- **Zero-Delay Live Video & Audio**: Powered by `flutter_webrtc` with Cloudflare Anycast & Google STUN clusters for sub-100ms ultra-low latency streaming.
- **Fullscreen Incoming Call Overlay**: Native-style full-screen animated incoming call dialog (`incoming_call_overlay.dart`) that pops up dynamically on the creator's device with Ringing sound, Caller Avatar, Rate/min, and Accept / Reject buttons.
- **Dynamic Picture-in-Picture (PIP)**: Draggable, floating local camera self-preview with Front/Back camera switcher and camera mirror toggles.
- **In-Call Controls**: Live mic mute/unmute, camera enable/disable, camera flip, and loudspeaker toggle.
- **60-Second Real-Time Coin Billing Engine**: Automated server-side billing manager (`call-billing.manager.ts`) that runs ticks every 60 seconds, deducting coins from the caller's wallet and crediting the creator in real-time.
- **Live In-Call Recharge**: If coin balance drops below 1 minute, a real-time warning banner displays with a one-click modal to recharge without disconnecting the active video call!

### 2. 💬 Real-Time 1-on-1 Chat & Messaging
- Socket.io live messaging between users and creators.
- Instant delivery, timestamped message bubbles, unread indicators, and message history persistence in PostgreSQL.

### 3. 🔐 Enterprise Authentication & Dual Role Engine
- **Fast2SMS Real SMS Gateway**: Instant 6-digit OTP delivery across India for phone number authentication.
- **Email & Password Authentication**: Secured with bcrypt password hashing and 7-day signed JWT tokens.
- **Dual Role Switching**: Seamlessly toggle between `USER` and `CREATOR` modes from the profile screen with a single tap.
- **10-Step Interactive Profile Engine**: 100% profile completion gateway with photo galleries, lifestyle tags, relationship goals, and languages.

### 4. 💎 Diamond Coin Economy & Wallet System
- **Real-Time Wallet**: Live coin balance, recharge packages with promotional bonuses, and complete transaction ledger.
- **Automated Commission Split**: 70% credited to creator, 30% platform revenue distribution on every completed call session.
- **Payment Verification**: Mock & Razorpay payment integration with automated wallet credit callbacks.

### 5. 👑 Creator Studio & Discovery Feed
- **Live Creator Feed**: Categories (Trending, Top Rated, Live Now), multi-facet search filters (Age, Gender, Languages, Price range).
- **Creator Studio Dashboard**: Live pricing configuration (Video call coins/min, Voice call coins/min), earnings analytics, followers count, and availability toggles (`isOnline`, `isAvailable`).

### 6. 🛡️ PostgreSQL 18 & Prisma ORM Backend
- Relational schema covering `User`, `UserProfile`, `Creator`, `Wallet`, `WalletTransaction`, `CallSession`, `ChatMessage`, and `AdminSetting`.
- Global administrative killswitch controls (instant video disable, freeze balance, commission percentage override).

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Frontend Mobile & Web** | Flutter 3.x, Dart 3.x, Google Fonts (`Plus Jakarta Sans`), `flutter_webrtc`, `socket_io_client`, `flutter_secure_storage` |
| **Backend API & Signaling** | Node.js 18+, TypeScript, Express.js, Socket.io (WebSocket), Prisma ORM |
| **Database** | PostgreSQL 18 (Local & Cloud compatible) |
| **Video Engine** | WebRTC (Unified-Plan SDP, Cloudflare & Google STUN, IPv6 transport) |
| **SMS Gateway** | Fast2SMS (Production Indian Telecom Route) |
| **Admin Dashboard** | React, Vite, Tailwind CSS, Lucide Icons |

---

## 🚀 Quick Setup & Installation Guide

### 1. Prerequisites
- **Flutter SDK** (`>= 3.19.0`) -> [flutter.dev](https://flutter.dev)
- **Node.js** (`>= 18.0.0`) -> [nodejs.org](https://nodejs.org)
- **PostgreSQL 18** -> Running locally on port `5432`

---

### 2. Backend Setup (`version1/backend`)

1. Open terminal and navigate to backend directory:
   ```bash
   cd version1/backend
   ```

2. Install Node dependencies:
   ```bash
   npm install
   ```

3. Configure `.env` file (create `version1/backend/.env`):
   ```env
   PORT=5000
   NODE_ENV=development
   DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/linkup_db?schema=public"
   JWT_SECRET="linkup_super_secret_jwt_key_2026_secured"
   JWT_EXPIRES_IN="7d"
   FAST2SMS_API_KEY="YOUR_FAST2SMS_KEY"
   ```

4. Push Prisma schema to PostgreSQL:
   ```bash
   npx prisma db push
   ```

5. Start the backend development server:
   ```bash
   npm run dev
   ```
   *Backend will run at: `http://localhost:5000` (LAN: `http://<YOUR_LOCAL_IP>:5000`)*

---

### 3. Flutter App Setup (`version1`)

1. Open a new terminal in the `version1` folder:
   ```bash
   cd version1
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

3. Launch on **Flutter Web**:
   ```bash
   flutter run -d chrome
   ```

4. Launch on **Android Physical Device**:
   - Connect phone via USB with USB Debugging enabled.
   - Run:
     ```bash
     flutter run -d <device_id>
     ```

---

### 4. Admin Dashboard Setup (`version1/admin-dashboard`)

1. Navigate to admin dashboard directory:
   ```bash
   cd version1/admin-dashboard
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start Vite dev server:
   ```bash
   npm run dev
   ```
   *Dashboard will be available at: `http://localhost:5173`*

---

## 🌐 Network Configuration for Physical Device Video Calling

For instantaneous, 0ms zero-delay WebRTC video calling between your laptop and physical Android device during development:

1. **Option A (Wi-Fi Router / Mobile Hotspot):**
   - Connect both your Laptop and your Android Phone to the **same Wi-Fi network** (or connect both to a third mobile's hotspot).
   - Find your laptop's Wi-Fi IP using `ipconfig` (e.g. `192.168.1.15`).
   - Ensure `lib/services/api_service.dart` has your laptop IP in `baseUrl`.

2. **Option B (USB Reverse):**
   - With your phone connected via USB:
     ```bash
     adb reverse tcp:5000 tcp:5000
     ```
   - Phone will access backend directly via `localhost:5000`!

---

## 📁 Repository Directory Structure

```text
version1/
├── android/                    # Android native configuration & permissions
├── assets/                     # Images, vectors, app icons & fonts
├── backend/                    # Node.js + Express + TypeScript + Prisma Backend
│   ├── prisma/
│   │   └── schema.prisma       # Database models & relationships
│   ├── src/
│   │   ├── lib/                # Prisma client & utility helpers
│   │   ├── routes/             # Auth, Call, Chat, Creator, Wallet REST APIs
│   │   ├── services/           # Real-time Call Billing Manager & SMS Service
│   │   └── server.ts           # Express app & Socket.io WebRTC signaling server
│   └── package.json
├── admin-dashboard/            # React + Vite + Tailwind Admin Panel
├── lib/                        # Flutter Core Application
│   ├── constants/              # Theme tokens & SVG asset definitions
│   ├── models/                 # Strong Dart models (Creator, Wallet, Profile)
│   ├── screens/                # 23 Production-grade screens
│   │   ├── active_call_screen.dart    # WebRTC Video Call Screen with Live Controls
│   │   ├── calling_screen.dart        # Dialing & Ringing Screen
│   │   ├── home_screen.dart           # Creator discovery & feed
│   │   ├── profile_self_screen.dart   # Profile & Creator toggle
│   │   ├── wallet_screen.dart         # Coin wallet & recharge packages
│   │   └── ...
│   ├── services/               # StateNotifier & Engine layer
│   │   ├── api_service.dart           # HTTP API client
│   │   ├── app_state.dart             # Central reactive state singleton
│   │   ├── navigation_service.dart    # Global context navigation key
│   │   └── webrtc_service.dart        # Real-time WebRTC PeerConnection engine
│   ├── widgets/                # Reusable UI widgets & Incoming Call Overlay
│   └── main.dart               # App entrypoint & MaterialApp configuration
├── pubspec.yaml                # Flutter dependencies
└── README.md                   # Project documentation
```

---

## 📄 License & Ownership
Copyright © 2026 LinkUp. All rights reserved.
Developed for LinkUp — Next-Generation Authentic Creator Connections.
