# ✈️ Baggage Fee Estimator (AeroWeigh)

An intuitive, aviation-themed Flutter mobile application designed to calculate excess airline baggage charges, apply statutory service tax (SST), and generate itemized digital boarding-pass receipts.

Developed as a coursework project for **Mobile Technology (Air Travel Baggage Fee Estimator)**.

---

## 📱 App Highlights & Screenshots

| Home / Calculator Screen | Digital Fee Receipt | Developer / About Screen |
|:---:|:---:|:---:|
| *(Add your screenshot here)* | *(Add your screenshot here)* | *(Add your screenshot here)* |

---

## ✨ Features

- **Luggage Weight Input**: Clean numeric input field with decimal formatters and real-time form validation.
- **Cabin Class Selection**:
  - 💺 **Economy Class**: 20 kg complimentary baggage allowance.
  - 🛫 **Business Class**: 40 kg complimentary baggage allowance.
- **Airline Rate Input**: Customizable rate per kg (RM / kg).
- **Automated Calculation & Breakdown**:
  - Excess Baggage Weight ($Weight - Allowance$)
  - Excess Baggage Charge ($Excess \times Rate$)
  - 8% Malaysian Service Tax (SST)
  - Grand Total Payable ($Charge + Tax$)
- **Zero-Fee Allowance Protection**: If baggage weight is within the free tier, the app notifies the passenger with a green zero-fee badge.
- **Digital Boarding Pass Receipt**: Clear, formatted summary displaying itemized breakdown with monospace figures.
- **Form Reset**: Quick reset button that clears fields and returns state with SnackBar feedback.
- **Navigation Bar**: Bottom navigation to switch effortlessly between **Estimator** and **About / Developer** pages.
- **About & Developer Page**: Displays author credentials, release version, and an external clickable GitHub repository link using `url_launcher`.
- **Custom App Branding & Icons**: Tailored aviation color palette (Deep Navy/Teal `#0F2C38`, Warm Coral `#E05A47`, and Soft Mint `#E6F2EF`) with custom adaptive launcher icons.

---

## 🧮 Calculation Logic & Formulas

$$\text{Excess Weight (kg)} = \max(0, \text{Total Weight} - \text{Free Allowance})$$

$$\text{Excess Charge (RM)} = \text{Excess Weight} \times \text{Rate per kg}$$

$$\text{Service Tax (RM)} = \text{Excess Charge} \times 0.08$$

$$\text{Total Payable (RM)} = \text{Excess Charge} + \text{Service Tax}$$

---

## 🛠️ Tech Stack & Packages

- **Framework**: [Flutter](https://flutter.dev/) (Material 3)
- **Language**: [Dart](https://dart.dev/)
- **Dependencies**:
  - `url_launcher`: For opening the GitHub repository in external browser.
  - `cupertino_icons`: iOS-style icon assets.
  - `flutter_launcher_icons` *(dev)*: Automated multi-resolution app icon generation for Android and iOS.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (Dart 3.x+)
- Android Studio / VS Code with Flutter extension
- An Android device/emulator or Google Chrome for web testing

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/baggage.git
   cd baggage
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **(Optional) Re-generate app launcher icons:**
   ```bash
   dart run flutter_launcher_icons
   ```

4. **Run the application:**
   - **For Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```
   - **For Connected Android Device / Emulator:**
     ```bash
     flutter run
     ```

5. **Run widget tests:**
   ```bash
   flutter test
   ```

---

## 📂 Project Structure

```text
baggage/
├── android/               # Native Android configuration & mipmaps
├── assets/
│   ├── icon/              # 1024x1024 master app icon
│   └── images/            # In-app image assets
├── lib/
│   └── main.dart          # Core app UI, calculator logic, & navigation
├── test/
│   └── widget_test.dart   # Smoke and render tests
├── pubspec.yaml           # App dependencies & asset declarations
└── README.md              # Project documentation
```

---

## 👤 Author Information

- **Developer**: Your Name
- **Matric Number**: Your Matric No
- **Programme**: Bachelor of Computer Science
- **Course**: Mobile Technology Assignment

---

## 📄 License

This project is open-source and intended for academic and learning purposes.
