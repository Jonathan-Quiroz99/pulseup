# PulseUp

PulseUp is a mobile fitness and gym management application developed with Flutter. The project provides gym members with a centralized experience for managing workouts, tracking physical progress, checking gym attendance, and viewing membership information.

The project was developed as an academic and portfolio project, with a focus on clean architecture, REST API integration, reusable Flutter components, authentication, and a centralized application theme.

---

## Features

### Authentication

* Email and password login
* User registration
* Google Sign-In
* Session management
* Authenticated API requests

### Dashboard

* Personalized welcome screen
* Active workout overview
* Body statistics summary
* Weekly check-in information
* Quick navigation actions

### Workout Routines

* View assigned workout plans
* Display trainer information
* View exercises included in each routine
* Exercise details such as:

  * Sets
  * Repetitions
  * Rest time
  * Muscle group

### Progress Tracking

* Record body measurements
* View current measurements
* Track:

  * Weight
  * Body fat
  * Muscle percentage
  * Waist
  * Chest
  * Arm measurements
* Add notes to measurements
* View measurement history

### Gym Check-In

* Personal member QR code
* Membership status
* Latest gym access
* Check-in history

### Membership & Billing

* Membership information
* Payment status
* Payment method display
* Automatic payment setting
* Account balance information

### Navigation

* Centralized application navigation
* Bottom navigation bar
* Side drawer navigation
* Dashboard, routines, progress, check-in and billing sections

---

## Technologies

### Frontend

* Flutter
* Dart
* Material Design
* Google Sign-In
* QR Flutter

### Backend

PulseUp communicates with a REST API for authentication and member-related data.

The application currently consumes endpoints for:

* Authentication
* User information
* Workout routines
* Body measurements
* Check-ins
* Membership information

### Database / Backend Infrastructure

The backend project uses:

* REST API
* PostgreSQL
* Neon
* Render

---

## Project Architecture

The project follows a feature-oriented structure that separates screens, widgets, models and services.

```text
lib/
│
├── core/
│   ├── navigation/
│   │   └── app_screen.dart
│   │
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       └── app_theme.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── user_session.dart
│   │
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── models/
│   │   ├── services/
│   │   └── widgets/
│   │
│   ├── routines/
│   │   ├── routines_screen.dart
│   │   ├── models/
│   │   ├── services/
│   │   └── widgets/
│   │
│   ├── tracking/
│   │   ├── tracking_screen.dart
│   │   ├── models/
│   │   ├── services/
│   │   └── widgets/
│   │
│   ├── checkin/
│   │   ├── checkin_screen.dart
│   │   ├── models/
│   │   ├── services/
│   │   └── widgets/
│   │
│   └── billing/
│       └── billing_screen.dart
│
├── services/
│   └── api_service.dart
│
└── widgets/
    ├── app_drawer.dart
    └── custom_card.dart
```

---

## Theme System

The application uses a centralized theme system located in:

```text
lib/core/theme/
```

The main theme is configured through `AppTheme.darkTheme`.

Colors, spacing, typography and Material components are centralized so that individual screens and widgets do not need to define their own global visual configuration.

The application uses the centralized theme through:

```dart
MaterialApp(
  theme: AppTheme.darkTheme,
)
```

This allows the visual identity of PulseUp to be modified from a single location.

---

## Navigation

PulseUp uses a centralized navigation state through the `AppScreen` enum.

Current main sections include:

```text
Dashboard
Routines
Tracking
Check-In
Billing
```

The main navigation is handled by `HomeScreen`, which controls the currently selected section and coordinates the bottom navigation and application drawer.

---

## Authentication

The application supports two authentication methods:

```text
Email / Password
Google Sign-In
```

After successful authentication, the application stores the authenticated user's session information through `UserSession`.

The session currently contains information such as:

* Member ID
* Email
* Name
* Role
* Authentication token
* Membership information

---

## REST API Integration

API communication is separated from the UI through service classes.

Examples include:

```text
ApiService
DashboardService
RoutinesService
TrackingService
CheckinService
```

This separation allows screens and widgets to focus primarily on presentation while services handle communication with the backend.

---

## Reusable Components

The application uses reusable widgets to avoid duplicating UI code.

Examples include:

* `CustomCard`
* `AppDrawer`
* `RoutineCard`
* `ExerciseTile`
* `ProgressSummaryCard`
* `MeasurementTile`
* `QRCard`
* `MembershipStatusCard`
* `CheckinHistoryTile`

These components are organized according to the feature they belong to when appropriate.

---

## Design

PulseUp uses a dark fitness-oriented interface with a green accent color.

The visual system is based around:

* Dark surfaces
* High-contrast typography
* Green accent elements
* Rounded cards
* Material components
* Consistent spacing
* Centralized theme configuration

The goal is to provide a modern and consistent mobile experience while keeping the UI components reusable.

---

## Getting Started

### Requirements

Before running the project, install:

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-compatible IDE
* Android SDK
* Git

Verify the Flutter installation:

```bash
flutter doctor
```

---

### Installation

Clone the repository:

```bash
git clone https://github.com/Jonathan-Quiroz99/pulseup.git
```

Navigate into the project:

```bash
cd pulseup
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Backend Configuration

PulseUp requires access to its REST API for authenticated and data-driven functionality.

The API configuration is handled through the application's service layer.

For local development, make sure the backend is running and that the configured API endpoint is accessible from the device or emulator.

---

## Development Status

PulseUp is currently under active development.

Implemented functionality includes:

* Authentication
* Google authentication
* Dashboard
* Workout routines
* Progress tracking
* Body measurements
* QR-based check-in
* Check-in history
* Membership information
* Billing interface
* Centralized application theme
* Reusable UI components
* REST API integration

Some sections, such as payment processing, settings and additional membership functionality, are currently represented by UI components and are planned for future development.

---

## Future Improvements

Planned improvements include:

* Complete payment processing
* Member settings
* Profile management
* Improved session persistence
* More detailed workout tracking
* Progress charts
* Additional gym management functionality
* Improved error handling
* Production-ready configuration
* Automated testing

---

## Project Goals

The main objectives of PulseUp are to demonstrate practical experience developing a complete mobile application using Flutter and a REST backend.

The project focuses on:

* Mobile application development
* REST API consumption
* Authentication
* State management
* Feature-based project organization
* Reusable widgets
* UI/UX consistency
* Database-backed applications
* Git and GitHub workflow

---

## Author

**Jonathan Quiroz**

Ingeniería en Sistemas Computacionales

GitHub:

https://github.com/Jonathan-Quiroz99
