# Care HR Frontend 📱

[![Flutter CI/CD Pipeline](https://github.com/Johnaderounmu/care_hr_frontend/actions/workfl### 🔧 Key Technologies
- **Flutter 3.22.0** - Cross-platform mobile framework
- **Dart 3.4.0** - Programming language
- **Hive** - Local database for offline storage
- **Provider** - State management solution
- **Go Router** - Declarative routing
- **GraphQL** - API communication with backend
- **HTTP Client** - RESTful API integration
- **PostgreSQL Backend** - Robust database backend
- **JWT Authentication** - Secure token-based auth
- **AWS S3** - File storage and document managementl/badge.svg)](https://github.com/Johnaderounmu/care_hr_frontend/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Johnaderounmu/care_hr_frontend/branch/master/graph/badge.svg)](https://codecov.io/gh/Johnaderounmu/care_hr_frontend)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.22.0-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.4.0-blue.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> 📱 **Care HR Frontend** - A comprehensive HR management mobile application built with Flutter, featuring modern UI, offline-first architecture, and seamless user experience.

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Development](#-development)
- [Testing](#-testing)
- [Building & Deployment](#-building--deployment)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🔐 Authentication System
- **Secure Login/Signup** - JWT-based authentication with biometric support
- **Role-based Access** - Separate interfaces for HR Admins and Applicants
- **Password Recovery** - Secure password reset functionality
- **Auto-login** - Remember user sessions securely

### 👔 HR Dashboard
- **Real-time Analytics** - Live metrics and performance indicators
- **Applicant Management** - Comprehensive applicant tracking system
- **Document Review** - Streamlined document approval workflow
- **Hiring Pipeline** - Visual pipeline for recruitment stages
- **Reports & Analytics** - Detailed hiring and performance reports

### 🎯 Applicant Dashboard
- **Application Tracking** - Real-time status updates
- **Document Management** - Secure document upload and storage
- **Profile Management** - Complete profile editing capabilities
- **Notifications** - In-app notifications for important updates
- **Interview Scheduling** - Easy interview management

### 📋 Job Application System
- **Smart Forms** - Dynamic, context-aware application forms
- **Document Upload** - Multi-format document support
- **Application History** - Track all submitted applications
- **Status Updates** - Real-time application status tracking

### 👤 Profile Management
- **Complete Profiles** - Detailed user profile management
- **Skills & Qualifications** - Comprehensive skill tracking
- **Experience Management** - Work history and experience tracking
- **Document Library** - Personal document storage

### ⚙️ Advanced Settings
- **Theme Customization** - Light/Dark mode support
- **Notification Preferences** - Granular notification controls
- **Data Privacy** - GDPR-compliant privacy settings
- **Offline Mode** - Offline-first architecture with sync

## 📱 Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/login.png" width="200px" alt="Login Screen"/>
      <br />
      <sub><b>Login Screen</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/hr_dashboard.png" width="200px" alt="HR Dashboard"/>
      <br />
      <sub><b>HR Dashboard</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/applicant_dashboard.png" width="200px" alt="Applicant Dashboard"/>
      <br />
      <sub><b>Applicant Dashboard</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/screenshots/document_upload.png" width="200px" alt="Document Upload"/>
      <br />
      <sub><b>Document Upload</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/job_application.png" width="200px" alt="Job Application"/>
      <br />
      <sub><b>Job Application</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/profile.png" width="200px" alt="Profile"/>
      <br />
      <sub><b>Profile Management</b></sub>
    </td>
  </tr>
</table>

## 🏗️ Architecture

The application follows a **clean architecture** pattern with clear separation of concerns:

### 📐 Design Patterns
- **Provider Pattern** - State management with ChangeNotifier
- **Repository Pattern** - Data layer abstraction
- **Dependency Injection** - Loose coupling between components
- **MVVM Architecture** - Model-View-ViewModel separation

### 🛠️ Key Technologies
- **Flutter 3.22.0** - Cross-platform mobile framework
- **Dart 3.4.0** - Programming language
- **Hive** - Local database for offline storage
- **Provider** - State management solution
- **Go Router** - Declarative routing
- **GraphQL** - API communication
- **PostgreSQL Backend** - Robust database backend via Care HR Backend
- **JWT Authentication** - Secure token-based authentication
- **AWS S3** - File storage and document management


## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── user_model.g.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── theme_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_header.dart
│       └── loading_screen.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── signup_page.dart
│   │       │   └── forgot_password_page.dart
│   │       └── widgets/
│   │           ├── auth_header.dart
│   │           ├── auth_button.dart
│   │           └── custom_text_field.dart
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── hr_dashboard_page.dart
│   │       │   └── applicant_dashboard_page.dart
│   │       └── widgets/
│   │           ├── dashboard_card.dart
│   │           ├── chart_card.dart
│   │           └── quick_action_button.dart
│   ├── job_application/
│   │   └── presentation/
│   │       └── pages/
│   │           └── application_form_page.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── pages/
│   │           └── profile_page.dart
│   └── settings/
│       └── presentation/
│           └── pages/
│               └── settings_page.dart
└── main.dart
```

## Getting Started

### Prerequisites


### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd CareHR_stich
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. **Set up the Backend**:
   ```bash
   # In a separate terminal, start the backend
   cd ../care_hr_backend
   npm install
   docker-compose up -d  # Start PostgreSQL
   npm run dev          # Start backend server
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

## Configuration

### Backend Setup

1. **Start the Care HR Backend** (in a separate terminal):
   ```bash
   cd ../care_hr_backend
   npm install
   docker-compose up -d  # Start PostgreSQL
   npm run dev          # Start backend server
   ```

2. **Backend will run on**: `http://localhost:4000`
   - GraphQL endpoint: `http://localhost:4000/graphql`
   - REST API: `http://localhost:4000/api`

### Environment Variables

Create a `.env` file in the root directory:

```env
# Backend API Configuration
API_BASE_URL=http://localhost:4000
GRAPHQL_ENDPOINT=http://localhost:4000/graphql

# App Configuration
APP_ENV=development
ENABLE_LOGGING=true

# Optional: Analytics
ENABLE_ANALYTICS=false
```

## Features Implementation Status


## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

## Future Enhancements

## Splitting frontend and backend into separate repositories

If you'd like to maintain the Flutter frontend and Node backend in separate Git repositories, a helper script is provided at `scripts/split_backend.sh`.

Usage:

1. Ensure your working tree is clean and committed.
2. Make the script executable:

```bash
chmod +x scripts/split_backend.sh
```

3. Run the script with the new remote repository URL:

```bash
scripts/split_backend.sh git@github.com:your-org/care-hr-backend.git
```

The script uses `git subtree split` to extract `backend/` history into a branch and push it to the remote `main` branch. After verifying the new repo, optionally remove the `backend/` directory from this repo.

For advanced filtering or rewriting of history, consider using `git filter-repo` instead.

\n+## Local backend & integration tests

This repo includes a minimal backend scaffold under `backend/` that can be used for local development (Postgres + S3 presign + auth endpoints).

To start the backend locally:

1. cd backend
2. npm install
3. docker-compose up -d   # starts Postgres on 5432
4. npm run start

To run the provided integration test for the backend:

1. Ensure the backend is running at http://localhost:4000
2. cd backend && npm run test:integration

There is also a Flutter integration test that exercises the dev auto-login flow. To run it:

1. Ensure you have the integration_test package enabled in `pubspec.yaml` (add dependency if missing)
2. flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart


