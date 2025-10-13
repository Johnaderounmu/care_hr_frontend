# Care HR Deployment Guide

## Overview

This guide covers the complete deployment process for the Care HR system, including both frontend (Flutter) and backend (Node.js/TypeScript) components.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter Web   │    │   Flutter Mobile │    │  Admin Portal   │
│  (GitHub Pages) │    │   (App Stores)   │    │   (Web/Mobile)  │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │      Load Balancer       │
                    │    (Render/Railway)      │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │   Care HR Backend API    │
                    │  (Node.js + TypeScript)  │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │    PostgreSQL Database   │
                    │      (Render/Supabase)   │
                    └──────────────────────────┘
```

## Prerequisites

### Development Environment
- Node.js 18+ and npm
- Flutter SDK 3.24.3+
- Docker (optional)
- Git
- PostgreSQL (for local development)

### Production Services
- **Backend Hosting**: Render, Railway, or Heroku
- **Database**: Render PostgreSQL, Supabase, or AWS RDS
- **Frontend**: GitHub Pages, Vercel, or Netlify
- **File Storage**: AWS S3, Cloudinary, or similar
- **Monitoring**: Sentry, LogRocket, or DataDog

## Backend Deployment

### Environment Variables

Create a `.env` file with the following variables:

```bash
# Database
DATABASE_URL=postgresql://username:password@host:5432/database_name
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DATABASE=care_hr_db

# Authentication
JWT_SECRET=your-super-secret-jwt-key-256-bits-minimum
JWT_EXPIRES_IN=7d
REFRESH_TOKEN_SECRET=your-refresh-token-secret
ENCRYPTION_KEY=32-character-encryption-key-here

# Server
PORT=4000
NODE_ENV=production
API_VERSION=v1

# CORS
ALLOWED_ORIGINS=https://johnaderounmu.github.io,https://care-hr.com

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./uploads
AWS_S3_BUCKET=care-hr-documents
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret

# Email Service
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Monitoring
SENTRY_DSN=your-sentry-dsn
LOG_LEVEL=info

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX=100
```

### Render Deployment

1. **Connect Repository**
   ```bash
   # Connect your GitHub repository to Render
   # Create new Web Service on Render dashboard
   ```

2. **Configure Build Settings**
   ```yaml
   # Build Command
   npm install && npm run build
   
   # Start Command  
   npm start
   
   # Environment
   Node.js 18
   ```

3. **Database Setup**
   ```bash
   # Create PostgreSQL database on Render
   # Copy DATABASE_URL from Render dashboard
   # Add to environment variables
   ```

4. **Deploy Script**
   ```bash
   #!/bin/bash
   cd care_hr_backend
   
   # Install dependencies
   npm ci --production
   
   # Build application
   npm run build
   
   # Run database migrations
   npm run migration:run
   
   # Start production server
   npm start
   ```

### Railway Deployment

1. **Railway CLI Setup**
   ```bash
   # Install Railway CLI
   npm install -g @railway/cli
   
   # Login to Railway
   railway login
   
   # Initialize project
   railway init care-hr-backend
   ```

2. **Deploy Command**
   ```bash
   # Deploy to Railway
   railway up
   
   # Add environment variables
   railway variables set NODE_ENV=production
   railway variables set PORT=4000
   # Add other environment variables...
   ```

3. **Railway Configuration** (`railway.json`)
   ```json
   {
     "build": {
       "builder": "NIXPACKS"
     },
     "deploy": {
       "startCommand": "npm start",
       "healthcheckPath": "/health"
     }
   }
   ```

### Docker Deployment

1. **Dockerfile**
   ```dockerfile
   FROM node:18-alpine

   WORKDIR /app

   # Copy package files
   COPY package*.json ./
   RUN npm ci --only=production

   # Copy source code
   COPY . .

   # Build application
   RUN npm run build

   # Expose port
   EXPOSE 4000

   # Health check
   HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
     CMD curl -f http://localhost:4000/health || exit 1

   # Start application
   CMD ["npm", "start"]
   ```

2. **Docker Compose** (`docker-compose.prod.yml`)
   ```yaml
   version: '3.8'
   
   services:
     backend:
       build: .
       ports:
         - "4000:4000"
       environment:
         - NODE_ENV=production
         - DATABASE_URL=${DATABASE_URL}
         - JWT_SECRET=${JWT_SECRET}
       depends_on:
         - database
       restart: unless-stopped
   
     database:
       image: postgres:15-alpine
       environment:
         - POSTGRES_DB=care_hr_db
         - POSTGRES_USER=${DB_USERNAME}
         - POSTGRES_PASSWORD=${DB_PASSWORD}
       volumes:
         - postgres_data:/var/lib/postgresql/data
       restart: unless-stopped
   
     nginx:
       image: nginx:alpine
       ports:
         - "80:80"
         - "443:443"
       volumes:
         - ./nginx.conf:/etc/nginx/nginx.conf
         - ./ssl:/etc/ssl
       depends_on:
         - backend
       restart: unless-stopped
   
   volumes:
     postgres_data:
   ```

## Frontend Deployment

### GitHub Pages (Automated)

The project includes automated GitHub Actions workflows for deployment.

1. **Enable GitHub Pages**
   - Go to repository Settings → Pages
   - Source: GitHub Actions
   - Custom domain (optional): `care-hr.com`

2. **Workflow Configuration** (`.github/workflows/web-deploy.yml`)
   ```yaml
   # Already configured in your repository
   # Deploys automatically on push to master branch
   ```

3. **Custom Domain Setup**
   ```bash
   # Add CNAME file to repository root
   echo "care-hr.com" > CNAME
   
   # Configure DNS records
   # A Record: @ → 185.199.108.153
   # CNAME: www → username.github.io
   ```

### Vercel Deployment

1. **Vercel CLI**
   ```bash
   # Install Vercel CLI
   npm i -g vercel
   
   # Deploy
   cd care_hr_frontend
   flutter build web --release
   vercel --prod ./build/web
   ```

2. **Vercel Configuration** (`vercel.json`)
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "build/web/**",
         "use": "@vercel/static"
       }
     ],
     "routes": [
       {
         "src": "/(.*)",
         "dest": "/index.html"
       }
     ]
   }
   ```

### Netlify Deployment

1. **Build Settings**
   ```bash
   # Build command
   flutter build web --release
   
   # Publish directory
   build/web
   ```

2. **Netlify Configuration** (`netlify.toml`)
   ```toml
   [build]
     command = "flutter build web --release"
     publish = "build/web"
   
   [[redirects]]
     from = "/*"
     to = "/index.html"
     status = 200
   ```

## Mobile App Deployment

### Android (Google Play Store)

1. **Build Release APK**
   ```bash
   # Generate keystore
   keytool -genkey -v -keystore care-hr-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias care-hr

   # Configure signing (android/key.properties)
   storePassword=your_store_password
   keyPassword=your_key_password  
   keyAlias=care-hr
   storeFile=../care-hr-release.jks

   # Build release
   flutter build appbundle --release
   ```

2. **Play Store Console**
   - Create new app in Google Play Console
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Complete store listing and content rating
   - Submit for review

### iOS (App Store)

1. **Build iOS App**
   ```bash
   # Build iOS app
   flutter build ios --release
   
   # Open in Xcode
   open ios/Runner.xcworkspace
   ```

2. **Xcode Configuration**
   - Set development team and provisioning profile
   - Configure app signing
   - Archive and upload to App Store Connect

3. **App Store Connect**
   - Complete app information
   - Add screenshots and metadata  
   - Submit for App Store review

## Database Setup

### Production Database Migration

1. **Run Migrations**
   ```bash
   # Backend directory
   npm run migration:run
   
   # Or with TypeORM CLI
   npx typeorm migration:run -d src/data-source.ts
   ```

2. **Seed Production Data**
   ```bash
   # Run seeders
   npm run seed:run
   
   # Or custom seed script
   node dist/scripts/seed-production.js
   ```

### Backup Strategy

1. **Automated Backups**
   ```bash
   #!/bin/bash
   # backup-db.sh
   
   BACKUP_DIR="/backups"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   # Create backup
   pg_dump $DATABASE_URL > "$BACKUP_DIR/care_hr_backup_$DATE.sql"
   
   # Upload to S3
   aws s3 cp "$BACKUP_DIR/care_hr_backup_$DATE.sql" s3://care-hr-backups/
   
   # Cleanup old backups (keep last 30 days)
   find $BACKUP_DIR -name "care_hr_backup_*.sql" -mtime +30 -delete
   ```

2. **Restore Process**
   ```bash
   # Restore from backup
   psql $DATABASE_URL < backup_file.sql
   ```

## Monitoring & Logging

### Application Monitoring

1. **Sentry Integration**
   ```bash
   # Install Sentry
   npm install @sentry/node @sentry/profiling-node
   
   # Configure in app
   # (Already integrated in your backend)
   ```

2. **Health Checks**
   ```bash
   # Monitor endpoint health
   curl -f https://care-hr-backend.onrender.com/health
   
   # Set up monitoring alerts
   # Use Render monitoring or external services like UptimeRobot
   ```

### Log Management

1. **Structured Logging**
   ```typescript
   // Already configured with Winston logger
   // Logs are automatically collected by hosting platforms
   ```

2. **Log Analysis**
   ```bash
   # View logs on Render
   render logs --service care-hr-backend
   
   # Export logs for analysis
   render logs --service care-hr-backend --output logs.txt
   ```

## Security Configuration

### SSL/TLS Setup

1. **Automatic SSL** (Render/Railway)
   - SSL certificates are automatically provisioned
   - Force HTTPS redirects are enabled

2. **Custom Domain SSL**
   ```bash
   # For custom domains, configure DNS
   # Add CNAME record pointing to render service
   # SSL certificate will be auto-generated
   ```

### Security Headers

```typescript
// Already configured in your backend
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  }
}));
```

## CI/CD Pipeline

### GitHub Actions (Already Configured)

Your repository includes automated workflows:

- **Frontend**: Builds and deploys to GitHub Pages
- **Android**: Builds APK artifacts
- **iOS**: Builds iOS app (requires Apple Developer account)
- **Backend**: Can be configured for automatic deployment

### Manual Deployment Commands

```bash
# Deploy backend to Render
git push origin master  # Auto-deploys if connected

# Deploy frontend
npm run deploy:web      # Builds and deploys to GitHub Pages

# Build mobile apps
npm run build:android   # Builds Android APK
npm run build:ios       # Builds iOS app
```

## Performance Optimization

### Backend Optimization

1. **Database Optimization**
   ```sql
   -- Add database indexes (already configured)
   CREATE INDEX idx_employees_email ON employees(email);
   CREATE INDEX idx_jobs_status ON jobs(status);
   ```

2. **Caching Strategy**
   ```typescript
   // Redis caching (configure if needed)
   // Memory caching is already implemented
   ```

### Frontend Optimization

1. **Web Performance**
   ```bash
   # Build with optimizations
   flutter build web --release --web-renderer canvaskit
   ```

2. **Mobile Performance**
   ```bash
   # Build optimized APK
   flutter build apk --release --shrink --obfuscate
   ```

## Troubleshooting

### Common Issues

1. **Database Connection**
   ```bash
   # Test database connection
   psql $DATABASE_URL -c "SELECT 1;"
   ```

2. **CORS Issues**
   ```typescript
   // Update CORS settings in backend
   // Check ALLOWED_ORIGINS environment variable
   ```

3. **Build Failures**
   ```bash
   # Clear Flutter cache
   flutter clean
   flutter pub get
   
   # Clear Node modules
   rm -rf node_modules package-lock.json
   npm install
   ```

### Logs and Debugging

```bash
# View application logs
render logs --service care-hr-backend --tail

# Debug database issues
render shell --service care-hr-backend
psql $DATABASE_URL
```

## Post-Deployment Checklist

- [ ] Backend health check responds correctly
- [ ] Database migrations completed successfully
- [ ] Frontend loads without errors
- [ ] API endpoints return expected data
- [ ] Authentication flow works end-to-end
- [ ] File uploads function properly
- [ ] Email notifications are sent
- [ ] Monitoring alerts are configured
- [ ] SSL certificates are active
- [ ] Performance metrics are within acceptable ranges
- [ ] Backup systems are operational

## Support and Maintenance

### Regular Maintenance Tasks

1. **Weekly**
   - Review application logs
   - Check database performance
   - Monitor error rates

2. **Monthly**
   - Update dependencies
   - Review and rotate secrets
   - Analyze performance metrics
   - Test backup/restore procedures

3. **Quarterly**
   - Security audit
   - Performance optimization
   - Disaster recovery testing
   - Documentation updates

For technical support, contact the development team or refer to the troubleshooting section above.