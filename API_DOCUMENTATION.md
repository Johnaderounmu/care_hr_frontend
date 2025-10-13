# Care HR API Documentation

## API Overview

The Care HR backend provides a comprehensive REST API for managing HR operations. The API is built with Node.js, TypeScript, and PostgreSQL, offering robust endpoints for authentication, job management, application processing, and document handling.

### Base URL
- **Development**: `http://localhost:3000/api`
- **Staging**: `https://staging-api.carehr.com/api`
- **Production**: `https://api.carehr.com/api`

### Authentication
All API endpoints (except public ones) require JWT authentication via the `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

### Response Format
All responses follow a consistent JSON structure:
```json
{
  "success": boolean,
  "data": object | array | null,
  "message": string,
  "error": object | null,
  "timestamp": string,
  "requestId": string
}
```

## Authentication Endpoints

### POST /auth/login
Authenticate user and receive JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "role": "hr_admin",
      "profileImage": "https://...",
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "lastLogin": "2024-01-01T10:30:00Z"
    },
    "expiresIn": "24h"
  },
  "message": "Login successful"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "data": null,
  "message": "Invalid credentials",
  "error": {
    "code": "INVALID_CREDENTIALS",
    "details": "Email or password is incorrect"
  }
}
```

### POST /auth/register
Create a new user account.

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "password": "securePassword123",
  "fullName": "Jane Smith",
  "role": "applicant"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "email": "newuser@example.com",
      "fullName": "Jane Smith",
      "role": "applicant",
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  },
  "message": "Registration successful"
}
```

### POST /auth/refresh
Refresh JWT token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

### POST /auth/logout
Logout user and invalidate token.

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "success": true,
  "data": null,
  "message": "Logout successful"
}
```

### POST /auth/forgot-password
Request password reset.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

### POST /auth/reset-password
Reset password with token.

**Request Body:**
```json
{
  "token": "reset_token",
  "newPassword": "newSecurePassword123"
}
```

## User Management Endpoints

### GET /users/profile
Get current user profile.

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Doe",
    "role": "hr_admin",
    "profileImage": "https://...",
    "phone": "+1234567890",
    "department": "Human Resources",
    "position": "HR Manager",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "lastLogin": "2024-01-01T10:30:00Z",
    "preferences": {
      "theme": "light",
      "notifications": true,
      "language": "en"
    }
  }
}
```

### PUT /users/profile
Update user profile.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "fullName": "John Smith",
  "phone": "+1234567890",
  "department": "Human Resources",
  "preferences": {
    "theme": "dark",
    "notifications": false
  }
}
```

### GET /users
Get all users (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 100)
- `role`: Filter by role (`hr_admin`, `applicant`)
- `search`: Search by name or email
- `active`: Filter by active status

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "email": "user@example.com",
        "fullName": "John Doe",
        "role": "hr_admin",
        "isActive": true,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### PUT /users/:id/role
Update user role (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "role": "hr_admin"
}
```

### DELETE /users/:id
Deactivate user account (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

## Job Management Endpoints

### GET /jobs
Get all job postings.

**Query Parameters:**
- `page`: Page number
- `limit`: Items per page
- `status`: Filter by status (`draft`, `published`, `closed`)
- `department`: Filter by department
- `search`: Search in title and description

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "jobs": [
      {
        "id": "uuid",
        "title": "Senior Flutter Developer",
        "description": "We are looking for...",
        "department": "Engineering",
        "location": "San Francisco, CA",
        "type": "full-time",
        "salary": {
          "min": 120000,
          "max": 180000,
          "currency": "USD"
        },
        "requirements": [
          "5+ years Flutter experience",
          "Strong Dart knowledge"
        ],
        "status": "published",
        "postedBy": {
          "id": "uuid",
          "fullName": "HR Manager"
        },
        "applicationsCount": 15,
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z",
        "expiresAt": "2024-02-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### POST /jobs
Create new job posting (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Senior Flutter Developer",
  "description": "We are looking for a talented Flutter developer...",
  "department": "Engineering",
  "location": "San Francisco, CA",
  "type": "full-time",
  "salary": {
    "min": 120000,
    "max": 180000,
    "currency": "USD"
  },
  "requirements": [
    "5+ years Flutter experience",
    "Strong Dart knowledge",
    "Experience with state management"
  ],
  "benefits": [
    "Health insurance",
    "401k matching",
    "Flexible PTO"
  ],
  "expiresAt": "2024-02-01T00:00:00Z"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Senior Flutter Developer",
    "status": "draft",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  "message": "Job created successfully"
}
```

### GET /jobs/:id
Get specific job details.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Senior Flutter Developer",
    "description": "Detailed job description...",
    "department": "Engineering",
    "location": "San Francisco, CA",
    "type": "full-time",
    "salary": {
      "min": 120000,
      "max": 180000,
      "currency": "USD"
    },
    "requirements": ["..."],
    "benefits": ["..."],
    "status": "published",
    "postedBy": {
      "id": "uuid",
      "fullName": "HR Manager",
      "email": "hr@company.com"
    },
    "applicationsCount": 15,
    "viewCount": 234,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "expiresAt": "2024-02-01T00:00:00Z"
  }
}
```

### PUT /jobs/:id
Update job posting (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same as POST /jobs

### DELETE /jobs/:id
Delete job posting (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

### PUT /jobs/:id/status
Update job status (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "published"
}
```

## Job Applications Endpoints

### GET /applications
Get job applications.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`: Page number
- `limit`: Items per page
- `status`: Filter by status (`pending`, `reviewed`, `interviewed`, `offered`, `rejected`)
- `jobId`: Filter by specific job
- `applicantId`: Filter by applicant (HR Admin only)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "applications": [
      {
        "id": "uuid",
        "job": {
          "id": "uuid",
          "title": "Senior Flutter Developer",
          "department": "Engineering"
        },
        "applicant": {
          "id": "uuid",
          "fullName": "John Smith",
          "email": "john@example.com"
        },
        "status": "pending",
        "coverLetter": "Dear Hiring Manager...",
        "resumeUrl": "https://...",
        "submittedAt": "2024-01-01T00:00:00Z",
        "reviewedAt": null,
        "reviewedBy": null,
        "score": null,
        "notes": []
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### POST /applications
Submit job application.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "jobId": "uuid",
  "coverLetter": "Dear Hiring Manager, I am writing to express...",
  "resumeUrl": "https://storage.com/resumes/resume.pdf",
  "additionalDocuments": [
    {
      "type": "portfolio",
      "url": "https://portfolio.com",
      "name": "My Portfolio"
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "pending",
    "submittedAt": "2024-01-01T00:00:00Z"
  },
  "message": "Application submitted successfully"
}
```

### GET /applications/:id
Get specific application details.

**Headers:** `Authorization: Bearer <token>`

### PUT /applications/:id/status
Update application status (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "reviewed",
  "score": 85,
  "notes": "Strong technical background, good communication skills"
}
```

### POST /applications/:id/interview
Schedule interview (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "type": "technical",
  "scheduledAt": "2024-01-15T14:00:00Z",
  "duration": 60,
  "interviewers": ["uuid1", "uuid2"],
  "location": "Conference Room A",
  "notes": "Technical interview focusing on Flutter and Dart"
}
```

## Document Management Endpoints

### GET /documents
Get documents.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`: Page number
- `limit`: Items per page
- `type`: Filter by type (`resume`, `cover_letter`, `portfolio`, `certificate`)
- `status`: Filter by status (`pending`, `approved`, `rejected`)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "documents": [
      {
        "id": "uuid",
        "name": "John_Smith_Resume.pdf",
        "type": "resume",
        "url": "https://storage.com/documents/...",
        "size": 1024000,
        "mimeType": "application/pdf",
        "status": "approved",
        "uploadedBy": {
          "id": "uuid",
          "fullName": "John Smith"
        },
        "reviewedBy": {
          "id": "uuid",
          "fullName": "HR Manager"
        },
        "uploadedAt": "2024-01-01T00:00:00Z",
        "reviewedAt": "2024-01-02T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### POST /documents/upload
Upload document.

**Headers:** 
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data`

**Form Data:**
- `file`: Document file
- `type`: Document type (`resume`, `cover_letter`, `portfolio`, `certificate`)
- `description`: Optional description

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "document.pdf",
    "url": "https://storage.com/documents/...",
    "type": "resume",
    "size": 1024000,
    "uploadedAt": "2024-01-01T00:00:00Z"
  },
  "message": "Document uploaded successfully"
}
```

### GET /documents/:id
Get specific document details.

**Headers:** `Authorization: Bearer <token>`

### DELETE /documents/:id
Delete document.

**Headers:** `Authorization: Bearer <token>`

### PUT /documents/:id/status
Update document status (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "approved",
  "comments": "Document meets all requirements"
}
```

## Analytics & Reports Endpoints

### GET /analytics/dashboard
Get dashboard analytics (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "overview": {
      "totalJobs": 25,
      "activeJobs": 15,
      "totalApplications": 234,
      "pendingApplications": 45,
      "totalUsers": 150,
      "activeUsers": 120
    },
    "applicationsByStatus": {
      "pending": 45,
      "reviewed": 89,
      "interviewed": 67,
      "offered": 23,
      "rejected": 10
    },
    "jobsByDepartment": {
      "Engineering": 8,
      "Marketing": 4,
      "Sales": 3,
      "HR": 2
    },
    "applicationTrends": [
      {
        "date": "2024-01-01",
        "applications": 12,
        "hires": 2
      }
    ],
    "performanceMetrics": {
      "timeToHire": 18.5,
      "applicationToInterviewRate": 0.35,
      "interviewToOfferRate": 0.68,
      "offerAcceptanceRate": 0.89
    }
  }
}
```

### GET /analytics/reports/hiring
Get hiring report (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `startDate`: Start date (ISO format)
- `endDate`: End date (ISO format)
- `department`: Filter by department
- `format`: Response format (`json`, `csv`, `pdf`)

### GET /analytics/reports/performance
Get performance report (HR Admin only).

**Headers:** `Authorization: Bearer <token>`

## Notification Endpoints

### GET /notifications
Get user notifications.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`: Page number
- `limit`: Items per page
- `read`: Filter by read status (`true`, `false`)
- `type`: Filter by type

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "application_received",
        "title": "New Application Received",
        "message": "John Smith applied for Senior Flutter Developer",
        "data": {
          "applicationId": "uuid",
          "jobId": "uuid"
        },
        "isRead": false,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "unreadCount": 5,
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### PUT /notifications/:id/read
Mark notification as read.

**Headers:** `Authorization: Bearer <token>`

### PUT /notifications/read-all
Mark all notifications as read.

**Headers:** `Authorization: Bearer <token>`

## WebSocket Events

### Connection
Connect to WebSocket for real-time updates:
```
ws://localhost:3000/ws?token=<jwt_token>
```

### Events

#### application_status_updated
```json
{
  "event": "application_status_updated",
  "data": {
    "applicationId": "uuid",
    "status": "reviewed",
    "message": "Your application has been reviewed"
  }
}
```

#### new_notification
```json
{
  "event": "new_notification",
  "data": {
    "id": "uuid",
    "type": "interview_scheduled",
    "title": "Interview Scheduled",
    "message": "Your interview has been scheduled for tomorrow"
  }
}
```

## Error Codes

### HTTP Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error

### Custom Error Codes
- `INVALID_CREDENTIALS` - Invalid login credentials
- `TOKEN_EXPIRED` - JWT token has expired
- `INSUFFICIENT_PERMISSIONS` - User lacks required permissions
- `VALIDATION_ERROR` - Request data validation failed
- `DUPLICATE_EMAIL` - Email already exists
- `RESOURCE_NOT_FOUND` - Requested resource not found
- `FILE_TOO_LARGE` - Uploaded file exceeds size limit
- `INVALID_FILE_TYPE` - File type not supported
- `RATE_LIMIT_EXCEEDED` - Too many requests from client

## Rate Limiting

### Limits
- **Authentication endpoints**: 5 requests per minute per IP
- **File upload endpoints**: 10 requests per hour per user
- **General API endpoints**: 100 requests per hour per user
- **WebSocket connections**: 3 concurrent connections per user

### Headers
Rate limit information is included in response headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Pagination

All list endpoints support pagination with consistent parameters:
- `page`: Page number (1-based, default: 1)
- `limit`: Items per page (default: 10, max: 100)

Response includes pagination metadata:
```json
{
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 250,
    "totalPages": 25,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## Development & Testing

### API Testing
Use the provided Postman collection for testing:
```bash
# Import collection
curl -o CareHR-API.postman_collection.json https://api.carehr.com/docs/postman

# Set environment variables
CARE_HR_BASE_URL=http://localhost:3000/api
CARE_HR_JWT_TOKEN=your_jwt_token_here
```

### Mock Data
Development endpoints provide mock data:
- `/mock/users` - Generate sample users
- `/mock/jobs` - Generate sample jobs
- `/mock/applications` - Generate sample applications

### Health Check
Monitor API health:
```
GET /health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "version": "1.0.0",
  "database": "connected",
  "uptime": 86400
}
```

---

For additional support or questions about the API, contact the development team or refer to the interactive API documentation at `https://api.carehr.com/docs`.