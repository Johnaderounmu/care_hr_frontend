# Care HR Frontend - Deployment Guide

## 🚀 Production Deployment Guide

This comprehensive guide covers deploying the Care HR Frontend application to production environments with advanced security, performance optimization, and monitoring capabilities.

## 📋 Prerequisites

### System Requirements
- **Flutter SDK**: 3.37.0-0.1.pre or higher
- **Dart SDK**: 3.4.0 or higher
- **Node.js**: 18+ (for build tools)
- **Git**: Latest version
- **Docker** (optional): For containerized deployment

### Build Environment
- **RAM**: Minimum 8GB, Recommended 16GB
- **Storage**: 20GB+ free space
- **CPU**: Multi-core processor recommended
- **Network**: Stable internet connection for dependencies

## 🔧 Pre-Deployment Setup

### 1. Environment Configuration

Create environment-specific configuration files:

**.env.production**
```env
# API Configuration
API_BASE_URL=https://api.carehr.com
GRAPHQL_ENDPOINT=https://api.carehr.com/graphql
WEBSOCKET_URL=wss://api.carehr.com/ws

# Security Configuration
ENCRYPTION_KEY=prod_encryption_key_here
JWT_SECRET_KEY=prod_jwt_secret_here
API_KEY=prod_api_key_here

# Performance Configuration
CACHE_ENABLED=true
PERFORMANCE_MONITORING=true
COMPRESSION_ENABLED=true

# Feature Flags
ANALYTICS_ENABLED=true
PUSH_NOTIFICATIONS=true
OFFLINE_MODE=true
DEMO_MODE=false

# Monitoring Configuration
SENTRY_DSN=https://your-sentry-dsn
LOG_LEVEL=error
ERROR_TRACKING=true

# CDN Configuration
ASSETS_CDN=https://cdn.carehr.com
IMAGES_CDN=https://images.carehr.com
```

**.env.staging**
```env
# Similar to production but with staging URLs
API_BASE_URL=https://staging-api.carehr.com
LOG_LEVEL=warn
DEMO_MODE=true
```

### 2. Build Configuration

**pubspec.yaml** optimization for production:
```yaml
name: care_hr_app
description: Enterprise HR Management System
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: ">=3.37.0-0.1.pre"

dependencies:
  # Core Framework
  flutter:
    sdk: flutter
  
  # Production Dependencies
  crypto: ^3.0.3
  logger: ^2.0.2+1
  shared_preferences: ^2.4.14
  
  # Performance
  fl_chart: ^0.68.0
  
  # State Management
  provider: ^6.1.2
  
  # Navigation
  go_router: ^12.1.3
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  # Optimized assets for production
  assets:
    - assets/images/
    - assets/icons/
    - assets/logos/
    - .env.production
```

## 🏗️ Build Process

### 1. Pre-build Validation

```bash
# Validate Flutter installation
flutter doctor -v

# Check for analysis issues
dart analyze --fatal-infos

# Validate dependencies
flutter pub deps

# Run security audit
flutter pub audit

# Generate required files
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Platform-Specific Builds

#### Web Deployment (Primary)
```bash
# Production web build
flutter build web \
  --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --web-renderer canvaskit \
  --base-href /care-hr/ \
  --source-maps \
  --tree-shake-icons

# Staging web build
flutter build web \
  --release \
  --dart-define=ENVIRONMENT=staging \
  --web-renderer html \
  --base-href /staging/
```

**Web Optimization Options:**
- `--web-renderer canvaskit`: Better performance, larger download
- `--web-renderer html`: Faster load, limited features
- `--web-renderer auto`: Automatic selection based on device
- `--source-maps`: Enable for production debugging
- `--tree-shake-icons`: Reduce bundle size

#### Android Deployment
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore care-hr-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias care-hr

# Build Android App Bundle (recommended)
flutter build appbundle \
  --release \
  --dart-define=ENVIRONMENT=production \
  --build-name=1.0.0 \
  --build-number=1

# Build APK (for direct distribution)
flutter build apk \
  --release \
  --dart-define=ENVIRONMENT=production \
  --split-per-abi
```

**Android Configuration (android/app/build.gradle):**
```gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion
    
    defaultConfig {
        applicationId "com.carehr.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### iOS Deployment (macOS only)
```bash
# Build iOS Archive
flutter build ipa \
  --release \
  --dart-define=ENVIRONMENT=production \
  --export-options-plist=ios/ExportOptions.plist

# Alternative: Build for iOS simulator
flutter build ios \
  --release \
  --dart-define=ENVIRONMENT=production
```

**iOS Configuration (ios/Runner/Info.plist):**
```xml
<key>CFBundleDisplayName</key>
<string>Care HR</string>
<key>CFBundleIdentifier</key>
<string>com.carehr.app</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
```

## 🌐 Web Deployment Options

### 1. Static Hosting (Recommended)

#### Netlify Deployment
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build and deploy
flutter build web --release --dart-define=ENVIRONMENT=production
netlify deploy --dir=build/web --prod

# Auto-deployment with Git integration
echo 'build/web' > .netlifyrc
```

**netlify.toml:**
```toml
[build]
  command = "flutter build web --release --dart-define=ENVIRONMENT=production"
  publish = "build/web"

[build.environment]
  FLUTTER_VERSION = "3.37.0-0.1.pre"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Strict-Transport-Security = "max-age=31536000; includeSubDomains"
```

#### Vercel Deployment
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
flutter build web --release --dart-define=ENVIRONMENT=production
vercel --prod
```

**vercel.json:**
```json
{
  "buildCommand": "flutter build web --release --dart-define=ENVIRONMENT=production",
  "outputDirectory": "build/web",
  "framework": null,
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains"
        }
      ]
    }
  ]
}
```

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init hosting

# Deploy
flutter build web --release --dart-define=ENVIRONMENT=production
firebase deploy --only hosting
```

**firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=3600"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          }
        ]
      }
    ]
  }
}
```

### 2. Server-Side Hosting

#### Nginx Configuration
```nginx
server {
    listen 80;
    server_name carehr.com www.carehr.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name carehr.com www.carehr.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Root directory
    root /var/www/carehr/build/web;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Handle Flutter routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy (if needed)
    location /api/ {
        proxy_pass https://api.carehr.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### Apache Configuration (.htaccess)
```apache
RewriteEngine On

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Security headers
Header always set X-Frame-Options "DENY"
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/json
</IfModule>

# Cache static assets
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
</IfModule>

# Handle Flutter routing
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]
```

## 📱 Mobile App Store Deployment

### Google Play Store (Android)

#### 1. Prepare for Release
```bash
# Generate signed app bundle
flutter build appbundle --release --dart-define=ENVIRONMENT=production

# Validate app bundle
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
```

#### 2. Play Console Setup
1. Create developer account at https://play.google.com/console
2. Create new application
3. Complete store listing (descriptions, screenshots, etc.)
4. Set up content rating
5. Configure pricing & distribution
6. Upload app bundle
7. Complete release review

#### 3. Release Management
- **Internal Testing**: Limited testers, instant updates
- **Closed Testing**: Larger test groups, staged rollout
- **Open Testing**: Public beta, feedback collection
- **Production**: Full release with staged rollout

### Apple App Store (iOS)

#### 1. Prepare for Release
```bash
# Generate iOS archive
flutter build ipa --release --dart-define=ENVIRONMENT=production

# Upload to App Store Connect
xcrun altool --upload-app --type ios --file build/ios/ipa/care_hr_app.ipa --username your-email --password app-specific-password
```

#### 2. App Store Connect Setup
1. Create developer account at https://developer.apple.com
2. Create app record in App Store Connect
3. Complete app information
4. Upload build via Xcode or Application Loader
5. Submit for review

#### 3. Review Guidelines
- Follow Apple Human Interface Guidelines
- Ensure compliance with App Store Review Guidelines
- Test on physical devices
- Prepare for potential rejections and resubmissions

## 🐳 Docker Deployment

### Dockerfile for Web
```dockerfile
# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=ENVIRONMENT=production

# Production stage
FROM nginx:alpine

# Copy built app
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Security and performance headers
COPY nginx-security.conf /etc/nginx/conf.d/security.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
```yaml
version: '3.8'

services:
  care-hr-frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
      - "443:443"
    environment:
      - ENVIRONMENT=production
    volumes:
      - ./ssl:/etc/nginx/ssl:ro
    restart: unless-stopped
    
  care-hr-backend:
    image: care-hr/backend:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    restart: unless-stopped
    
networks:
  default:
    external:
      name: care-hr-network
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: care-hr-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: care-hr-frontend
  template:
    metadata:
      labels:
        app: care-hr-frontend
    spec:
      containers:
      - name: care-hr-frontend
        image: care-hr/frontend:latest
        ports:
        - containerPort: 80
        env:
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: care-hr-frontend-service
spec:
  selector:
    app: care-hr-frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

## 🔒 Security Configuration

### 1. Environment Security
```bash
# Generate secure encryption keys
openssl rand -hex 32 > encryption.key
openssl rand -hex 64 > jwt.secret

# Set restrictive file permissions
chmod 600 encryption.key jwt.secret
```

### 2. Content Security Policy (Web)
```html
<!-- Add to index.html -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' 'unsafe-eval'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data: https:; 
               connect-src 'self' https://api.carehr.com wss://api.carehr.com;">
```

### 3. Security Headers
```bash
# Add to server configuration
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
```

## 📊 Monitoring & Analytics

### 1. Performance Monitoring
```bash
# Enable performance tracking
flutter build web --release --dart-define=PERFORMANCE_MONITORING=true

# Set up monitoring dashboard
export MONITORING_URL=https://monitoring.carehr.com
export ANALYTICS_KEY=your_analytics_key
```

### 2. Error Tracking (Sentry)
```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-sentry-dsn';
      options.environment = 'production';
      options.release = '1.0.0';
    },
    appRunner: () => runApp(CareHRApp()),
  );
}
```

### 3. Analytics Integration
```dart
// Analytics service integration
class AnalyticsService {
  static void trackPageView(String pageName) {
    // Google Analytics
    gtag('config', 'GA_MEASUREMENT_ID', {
      'page_title': pageName,
      'page_location': window.location.href,
    });
    
    // Custom analytics
    MonitoringService.trackEvent('page_view', {
      'page': pageName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: Care HR Frontend CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.37.0-0.1.pre'
        channel: 'beta'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate files
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.37.0-0.1.pre'
        channel: 'beta'
    
    - name: Build for production
      run: |
        flutter pub get
        flutter packages pub run build_runner build --delete-conflicting-outputs
        flutter build web --release --dart-define=ENVIRONMENT=production
    
    - name: Deploy to Netlify
      uses: nwtgck/actions-netlify@v1.2
      with:
        publish-dir: './build/web'
        production-branch: main
        github-token: ${{ secrets.GITHUB_TOKEN }}
        deploy-message: "Deploy from GitHub Actions"
      env:
        NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
        NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### Automated Testing Pipeline
```yaml
name: Automated Testing

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    
    - name: Run integration tests
      run: |
        flutter pub get
        flutter test integration_test/
    
    - name: Performance tests
      run: |
        flutter run --profile --trace-startup --verbose
        flutter build web --analyze-size
    
    - name: Security audit
      run: |
        flutter pub audit
        dart analyze --fatal-infos
```

## 📋 Post-Deployment Checklist

### 1. Functional Testing
- [ ] Authentication flow works correctly
- [ ] All main features are functional
- [ ] File uploads work properly
- [ ] Notifications are delivered
- [ ] Performance meets benchmarks
- [ ] Mobile responsiveness verified

### 2. Security Verification
- [ ] HTTPS is properly configured
- [ ] Security headers are present
- [ ] No sensitive data exposed
- [ ] Rate limiting is working
- [ ] Input validation is effective

### 3. Performance Monitoring
- [ ] Page load times < 2 seconds
- [ ] API response times < 500ms
- [ ] Memory usage is optimal
- [ ] Cache hit rates > 80%
- [ ] No memory leaks detected

### 4. User Experience
- [ ] All pages load correctly
- [ ] Navigation works smoothly
- [ ] Forms submit properly
- [ ] Error messages are helpful
- [ ] Offline functionality works

### 5. Monitoring Setup
- [ ] Error tracking is active
- [ ] Performance monitoring configured
- [ ] Analytics tracking working
- [ ] Alerts are properly set up
- [ ] Health checks are running

## 🛠️ Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean build
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for conflicts
flutter doctor -v
dart analyze
```

#### Performance Issues
```bash
# Analyze bundle size
flutter build web --analyze-size

# Profile performance
flutter run --profile --trace-startup

# Check for memory leaks
flutter run --observatory-port=8080
```

#### Deployment Issues
```bash
# Verify build output
ls -la build/web/

# Test locally
python -m http.server 8000 -d build/web

# Check server logs
nginx -t
systemctl status nginx
```

### Emergency Rollback
```bash
# Quick rollback procedure
git checkout previous-stable-tag
flutter build web --release --dart-define=ENVIRONMENT=production
# Deploy to hosting service
```

## 📞 Support

### Deployment Support
- **Email**: devops@carehr.com
- **Slack**: #deployment-support
- **Documentation**: https://docs.carehr.com/deployment
- **Status Page**: https://status.carehr.com

### Emergency Contact
- **On-call Engineer**: +1-XXX-XXX-XXXX
- **Emergency Email**: emergency@carehr.com
- **Incident Response**: https://incident.carehr.com

---

This deployment guide ensures a secure, performant, and reliable deployment of the Care HR Frontend application. Follow the checklist carefully and maintain proper monitoring to ensure optimal performance in production.