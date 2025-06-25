# Flutter Project

This is a Flutter application with biometric authentication and secure token storage.

## 🚀 How to Run This Flutter Project

### 1. Clone the repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 2. Get Flutter packages

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

## ✨ Key Features

- 🔐 **Biometric Authentication**  
  Supports fingerprint or facial recognition to securely log in users.

- 📱 **Platform-Specific Secure Storage**  
  Uses **Android Keystore** and **iOS Keychain** via `flutter_secure_storage` to store authentication tokens safely.

- ⚠️ **Rooted/Jailbroken Device Detection**  
  Automatically detects if the device is rooted or jailbroken and blocks access for security reasons.

- 🔁 **Persistent Login with Token**  
  Generates and stores a unique token after biometric login to keep users signed in across sessions.

- 🔄 **Lifecycle-Aware Security Check**  
  Re-validates biometric authentication every time the app resumes from background.

- 🚪 **Logout Functionality**  
  Easily logs out users and clears all sensitive data with a single tap.

- 🧪 **Fallback Handling**  
  Gracefully handles biometric unavailability and device security warnings.

---

## ✅ Requirements

- Flutter SDK installed (https://flutter.dev/docs/get-started/install)
- Android Studio or Visual Studio Code
- A device or emulator
