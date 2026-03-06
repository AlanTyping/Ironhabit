# Ironhabit ☄️🟡

**Sculpt your discipline. Track your essence.**

Ironhabit is a premium, high-performance habit tracker and emotional journal built with Flutter. Designed with a "Dark Luxury" aesthetic, it combines robust functionality with a sophisticated user experience to help you stay consistent with your goals while keeping an eye on your inner weather.

---

## ✨ Features

- **Advanced Habit Scheduling**: Create habits with specific weekly frequency and time windows (Start/End times).
- **Intelligent Navigation**: A dynamic, auto-centering horizontal day selector that keeps your current focus right in the middle.
- **Inner Climate Calendar**: A professional mood tracker integrated into a clean, minimalist calendar. Register how you feel using high-quality emoji feedback.
- **Glassmorphic UI**: A "Bordeaux & Amber" theme featuring deep gradients, smoky glass effects, and the modern **Outfit** typeface.
- **Fluid Animations**: Powered by `flutter_animate` for organic transitions and satisfying feedback loops.
- **Rock-Solid Persistence**: Local data storage using SQLite, ensuring your data never leaves your device.

---

## 🏗️ Architecture & Tech Stack

Ironhabit is built using industry-standard patterns to ensure scalability and maintainability:

- **Architecture**: Clean Architecture (Domain, Data, Presentation layers).
- **Organization**: **Feature-First** structure.
- **State Management**: [BLoC (Business Logic Component)](https://pub.dev/packages/flutter_bloc).
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) for service location and DI.
- **Database**: [Sqflite](https://pub.dev/packages/sqflite) with [FFI support](https://pub.dev/packages/sqflite_common_ffi) for Windows/Desktop compatibility.
- **UI & Motion**: [Google Fonts (Outfit)](https://pub.dev/packages/google_fonts) and [Flutter Animate](https://pub.dev/packages/flutter_animate).

---

## 📂 Project Structure

```text
lib/
├── core/                # Shared utilities and database helpers
├── features/
│   ├── habits/          # Habit management feature
│   │   ├── data/        # Models, Repositories Impl, Datasources
│   │   ├── domain/      # Entities and Repository Interfaces
│   │   └── presentation/# BLoC and UI (Pages & Widgets)
│   └── mood/            # Emotional calendar feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart # Dependency Injection setup
└── main.dart            # App entry point and global theme
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Dart SDK
- For Windows: Visual Studio with "Desktop development with C++" installed.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ironhabit.git
   ```
2. Navigate to the project folder:
   ```bash
   cd ironhabit
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   # For Mobile
   flutter run
   
   # For Windows Desktop
   flutter run -d windows
   ```

---

## 🎨 Design Philosophy
Ironhabit follows a **"Modern Dark Luxury"** design language. By using a deep #2D0A0A (Bordeaux) background contrasted with vibrant Yellow accents, the app creates a focused, high-energy environment that motivates the user to complete their "Iron" routine.

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
