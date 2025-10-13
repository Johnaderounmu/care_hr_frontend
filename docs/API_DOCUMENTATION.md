# Care HR API Documentation

## Overview

The Care HR API is a comprehensive RESTful service built with TypeORM, Express.js, and GraphQL that provides enterprise-grade HR management capabilities.

**Base URL:** `https://care-hr-backend.onrender.com`  
**GraphQL Endpoint:** `https://care-hr-backend.onrender.com/graphql`  
**WebSocket:** `wss://care-hr-backend.onrender.com/ws`

## Authentication

All API endpoints require authentication using JWT tokens.

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "employee",
      "profile": { ... }
    }
  }
}
```

### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "securepassword",
  "firstName": "John",
  "lastName": "Doe",
  "role": "employee"
}
```

## Core Entities

### Users
Manages user accounts and authentication.

**Endpoints:**
- `GET /api/users` - List all users (Admin only)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user (Admin only)

### Employees
Manages employee profiles and HR data.

**Endpoints:**
- `GET /api/employees` - List employees
- `GET /api/employees/:id` - Get employee details
- `POST /api/employees` - Create employee
- `PUT /api/employees/:id` - Update employee
- `DELETE /api/employees/:id` - Remove employee

**Employee Schema:**
```json
{
  "id": "uuid",
  "employeeId": "EMP001",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@company.com",
  "phone": "+1234567890",
  "department": "Engineering",
  "position": "Senior Developer",
  "salary": 75000,
  "hireDate": "2024-01-15T00:00:00Z",
  "status": "active",
  "manager": { ... },
  "documents": [ ... ]
}
```

### Jobs
Manages job postings and recruitment.

**Endpoints:**
- `GET /api/jobs` - List active jobs
- `GET /api/jobs/:id` - Get job details
- `POST /api/jobs` - Create job posting (HR only)
- `PUT /api/jobs/:id` - Update job posting
- `DELETE /api/jobs/:id` - Remove job posting

### Job Applications
Handles job applications and candidate tracking.

**Endpoints:**
- `GET /api/applications` - List applications
- `GET /api/applications/:id` - Get application details
- `POST /api/applications` - Submit application
- `PUT /api/applications/:id/status` - Update application status

### Documents
Manages employee documents and file uploads.

**Endpoints:**
- `GET /api/documents` - List documents
- `GET /api/documents/:id` - Get document
- `POST /api/documents/upload` - Upload document
- `DELETE /api/documents/:id` - Delete document

### Interviews
Manages interview scheduling and tracking.

**Endpoints:**
- `GET /api/interviews` - List interviews
- `POST /api/interviews` - Schedule interview
- `PUT /api/interviews/:id` - Update interview
- `DELETE /api/interviews/:id` - Cancel interview

## GraphQL API

### Queries

```graphql
# Get all employees
query GetEmployees {
  employees {
    id
    firstName
    lastName
    email
    department
    position
    hireDate
  }
}

# Get employee by ID
query GetEmployee($id: ID!) {
  employee(id: $id) {
    id
    firstName
    lastName
    email
    phone
    department
    position
    salary
    documents {
      id
      name
      type
      uploadDate
    }
  }
}

# Get job applications
query GetJobApplications {
  jobApplications {
    id
    applicantName
    email
    job {
      title
      department
    }
    status
    submissionDate
  }
}
```

### Mutations

```graphql
# Create employee
mutation CreateEmployee($input: EmployeeInput!) {
  createEmployee(input: $input) {
    id
    firstName
    lastName
    email
    department
  }
}

# Update employee
mutation UpdateEmployee($id: ID!, $input: EmployeeUpdateInput!) {
  updateEmployee(id: $id, input: $input) {
    id
    firstName
    lastName
    email
  }
}

# Submit job application
mutation SubmitApplication($input: JobApplicationInput!) {
  submitJobApplication(input: $input) {
    id
    status
    submissionDate
  }
}
```

## WebSocket Events

Real-time notifications for HR activities.

### Connection
```javascript
const socket = new WebSocket('wss://care-hr-backend.onrender.com/ws');
```

### Events

**Employee Updates:**
```json
{
  "type": "EMPLOYEE_CREATED",
  "data": {
    "employee": { ... },
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Job Application Updates:**
```json
{
  "type": "APPLICATION_STATUS_CHANGED",
  "data": {
    "applicationId": "uuid",
    "status": "interview_scheduled",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Error Handling

All API responses follow a consistent error format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Error Codes

- `VALIDATION_ERROR` - Input validation failed
- `AUTHENTICATION_ERROR` - Invalid or missing token
- `AUTHORIZATION_ERROR` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `INTERNAL_ERROR` - Server error

## Rate Limiting

API requests are rate limited:
- **Standard users:** 100 requests/minute
- **Admin users:** 500 requests/minute
- **GraphQL:** 50 requests/minute

## Pagination

List endpoints support pagination:

```http
GET /api/employees?page=1&limit=20&sort=firstName&order=asc
```

**Response:**
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

## Health Check

Monitor API health:

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "uptime": "2h 15m 30s",
  "database": "connected",
  "version": "1.0.0"
}
```

## Examples

### Complete Employee Management Flow

1. **Create Employee:**
```bash
curl -X POST https://care-hr-backend.onrender.com/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Smith",
    "email": "jane.smith@company.com",
    "department": "Marketing",
    "position": "Marketing Manager",
    "salary": 65000,
    "hireDate": "2024-02-01"
  }'
```

2. **Upload Document:**
```bash
curl -X POST https://care-hr-backend.onrender.com/api/documents/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@contract.pdf" \
  -F "employeeId=EMPLOYEE_UUID" \
  -F "type=contract"
```

3. **Schedule Interview:**
```bash
curl -X POST https://care-hr-backend.onrender.com/api/interviews \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "applicationId": "APPLICATION_UUID",
    "interviewerId": "INTERVIEWER_UUID",
    "scheduledAt": "2024-02-15T14:00:00Z",
    "type": "technical",
    "location": "Conference Room A"
  }'
```

## SDK Examples

### JavaScript/TypeScript
```typescript
import { CareHRClient } from '@care-hr/sdk';

const client = new CareHRClient({
  baseUrl: 'https://care-hr-backend.onrender.com',
  apiKey: 'YOUR_API_KEY'
});

// Get employees
const employees = await client.employees.list();

// Create employee
const newEmployee = await client.employees.create({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@company.com',
  department: 'Engineering'
});
```

### Flutter/Dart
```dart
import 'package:care_hr_sdk/care_hr_sdk.dart';

final client = CareHRClient(
  baseUrl: 'https://care-hr-backend.onrender.com',
  apiKey: 'YOUR_API_KEY',
);

// Get employees
final employees = await client.employees.getAll();

// Create employee
final employee = await client.employees.create(
  CreateEmployeeRequest(
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@company.com',
    department: 'Engineering',
  ),
);
```