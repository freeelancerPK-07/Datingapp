# 💚 LinkUp — Dating, Creator Discovery & Live Video Consultation App

LinkUp is a next-generation Flutter mobile application engineered for authentic connections, creator discovery, and real-time private 1-on-1 HD video consultations. Built with modern design aesthetics, a unified **Mint & Teal** visual theme, responsive layouts, and zero UI overflow errors.

---

## ✨ Key Features & Capabilities

### 1. 🛡️ Authentication & Onboarding
* **Visual Welcome Screen**: Ambient gradient aesthetics with custom scale and slide route transitions.
* **Flexible Sign-In & Sign-Up**: Name, email, password validation, visibility toggles, and Google/Phone auth options.
* **Mobile OTP Verification Flow**: 6-digit challenge code entry with auto-focus and resend countdown timer.
* **Password Recovery**: Clean reset request handling with safety feedback.

---

### 2. 🎯 10-Step Profile Completion Engine
* **100% Comprehensive Profile Setup**:
  1. Full Name & Display Name
  2. Date of Birth & Age Calculation (18+ verification)
  3. Gender & Sexual Orientation ("Looking For...")
  4. Multi-Photo Gallery (Primary photo selector, photo reordering, upload slot)
  5. Relationship Goals (Long-term, Casual dating, Deep conversations, Marriage vibe)
  6. Profile Prompts (Icebreakers, conversation starters, voice note prompts)
  7. Lifestyle & Interests (Dance, Fashion, Fitness, Travel, Music, Technology)
  8. City, Country & Location preferences
  9. Languages Spoken (Tamil, English, Hindi, Telugu, Malayalam, Kannada, etc.)
  10. Profile Review & 100% Verification Badge
* **Progress Tracking**: Real-time progress bar displaying completion percentage (`Step X of 10 • Y% Completed`).
* **Privacy & Safety Settings**: Toggle online visibility, hide distance, and blocked users management.

---

### 3. 🔒 100% Profile Completion Gate for Creator Discovery
* **Hero Gradient Header Widget**: Always anchored at the top of the Home screen with greeting, brand mark, country selector, diamond balance, and Instagram-style favorites widget.
* **Gated Feed Access**:
  * If the user's profile is incomplete (`!isProfileCompleted`), a dedicated **Completion Banner** appears directly below the top box widget with progress indicators and a one-click *"Complete Profile to Access Creators"* button.
  * Below the banner, a locked creator teaser card explains that video calls and creator feeds unlock upon reaching 100% completion.
  * Once completed, full creator profiles, category tabs, and feeds automatically unlock.

---

### 4. ❤️ Instagram-Style Favorites & Saved Activity (`LikedSavedScreen`)
* **Real-Time Header Badge**: The top-right heart icon on the Home screen header displays an active badge counter reflecting total liked and saved creators.
* **Dedicated Activity Hub**:
  * **Liked Tab ❤️**: Displays all liked creator profiles in a modern 2-column card grid.
  * **Saved Tab 🔖**: Bookmarked creator profiles for quick access later.
* **Card Features**: Online status badge, rating, diamonds-per-minute rate card, instant "Connect" action, and interactive heart/bookmark toggles.

---

### 5. 📸 Discover Creators & Feed (`HomeScreen`)
* **Curated Category Filters**: Featured, Top Rated, Trending, Recommended, and Live Now.
* **Instagram-Style Feed Posts**: High-resolution media, double-tap to like, distance badges, verified badges, rating pill, follower count, bio caption, and hashtags.
* **Instant CTA**: Direct "Book Video Call" button with vibrant gradient on every post.
* **Advanced Multi-Facet Filter Sheet**: Country picker, Gender choice, Age range slider (18–60), Languages multi-select, Online only, and Verified only.

---

### 6. 🌟 Creator Profile & Rate Card (`CreatorDetailScreen`)
* **Visual Gallery Pager**: Smooth pagination with active dot indicators.
* **Detailed Bio & Vibe**: About me, verified badge, response time, rating reviews count, and profile prompts.
* **Platform Standard Services**:
  * 1-on-1 Private Video Calls (10 min, 20 min, 30 min duration options).
  * Instant coin conversion and duration selection.
* **Payment Summary**: Transparent breakdown of coins per minute, total duration, and wallet balance check.

---

### 7. 📹 Active HD Video Call Experience (`ActiveCallScreen`)
* **Live Video Controls**: Flip camera, mute audio, toggle video, and speakerphone.
* **Real-Time Duration & Coin Burn**: Active timer tracking session duration and diamonds consumed.
* **Transparent Commission Split**: Automated 70/30 revenue distribution (70% to Creator, 30% Platform fee) with dynamic coin calculation.
* **Rating & Feedback**: Interactive post-call 5-star rating with tag selections.

---

### 8. 💎 In-App Diamond Wallet & Payments (`WalletScreen`)
* **Balance Overview**: Active diamond coins balance with quick recharge shortcuts.
* **Recharge Packages**: Tiered diamond coin packages with bonus diamonds and promotional badges.
* **Transaction Ledger**: Complete history tracking video call debits, recharge credits, photo purchases, and 100% refund settlements.
* **Mock Payment Gateways**: UPI (GPay, PhonePe, Paytm), Credit/Debit Cards, Net Banking, and instant simulated success.

---

## 🎨 Unified Mint & Teal Design System

All screens and UI components adhere strictly to a unified color palette and typography system:

| Token | Hex Value | Usage |
|---|---|---|
| **Primary Teal** | `#007A78` | Primary brand color, icons, active tab indicators |
| **Deep Teal** | `#005E5D` | Hero gradients, button gradient start |
| **Radiant Mint** | `#00A896` | Accents, gradients, rating stars, active badges |
| **Dark Slate** | `#0F2B32` | Unified text color for all headings, titles, and key elements |
| **Pale Mint/Teal** | `#E5F7F4` | Chip backgrounds, container fills, avatar rings |
| **Border Mint** | `#CEF1EB` | Card borders, dividers, subtle outlines |

* **Typography**: Google Fonts (`Plus Jakarta Sans` for clean UI readability, `Playfair Display` for editorial accents).
* **Responsive Layouts**: Zero pixel-overflow errors across small and large Android & iOS screen sizes.

---

## 📁 Project Architecture & Structure

```
version1/
├── assets/
│   ├── fonts/
│   └── images/
│       ├── adaptive_bg.png
│       ├── adaptive_fg.png
│       ├── app_icon_teal.png
│       ├── linkup_splash.png
│       └── skybound_together.png
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── constants/
│   │   ├── app_icon_base64.dart           # Offline brand logo base64 bytes
│   │   └── svg_assets.dart                # LinkUpTheme color tokens & vectors
│   ├── models/
│   │   ├── creator_model.dart             # Creator data model
│   │   ├── user_profile_model.dart        # 10-Step User Profile model
│   │   └── wallet_model.dart              # Wallet transaction model
│   ├── screens/
│   │   ├── active_call_screen.dart        # Live video call & commission split
│   │   ├── creator_detail_screen.dart     # Creator profile, gallery & booking
│   │   ├── creator_profile_sheet.dart     # Quick bottom sheet profile preview
│   │   ├── edit_profile_screen.dart       # Edit profile & photo management
│   │   ├── email_signup_screen.dart       # Email signup screen
│   │   ├── home_screen.dart               # Main feed, header & 100% completion gate
│   │   ├── liked_saved_screen.dart        # Instagram-style Favorites & Bookmarks
│   │   ├── login_screen.dart              # Sign in screen
│   │   ├── payment_result_screen.dart     # Payment confirmation & receipt
│   │   ├── phone_verification_screen.dart # 6-digit OTP verification
│   │   ├── profile_self_screen.dart       # User's own profile preview
│   │   ├── profile_setup_screen.dart      # 10-Step interactive profile setup
│   │   ├── recharge_packages_sheet.dart   # Diamond coin packages modal
│   │   ├── signup_screen.dart             # Sign up screen
│   │   ├── splash_screen.dart             # Animated splash with precached assets
│   │   ├── video_calls_screen.dart        # Video call activity & call history
│   │   ├── wallet_screen.dart             # In-app wallet & ledger
│   │   └── welcome_screen.dart            # First-run welcome experience
│   ├── services/
│   │   ├── api_service.dart               # HTTP client & backend contracts
│   │   └── app_state.dart                 # Central ChangeNotifier state singleton
│   └── widgets/
│       └── coin_icon.dart                 # Custom Diamond Coin widget
├── pubspec.yaml                           # Dependencies and asset declarations
└── README.md                              # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.19.0 or higher recommended)
* Dart SDK (3.3.0 or higher)
* Android Studio / Xcode with emulator or physical device

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/freeelancerPK-07/Datingapp.git
   cd Datingapp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis (Verify 0 errors):
   ```bash
   flutter analyze
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is proprietary and developed for LinkUp. All rights reserved.
