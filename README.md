# 🛒 Classified Ads Mobile Application in Oman

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Feature--Driven-green)
![License](https://img.shields.io/badge/License-MIT-blue)

A modern, cross-platform classified advertisements mobile application designed for local marketplace interactions. It allows users to browse, search, and publish listings across multiple categories such as real estate, vehicles, electronics, and local services.

---

## ✨ Key Features

- **📱 Cross-Platform UI:** Built with Flutter targeting Android & iOS with full **RTL (Right-to-Left)** layout support.
- **🔍 Smart Search & Filtering:** Filter ads by regions, categories, and keyword queries.
- **⭐ Featured Listings:** Dynamic home screen featuring highlighted and top-tier listings.
- **🔐 Navigation & Access Control:** Route guards and authentication state redirection using `GoRouter`.
- **⚡ Reactive State Management:** Predictable state handling powered by `flutter_bloc`.
- **🌐 Network Layer:** Robust RESTful API integration using `Dio` & `Retrofit`.
- **🎨 Modern Material 3 UI:** Clean user interface with custom typography and responsive scaling.

---

## 🛠️ Tech Stack & Dependencies

### Core Framework & Architecture
* **Language:** Dart (`^3.12.2`)
* **Framework:** Flutter (Material Design 3)
* **Architecture:** Feature-Driven Clean Architecture

### Libraries & Packages
| Category | Library / Tool | Purpose |
| :--- | :--- | :--- |
| **State Management** | `flutter_bloc` | Managing UI states reactively |
| **Routing** | `go_router` | Declarative routing with auth redirection logic |
| **Networking** | `dio` & `retrofit` | RESTful API client with customizable interceptors |
| **Dependency Injection** | `get_it` & `injectable` | Service locator and dependency injection |
| **UI & Layout** | `flutter_screenutil` | Responsive scaling across screen sizes |
| **Localization** | `flutter_localizations` | Multi-language and RTL support |

---

## 📁 Project Structure

The project follows a **Feature-Driven Architecture** for high modularity, scalability, and maintainability:

```text
lib/
├── core/                         # Core utilities & global configurations
│   ├── auth/                     # Auth state notifier & session management
│   ├── network/                  # Dio HTTP client setup & network helpers
│   ├── router/                   # AppRouter configuration & route guards
│   └── theme/                    # Color palettes, text styles & ThemeData
│
└── features/                     # Feature modules
    ├── auth/                     # Authentication screens (Login, Register)
    ├── home/                     # Home feed, category grid & featured ads
    │   ├── data/                 # Models & Repositories
    │   └── presentation/         # Pages & Custom Widgets
    ├── listings/                 # Add listing, Favorites & Search interfaces
    └── splash/                   # App onboarding / splash screen
