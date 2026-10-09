# FitPulse – Home Workouts & Fitness Mobile App
> **Group 06 — Human-Computer Interaction (HCI) Project**

FitPulse is a comprehensive, cross-platform mobile application developed using **Flutter** and **Dart**. Designed specifically for beginners and fitness enthusiasts, FitPulse bridges the gap between **Trainees**, **Certified Fitness Trainers**, **Healthcare Advisors (Doctors)**, and **Platform Administrators**. It offers personalized workout plans, real-time MP4 video streaming, live patient consultations, MS Word-style clinical safety guidance editing, and multi-tier database integration powered by **Firebase** and **Supabase**.

---

## 🚀 Key Features by Role

### 🏋️‍♂️ Customer / Trainee Portal
* **Personalized Workout Queue**: Access daily, weekly, and monthly workout plans categorized by difficulty (Beginner, Intermediate, Advanced).
* **Real-time Workout Details & Video Streaming**: Stream trainer-uploaded MP4 exercise videos and 60 FPS motion demonstration animations.
* **Active Workout Session Mode**: Interactive rep and set tracker, rest timer, calorie burn calculator, and real-time form cues.
* **Healthcare Advisor Selection & Real-Time Chat**: Select a SLMC-certified medical doctor and consult them via two-way real-time messaging.
* **Clinical Safety Guidelines**: View doctor-verified warm-up recommendations, precautions, and warning signs linked to workouts.
* **Biometrics & Progress Tracking**: Log height, weight, day streaks, and workout completion rates.

### 👟 Fitness Trainer Portal
* **Workout Curriculum Management**: Create, edit, and publish workout routines with custom titles, descriptions, sets, reps, and rest timers.
* **MP4 Video Uploads**: Upload exercise demonstration videos directly to **Supabase Cloud CDN Storage**.
* **Dual Database Sync**: Workouts save synchronously to Cloud Firestore and Supabase PostgreSQL tables.
* **Trainer Dashboard & Analytics**: Track published routines, active subscriber counts, and draft statuses.

### 🩺 Healthcare Advisor (Doctor) Portal
* **Patient Consultation Inbox**: Receive real-time health inquiries from trainees and send direct replies.
* **MS Word-Style Clinical Guidance Editor**: Create safety protocols using a rich text formatting engine (**Bold**, *Italic*, <u>Underline</u>, Alignment, and Double Quotes) with live MS Word-style preview.
* **Real-time Safety Guidance Attachment**: Review trainer-uploaded workouts (with video playback) and attach, edit, or delete medical safety guidelines.
* **SLMC Credential Verification**: Display SLMC registration badges and medical specialty details.

### 🛡️ Admin Portal
* **Platform User Management**: Create, verify, and moderate Customers, Trainers, Healthcare Advisors, and Admins.
* **Firebase Authentication Integration**: Admin-created users are automatically created in Firebase Auth for immediate sign-in.
* **Account Status Control**: Activate, deactivate, or remove user accounts across the platform in real time.

---

## 🛠️ Technology Stack

| Technology | Purpose | Description & Justification |
| :--- | :--- | :--- |
| **Flutter** | Mobile & Web Framework | Cross-platform framework enabling a single codebase for Android, iOS, and Web. |
| **Dart** | Programming Language | Object-oriented, strongly-typed language optimized for fast UI rendering. |
| **Firebase Auth** | User Authentication | Secure user sign-in, account creation, and credential handling. |
| **Cloud Firestore** | Real-time NoSQL Database | Stores real-time chats, user profiles, safety content, and workout guidelines. |
| **Supabase** | PostgreSQL & Cloud Storage | High-speed CDN storage for uploaded MP4 exercise videos, user photos, and relational tables. |
| **Provider** | State Management | `provider: ^6.1.2` with `ChangeNotifier` manages reactive app state clean architecture. |
| **SharedPreferences** | Local Storage | Persists user preferences, onboarding flags, and session tokens. |
| **Video Player & Lottie** | Media Playback | Smooth MP4 video streaming and 60 FPS vector motion guide animations. |
| **Git & GitHub** | Version Control | Group collaboration, branch management, and commit tracking. |

---

## 📂 Folder & Project Structure

```
lib/
├── main.dart                          # Application Entry Point & Provider Registration
├── firebase_options.dart              # Firebase Credentials Configuration
├── core/
│   ├── config/                        # App Constants & Fallback Configurations
│   ├── models/                        # Data Models (User, Workout, Exercise, AdvisorGuideline)
│   ├── providers/                     # Providers (AuthProvider, WorkoutProvider, HistoryProvider)
│   ├── repositories/                  # Repositories (WorkoutRepository)
│   ├── services/                      # Services (SupabaseService, StorageService)
│   └── theme/                         # FitPulse Color Palette & Typography
├── features/
│   ├── admin/                         # Admin User Management & Reports Screens
│   ├── advisor/                       # Doctor Dashboard, Clinical Guidance Editor & Chat
│   ├── auth/                          # Login, Registration & Role Selection Screens
│   ├── customer/                      # Workout Plans, Exercise Details, Chat & Profile
│   └── trainer/                       # Workout Creation, Video Upload & Management
└── shared/
    ├── screens/                       # App Shells & Pending Verification Screens
    └── widgets/                       # Reusable App Cards, Video Player & Buttons
```

---

## 💻 Setup & Installation Instructions

### Prerequisites
1. **Flutter SDK**: Install [Flutter](https://docs.flutter.dev/get-started/install) (v3.3.0 or higher).
2. **Android Studio / VS Code**: Installed with Flutter & Dart extensions.
3. **Android Emulator / Physical Device**: Running API Level 21 (Android 5.0) or higher.

### Step 1: Clone the Repository
```bash
git clone https://github.com/Gimantha-Dil/Home-workouts-Fitness-Mobile-App-Group-06.git
cd Home-workouts-Fitness-Mobile-App-Group-06
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run Static Code Analysis
Verify that there are no compilation errors:
```bash
flutter analyze
```

### Step 4: Run the Application
* **On Android Emulator / Device**:
  ```bash
  flutter run
  ```
* **On Chrome (Web)**:
  ```bash
  flutter run -d chrome
  ```

---

## ⚙️ Building Release Artifacts

* **Build Android APK**:
  ```bash
  flutter build apk --release
  ```
  The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

* **Build Flutter Web**:
  ```bash
  flutter build web --release
  ```

---

## 👥 Group 06 Team Members
Developed with  by  **Group 06** for the Human-Computer Interaction (HCI) Module.

IT23543096       PRIYASHAN H.L.D                         Fitness Trainer Portal

IT23543478	     GUNASEKARA A.G.A.G.D               Customer(User)

IT23537088	     THARUKA D.L.B                             Healthcare Advisor (Doctor) Portal

IT22240606	     DISSANAYAKE D.M.R.R.                 Admin Portal



 
