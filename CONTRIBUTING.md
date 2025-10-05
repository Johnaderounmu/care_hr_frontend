# Contributing to Care HR Frontend 📱

Thank you for your interest in contributing to Care HR Frontend! We welcome contributions from the community and are grateful for your help in making this project better.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Flutter Guidelines](#flutter-guidelines)
- [Submitting Changes](#submitting-changes)
- [Issue Guidelines](#issue-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Flutter SDK >= 3.22.0
- Dart SDK >= 3.4.0
- Android Studio / VS Code with Flutter extensions
- Git
- A GitHub account

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/care_hr_frontend.git
   cd care_hr_frontend
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/Johnaderounmu/care_hr_frontend.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Generate code**:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```
6. **Run the app**:
   ```bash
   flutter run
   ```

## Development Process

### Branching Strategy

We use **Git Flow** for our branching strategy:

- `master` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Creating a Feature Branch

```bash
# Ensure you're on the latest develop branch
git checkout develop
git pull upstream develop

# Create your feature branch
git checkout -b feature/your-feature-name

# Make your changes and commit them
git add .
git commit -m "feat: add your feature description"

# Push to your fork
git push origin feature/your-feature-name
```

## Flutter Guidelines

### Project Structure

Follow the established project structure:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── models/             # Core data models
│   ├── providers/          # State management
│   ├── router/             # Navigation
│   ├── services/           # Core services
│   ├── theme/              # App theming
│   └── widgets/            # Reusable widgets
└── features/               # Feature modules
    └── feature_name/
        ├── data/           # Data layer
        ├── domain/         # Business logic
        └── presentation/   # UI layer
```

### Coding Standards

#### Dart/Flutter Guidelines

- Follow **Dart style guide** and **Flutter best practices**
- Use **meaningful widget and variable names**
- Keep widgets **small and focused**
- Use **const constructors** where possible
- Implement **proper error handling**

#### Widget Guidelines

```dart
// ✅ Good
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.fullName),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}

// ❌ Bad
class UserCard extends StatelessWidget {
  final dynamic user;
  final Function? onTap;
  
  UserCard({this.user, this.onTap});
  
  Widget build(context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        onTap: onTap,
      ),
    );
  }
}
```

### State Management

- Use **Provider** for state management
- Keep state **immutable** where possible
- Use **ChangeNotifier** for complex state
- Implement **proper disposal** of resources

```dart
// ✅ Good
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Navigation

- Use **Go Router** for navigation
- Define routes in **app_router.dart**
- Use **named routes** for navigation
- Implement **proper route guards**

### Styling and Theming

- Use **Theme.of(context)** for colors and text styles
- Define custom styles in **app_theme.dart**
- Use **responsive design** principles
- Support both **light and dark** themes

### Data Management

- Use **Hive** for local storage
- Implement **offline-first** architecture
- Use **repositories** for data access
- Handle **network errors** gracefully

## Testing

### Writing Tests

- Write **widget tests** for UI components
- Write **unit tests** for business logic
- Write **integration tests** for user flows
- Aim for **80%+ code coverage**

```dart
// ✅ Good widget test
group('LoginPage', () {
  testWidgets('should display login form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('should show error when email is invalid', (tester) async {
    // Test implementation
  });
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Run specific test file
flutter test test/features/auth/auth_provider_test.dart
```

## Performance Guidelines

### Optimization Best Practices

- Use **const constructors** extensively
- Implement **lazy loading** for large lists
- Optimize **image loading** and caching
- Use **RepaintBoundary** for expensive widgets
- Profile app performance regularly

### Memory Management

- Dispose **controllers** and **streams** properly
- Use **weak references** where appropriate
- Monitor **memory usage** during development
- Avoid **memory leaks** in providers

## Submitting Changes

### Commit Message Format

We use **Conventional Commits** for commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(auth): add biometric authentication
fix(navigation): resolve deep link navigation issue
docs(readme): update installation instructions
```

### Pre-commit Checklist

Before submitting your changes, ensure:

- [ ] Code follows Flutter/Dart style guidelines
- [ ] All tests pass (`flutter test`)
- [ ] Code is properly formatted (`dart format .`)
- [ ] No analysis issues (`flutter analyze`)
- [ ] App builds successfully on target platforms
- [ ] Documentation is updated if needed
- [ ] Commit messages follow the conventional format

## Pull Request Process

### Before Creating a PR

1. **Sync with upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

2. **Run the full test suite**:
   ```bash
   flutter test
   flutter analyze
   dart format . --set-exit-if-changed
   ```

3. **Test on devices**:
   ```bash
   flutter run -d ios
   flutter run -d android
   ```

### Creating a Pull Request

1. **Push your branch** to your fork
2. **Create a PR** against the `develop` branch
3. **Fill out the PR template** completely
4. **Add screenshots** of UI changes
5. **Link related issues** using keywords (e.g., "Closes #123")
6. **Request reviews** from maintainers

### PR Requirements

Your pull request must:

- [ ] Have a clear, descriptive title
- [ ] Include screenshots for UI changes
- [ ] Include a detailed description of changes
- [ ] Reference related issues
- [ ] Include tests for new functionality
- [ ] Pass all CI checks
- [ ] Be reviewed by at least one maintainer
- [ ] Have an up-to-date branch (rebased on latest develop)

## Issue Guidelines

### Before Creating an Issue

- **Search existing issues** to avoid duplicates
- **Check the documentation** for solutions
- **Test on multiple devices** if relevant

### Creating Quality Issues

- Use the appropriate **issue template**
- Provide **clear, detailed descriptions**
- Include **steps to reproduce** for bugs
- Add **device information** and **screenshots**
- Attach **logs** when helpful

## Community

### Getting Help

- **GitHub Discussions** - For questions and general discussion
- **GitHub Issues** - For bug reports and feature requests
- **Flutter Community** - For general Flutter questions

### Code Reviews

When reviewing:

- Test changes on **multiple devices**
- Check **UI consistency** across platforms
- Verify **accessibility** compliance
- Ensure **performance** is not degraded

## Development Tips

### Useful Commands

```bash
# Start development
flutter run

# Hot reload (in running app)
r

# Hot restart (in running app)
R

# Run on specific device
flutter run -d device_id

# Build for release
flutter build apk --release
flutter build ios --release

# Generate code
flutter packages pub run build_runner build

# Clean project
flutter clean
```

### Debugging

- Use **Flutter Inspector** for widget debugging
- Enable **performance overlay** for performance analysis
- Use **print statements** and **debugger** for logic debugging
- Leverage **VS Code Flutter extensions**

### Platform-Specific Considerations

#### iOS
- Test on **multiple iOS versions**
- Follow **iOS Human Interface Guidelines**
- Handle **safe areas** properly
- Test **app store submission** requirements

#### Android
- Test on **multiple Android versions**
- Follow **Material Design** guidelines
- Handle **different screen sizes** and **densities**
- Test **Google Play** requirements

## Thank You! 🙏

Thank you for contributing to Care HR Frontend! Your efforts help make this project better for everyone. We appreciate your time and expertise.

---

**Questions?** Feel free to reach out via [GitHub Discussions](https://github.com/Johnaderounmu/care_hr_frontend/discussions) or create an issue.