# Care HR System Architecture

## System Overview

The Care HR system is a modern, scalable enterprise HR management solution built with a microservices architecture, featuring a Flutter frontend, Node.js/TypeScript backend, and PostgreSQL database.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Web App<br/>GitHub Pages] 
        B[Flutter Mobile App<br/>iOS/Android]
        C[Admin Dashboard<br/>Web Portal]
    end
    
    subgraph "CDN & Load Balancer"
        D[CloudFlare/GitHub Pages]
        E[Render Load Balancer]
    end
    
    subgraph "Application Layer"
        F[Care HR API Server<br/>Node.js + TypeScript]
        G[GraphQL Endpoint]
        H[WebSocket Server]
        I[File Upload Service]
    end
    
    subgraph "Data Layer"
        J[PostgreSQL Database<br/>Render/Supabase]
        K[Redis Cache<br/>Optional]
        L[File Storage<br/>AWS S3/Local]
    end
    
    subgraph "External Services"
        M[Email Service<br/>SMTP/SendGrid]
        N[Monitoring<br/>Sentry/DataDog]
        O[Authentication<br/>JWT + Refresh Tokens]
    end
    
    A --> D
    B --> E
    C --> E
    D --> F
    E --> F
    F --> G
    F --> H
    F --> I
    F --> J
    F --> K
    F --> L
    F --> M
    F --> N
    F --> O
    
    style A fill:#e1f5fe
    style B fill:#e1f5fe  
    style C fill:#e1f5fe
    style F fill:#f3e5f5
    style J fill:#fff3e0
```

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.24.3+ (Dart)
- **State Management**: Provider pattern with ChangeNotifier
- **Routing**: GoRouter with authentication guards
- **Local Storage**: Hive (NoSQL embedded database)
- **HTTP Client**: Dio with interceptors
- **Real-time**: WebSocket integration
- **UI Components**: Material Design 3

### Backend (Node.js/TypeScript)
- **Runtime**: Node.js 18+ with TypeScript
- **Framework**: Express.js with middleware
- **ORM**: TypeORM with PostgreSQL
- **Authentication**: JWT with refresh tokens
- **API Styles**: RESTful + GraphQL
- **Real-time**: WebSocket (ws library)
- **File Handling**: Multer with AWS S3 integration
- **Validation**: class-validator and joi

### Database & Storage
- **Primary Database**: PostgreSQL 15+
- **Caching**: Redis (optional) + in-memory caching
- **File Storage**: AWS S3 or local filesystem
- **Search**: PostgreSQL full-text search
- **Backups**: Automated daily backups

### Infrastructure & DevOps
- **Backend Hosting**: Render/Railway/Heroku
- **Frontend Hosting**: GitHub Pages/Vercel/Netlify
- **Database Hosting**: Render PostgreSQL/Supabase
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry, Winston logging
- **Security**: Helmet.js, CORS, rate limiting

## Detailed Component Architecture

### Frontend Architecture

```mermaid
graph TB
    subgraph "Flutter App Structure"
        A[main.dart<br/>App Entry Point]
        B[Router<br/>Navigation & Guards]
        C[Providers<br/>State Management]
        
        subgraph "Feature Modules"
            D[Authentication<br/>Login/Register/Profile]
            E[Dashboard<br/>Overview & Analytics] 
            F[Employee Management<br/>CRUD Operations]
            G[Job Applications<br/>Recruitment Flow]
            H[Document Management<br/>File Upload/Download]
            I[Interviews<br/>Scheduling & Tracking]
        end
        
        subgraph "Core Services"
            J[API Service<br/>HTTP Client]
            K[Storage Service<br/>Hive Database]
            L[Auth Service<br/>Token Management]
            M[WebSocket Service<br/>Real-time Updates]
            N[Theme Service<br/>UI Customization]
        end
        
        subgraph "Shared Components"
            O[UI Widgets<br/>Reusable Components]
            P[Models<br/>Data Classes]
            Q[Utils<br/>Helper Functions]
        end
    end
    
    A --> B
    A --> C
    B --> D
    B --> E
    B --> F
    B --> G
    B --> H
    B --> I
    
    D --> J
    E --> J
    F --> J
    G --> J
    H --> J
    I --> J
    
    J --> K
    J --> L
    J --> M
    C --> N
    
    D --> O
    E --> O
    F --> O
    G --> O
    H --> O
    I --> O
    
    style A fill:#4CAF50
    style J fill:#2196F3
    style K fill:#FF9800
```

### Backend Architecture

```mermaid
graph TB
    subgraph "API Layer"
        A[Express Server<br/>HTTP/HTTPS]
        B[GraphQL Schema<br/>Type Definitions]
        C[WebSocket Server<br/>Real-time Events]
        D[Middleware Stack<br/>Auth, CORS, Validation]
    end
    
    subgraph "Business Logic Layer"
        E[User Controller<br/>Authentication & Users]
        F[Employee Controller<br/>HR Operations]
        G[Job Controller<br/>Recruitment]
        H[Document Controller<br/>File Management]
        I[Interview Controller<br/>Scheduling]
    end
    
    subgraph "Service Layer"
        J[Auth Service<br/>JWT & Security]
        K[Email Service<br/>Notifications]
        L[File Service<br/>Upload/Storage]
        M[Cache Service<br/>Performance]
        N[Validation Service<br/>Data Integrity]
    end
    
    subgraph "Data Access Layer"
        O[TypeORM Entities<br/>Database Models]
        P[Repositories<br/>Data Access]
        Q[Migrations<br/>Schema Management]
        R[Seeds<br/>Sample Data]
    end
    
    subgraph "External Integrations"
        S[PostgreSQL<br/>Primary Database]
        T[AWS S3<br/>File Storage]
        U[SMTP Server<br/>Email Delivery]
        V[Redis<br/>Caching]
    end
    
    A --> D
    A --> B
    A --> C
    D --> E
    D --> F
    D --> G
    D --> H
    D --> I
    
    E --> J
    F --> J
    G --> J
    H --> L
    I --> K
    
    E --> P
    F --> P
    G --> P
    H --> P
    I --> P
    
    P --> O
    O --> S
    L --> T
    K --> U
    M --> V
    
    style A fill:#4CAF50
    style J fill:#2196F3
    style S fill:#FF9800
```

## Data Flow Patterns

### Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant A as API Server
    participant D as Database
    
    U->>F: Enter credentials
    F->>A: POST /auth/login
    A->>D: Validate user
    D-->>A: User data
    A->>A: Generate JWT tokens
    A-->>F: Access & refresh tokens
    F->>F: Store tokens securely
    F-->>U: Navigate to dashboard
    
    Note over F,A: Subsequent requests include JWT
    F->>A: GET /api/employees (with JWT)
    A->>A: Validate JWT
    A->>D: Fetch employees
    D-->>A: Employee data
    A-->>F: JSON response
    F-->>U: Display employees
```

### Real-time Updates Flow

```mermaid
sequenceDiagram
    participant A1 as Admin User
    participant F1 as Flutter App 1
    participant W as WebSocket Server
    participant F2 as Flutter App 2
    participant U2 as Regular User
    
    F1->>W: Connect WebSocket
    F2->>W: Connect WebSocket
    
    A1->>F1: Create new employee
    F1->>W: Employee created event
    W->>W: Broadcast to subscribers
    W-->>F2: Employee update notification
    F2->>F2: Update local state
    F2-->>U2: Show new employee in list
```

### File Upload Flow

```mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant A as API Server
    participant S3 as AWS S3
    participant D as Database
    
    U->>F: Select file to upload
    F->>A: POST /documents/upload (multipart)
    A->>A: Validate file type & size
    A->>S3: Upload file to storage
    S3-->>A: File URL
    A->>D: Save document metadata
    D-->>A: Document record
    A-->>F: Document info with URL
    F-->>U: Show upload success
```

## Security Architecture

### Authentication & Authorization

```mermaid
graph LR
    subgraph "Authentication Layer"
        A[JWT Access Token<br/>15 minutes]
        B[Refresh Token<br/>7 days]
        C[Token Blacklist<br/>Redis/Memory]
    end
    
    subgraph "Authorization Layer"
        D[Role-Based Access<br/>Admin, HR, Employee]
        E[Resource Permissions<br/>Read, Write, Delete]
        F[Route Guards<br/>API & Frontend]
    end
    
    subgraph "Security Measures"
        G[Password Hashing<br/>bcrypt]
        H[Rate Limiting<br/>Per IP/User]
        I[Input Validation<br/>Sanitization]
        J[HTTPS Only<br/>SSL/TLS]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    E --> F
    
    G --> A
    H --> F
    I --> F
    J --> F
    
    style A fill:#4CAF50
    style D fill:#2196F3
    style G fill:#FF5722
```

### Data Protection

1. **Encryption at Rest**
   - Database: PostgreSQL with encryption
   - Files: AWS S3 server-side encryption
   - Sensitive data: Application-level encryption

2. **Encryption in Transit**
   - HTTPS/TLS 1.3 for all communications
   - WSS (WebSocket Secure) for real-time data
   - API token encryption

3. **Access Controls**
   - Multi-factor authentication (planned)
   - Role-based permissions
   - IP whitelisting (configurable)
   - Session management

## Performance Architecture

### Caching Strategy

```mermaid
graph TB
    subgraph "Caching Layers"
        A[Browser Cache<br/>Static Assets]
        B[CDN Cache<br/>Global Distribution]
        C[Application Cache<br/>API Responses]
        D[Database Cache<br/>Query Results]
    end
    
    subgraph "Cache Types"
        E[Memory Cache<br/>Fast Access]
        F[Redis Cache<br/>Distributed]
        G[Database Cache<br/>PostgreSQL]
    end
    
    A --> C
    B --> C
    C --> E
    C --> F
    D --> G
    
    style C fill:#4CAF50
    style E fill:#2196F3
```

### Database Optimization

1. **Indexing Strategy**
   ```sql
   -- Primary indexes for fast lookups
   CREATE INDEX idx_employees_email ON employees(email);
   CREATE INDEX idx_users_role ON users(role);
   CREATE INDEX idx_jobs_status ON jobs(status, created_at);
   CREATE INDEX idx_applications_status ON job_applications(status);
   ```

2. **Query Optimization**
   - Prepared statements
   - Connection pooling
   - Lazy loading with TypeORM
   - Database query monitoring

3. **Scaling Strategy**
   - Vertical scaling (CPU/Memory)
   - Read replicas (future)
   - Connection pooling
   - Database sharding (if needed)

## Monitoring & Observability

### Application Monitoring

```mermaid
graph TB
    subgraph "Metrics Collection"
        A[Application Metrics<br/>Performance, Errors]
        B[Infrastructure Metrics<br/>CPU, Memory, Disk]
        C[Business Metrics<br/>User Activity, Features]
    end
    
    subgraph "Monitoring Tools"
        D[Sentry<br/>Error Tracking]
        E[Winston<br/>Application Logs]
        F[Render Metrics<br/>Infrastructure]
    end
    
    subgraph "Alerting"
        G[Email Alerts<br/>Critical Issues]
        H[Slack Integration<br/>Team Notifications]
        I[PagerDuty<br/>On-call Alerts]
    end
    
    A --> D
    A --> E
    B --> F
    C --> E
    
    D --> G
    E --> H
    F --> I
    
    style D fill:#FF5722
    style E fill:#4CAF50
    style F fill:#2196F3
```

### Health Monitoring

1. **Health Checks**
   - `/health` endpoint with database connectivity
   - Service health indicators
   - Dependency status checking

2. **Logging Strategy**
   - Structured logging with Winston
   - Different log levels (error, warn, info, debug)
   - Centralized log aggregation
   - Log rotation and archival

3. **Performance Monitoring**
   - Response time tracking
   - Database query performance
   - Memory and CPU usage
   - User experience metrics

## Deployment Architecture

### Multi-Environment Setup

```mermaid
graph TB
    subgraph "Development"
        A[Local Development<br/>Docker Compose]
        B[Feature Branches<br/>GitHub]
        C[Development Database<br/>Local PostgreSQL]
    end
    
    subgraph "Staging"
        D[Staging Environment<br/>Render/Railway]
        E[Staging Database<br/>Render PostgreSQL]
        F[Integration Testing<br/>Automated Tests]
    end
    
    subgraph "Production"
        G[Production Environment<br/>Render/Railway]
        H[Production Database<br/>Render/Supabase]
        I[CDN Distribution<br/>Global Edge Locations]
    end
    
    A --> B
    B --> D
    D --> E
    D --> F
    F --> G
    G --> H
    G --> I
    
    style G fill:#4CAF50
    style H fill:#FF9800
```

### CI/CD Pipeline

1. **Continuous Integration**
   - Automated testing on pull requests
   - Code quality checks
   - Security vulnerability scanning
   - Build verification

2. **Continuous Deployment**
   - Automatic deployment to staging
   - Manual promotion to production
   - Blue-green deployment strategy
   - Rollback capabilities

## Scalability Considerations

### Horizontal Scaling

1. **Application Layer**
   - Stateless server design
   - Load balancer distribution
   - Container orchestration (future)
   - Microservices architecture (future)

2. **Database Layer**
   - Connection pooling
   - Read replicas
   - Database partitioning
   - Caching strategies

### Performance Optimization

1. **Frontend Optimization**
   - Code splitting and lazy loading
   - Image optimization
   - Caching strategies
   - Progressive Web App features

2. **Backend Optimization**
   - Database query optimization
   - API response caching
   - Compression middleware
   - Connection pooling

## Future Architecture Enhancements

1. **Microservices Migration**
   - Service decomposition
   - API gateway implementation
   - Service mesh architecture
   - Event-driven communication

2. **Advanced Features**
   - Machine learning integration
   - Advanced analytics
   - Mobile offline capabilities
   - Real-time collaboration features

3. **Infrastructure Improvements**
   - Container orchestration (Kubernetes)
   - Service discovery
   - Distributed tracing
   - Advanced monitoring and alerting

This architecture provides a solid foundation for the Care HR system while allowing for future growth and enhancement.