## Quick orientation for AI coding agents

This is a Flutter mobile app (Dart) named `care_hr_app`. Key points an agent needs to know to be immediately productive.

### Big-picture architecture (where to look)
- App entry: `lib/main.dart` — initializes Hive, services and registers providers.
- Routing: `lib/core/router/app_router.dart` — app uses `go_router` with a `redirect` that inspects authentication state.
- State & DI: `provider` (ChangeNotifier) — providers are created in `main.dart` (`AuthProvider`, `ThemeProvider`). See `lib/core/providers/`.
- Features layout: `lib/features/<feature>/presentation/...` — UI organized per feature (auth, dashboard, job_application, documents, reports).
- Services & storage: `lib/core/services/` and `lib/features/**/data/services/` — static init methods are called from `main.dart` to seed sample data and setup services.

### Critical developer workflows (exact commands)
- Install deps: `flutter pub get` (root).
- Generate Hive & other codegen artifacts: `flutter packages pub run build_runner build --delete-conflicting-outputs` (required for `*.g.dart` adapters such as `user_model.g.dart`).
- Run app: `flutter run` (or `flutter run -d <device-id>`). Use an Android/iOS emulator or physical device. Ensure Firebase config files are placed first (see below).
- Run tests: `flutter test` (none enforced in repo, but this is the command to run if tests are added).

### Required local configuration / integrations
- Firebase: project uses `firebase_auth` and `firebase_core`. Place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into platform folders before `flutter run`.
- Environment: README references a `.env` with `FIREBASE_API_KEY` and `FIREBASE_PROJECT_ID` — confirm how your environment loader reads it (no dotenv package in `pubspec.yaml`; search code if needed).

### Project-specific patterns & gotchas
- Sample-data init: `main.dart` calls `DocumentService.initializeSampleData()` and many `*.initializeSampleData()` methods. New services should follow this pattern to provide dev seed data.
- Provider init not automatically invoked: `AuthProvider` exposes an `init()` method but providers are created in `main.dart` without calling `init()` there. Search for where `init()` is invoked (some features may call it from UI). Be careful when reasoning about global auth state: `AppRouter.redirect` constructs a fresh `AuthProvider()` instead of using the existing provider — this is a notable pattern/bug to be aware of when modifying routing/auth behavior.
- Routing rules: `AppRouter.redirect` uses `_isAuthRoute(...)` and role checks (`user?.isHRAdmin`, `user?.isApplicant`) to choose dashboards. Modify `app_router.dart` when adding new top-level routes.
- Hive adapters: model files like `lib/core/models/user_model.dart` have generated counterparts `*.g.dart`. Always run build_runner after model changes.

### Where to change common behavior (examples)
- Add a new feature route: update `lib/core/router/app_router.dart` and add pages under `lib/features/<feature>/presentation/pages/`.
- Add a global provider: register in `lib/main.dart`'s `MultiProvider` and ensure any required `init()` is called during app startup.
- Persisted storage: use `StorageService` in `lib/core/services/storage_service.dart` or add a new Hive box; initialize it in `main.dart`.

### Useful files to reference quickly
- `pubspec.yaml` — dependencies and assets.
- `lib/main.dart` — startup sequence and service initialization.
- `lib/core/router/app_router.dart` — routing & auth redirect logic.
- `lib/core/providers/auth_provider.dart` — auth state, permissions and helper methods.
- `lib/core/models/` — data models and generated Hive adapters.

If anything above is unclear or you want the instructions adjusted (more examples, stricter style rules, or permission/role maps), tell me which area to expand and I'll iterate.
