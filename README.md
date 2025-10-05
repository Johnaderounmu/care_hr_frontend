# CareConnect HR - Flutter Application

A comprehensive HR management system built with Flutter, providing features for both HR administrators and job applicants.

## Features

### Authentication System

### HR Dashboard

### Applicant Dashboard

### Job Application Form

### Profile Management

### Settings

## Architecture

The application follows a clean architecture pattern with:


### Key Technologies


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

4. Set up Firebase:
   - Create a Firebase project
   - Enable Authentication
   - Add your app to the Firebase project
   - Download and place the configuration files

5. Run the application:
```bash
flutter run
```

## Configuration

### Firebase Setup

1. Create a new Firebase project
2. Enable Authentication with Email/Password provider
3. Download `google-services.json` for Android
4. Download `GoogleService-Info.plist` for iOS
5. Place the files in the appropriate directories

### Environment Variables

Create a `.env` file in the root directory:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
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


