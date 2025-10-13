# Care HR Developer Documentation

## Quick Start Guide

### Prerequisites
- **Flutter SDK**: 3.24.3 or later
- **Dart SDK**: 3.5.0 or later  
- **Node.js**: 18.0 or later
- **npm/yarn**: Latest version
- **PostgreSQL**: 15 or later (for local development)
- **Git**: Latest version
- **VS Code/Android Studio**: Recommended IDEs

### Repository Setup

```bash
# Clone repositories
git clone https://github.com/Johnaderounmu/care_hr_frontend.git
git clone https://github.com/Johnaderounmu/care_hr_backend.git

# Setup backend
cd care_hr_backend
npm install
cp .env.example .env  # Configure environment variables
npm run migration:run
npm run seed:run
npm run dev

# Setup frontend (new terminal)
cd care_hr_frontend
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Environment Configuration

#### Backend (.env)
```bash
# Database
DATABASE_URL=postgresql://localhost:5432/care_hr_dev
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DATABASE=care_hr_dev

# Authentication
JWT_SECRET=your-development-jwt-secret-key
JWT_EXPIRES_IN=7d
ENCRYPTION_KEY=dev_encryption_key_32_chars_long

# Server
PORT=4000
NODE_ENV=development
```

#### Frontend (.env)
```bash
API_BASE_URL=http://localhost:4000
GRAPHQL_ENDPOINT=http://localhost:4000/graphql
WEBSOCKET_URL=ws://localhost:4000/ws
ENCRYPTION_KEY=dev_encryption_key_32_chars_long
JWT_SECRET_KEY=dev_jwt_secret_key_256_bits
```

## Frontend Development Guide

### Project Structure

```
lib/
├── main.dart                    # Application entry point
├── core/                        # Core functionality
│   ├── constants/              # App constants
│   ├── models/                 # Data models
│   ├── providers/              # State management
│   ├── router/                 # Navigation & routing
│   ├── services/               # API & storage services
│   └── theme/                  # UI themes
├── features/                   # Feature modules
│   ├── auth/                   # Authentication
│   │   ├── data/
│   │   ├── presentation/
│   │   └── domain/
│   ├── dashboard/              # Main dashboard
│   ├── employees/              # Employee management
│   ├── jobs/                   # Job postings
│   ├── applications/           # Job applications
│   └── documents/              # Document management
└── shared/                     # Shared components
    ├── widgets/                # Reusable UI components
    └── utils/                  # Helper functions
```

### Key Components

#### State Management with Provider

```dart
// lib/core/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    try {
      final response = await AuthService.login(email, password);
      
      if (response.success) {
        _currentUser = response.user;
        _token = response.token;
        _isAuthenticated = true;
        
        // Store token securely
        await StorageService.setString('auth_token', _token!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    
    await StorageService.remove('auth_token');
    notifyListeners();
  }
}
```

#### API Service Integration

```dart
// lib/core/services/api_service.dart
class ApiService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:4000/api';

  static void initialize() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
```

#### Model Classes with Hive

```dart
// lib/core/models/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String firstName;

  @HiveField(3)
  String lastName;

  @HiveField(4)
  UserRole role;

  @HiveField(5)
  DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: UserRole.values.firstWhere(
        (r) => r.toString().split('.').last == json['role'],
      ),
      lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == UserRole.admin;
  bool get isHR => role == UserRole.hr;
}

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  admin,
  
  @HiveField(1)
  hr,
  
  @HiveField(2)
  employee,
  
  @HiveField(3)
  applicant,
}
```

### Routing with GoRouter

```dart
// lib/core/router/app_router.dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    redirect: _redirect,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Protected Routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
        routes: [
          GoRoute(
            path: '/employees',
            name: 'employees',
            builder: (context, state) => const EmployeesPage(),
            routes: [
              GoRoute(
                path: '/:id',
                name: 'employee-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EmployeeDetailPage(employeeId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/jobs',
            name: 'jobs',
            builder: (context, state) => const JobsPage(),
          ),
        ],
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    
    // Define auth routes
    final isAuthRoute = _isAuthRoute(state.matchedLocation);
    
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    
    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }
    
    return null; // No redirect needed
  }

  static bool _isAuthRoute(String location) {
    return ['/login', '/register', '/forgot-password'].contains(location);
  }
}
```

### Custom Widgets

```dart
// lib/shared/widgets/custom_card.dart
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

## Backend Development Guide

### Project Structure

```
src/
├── index.ts                    # Application entry point
├── app.ts                      # Express app configuration
├── data-source.ts              # Database configuration
├── entities/                   # TypeORM entities
│   ├── User.ts
│   ├── Employee.ts
│   ├── Job.ts
│   ├── JobApplication.ts
│   ├── Document.ts
│   └── Interview.ts
├── routes/                     # API route handlers
│   ├── auth.ts
│   ├── users.ts
│   ├── employees.ts
│   ├── jobs.ts
│   └── documents.ts
├── services/                   # Business logic services
│   ├── AuthService.ts
│   ├── EmailService.ts
│   ├── FileService.ts
│   └── ValidationService.ts
├── middleware/                 # Express middleware
│   ├── auth.ts
│   ├── validation.ts
│   ├── errorHandler.ts
│   └── rateLimiter.ts
├── graphql/                    # GraphQL schema & resolvers
│   ├── schema.ts
│   ├── resolvers/
│   └── types/
└── utils/                      # Utility functions
    ├── logger.ts
    ├── encryption.ts
    └── helpers.ts
```

### Entity Definitions

```typescript
// src/entities/Employee.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  Index,
} from 'typeorm';
import { User } from './User';
import { Document } from './Document';

@Entity('employees')
@Index(['email'], { unique: true })
@Index(['employeeId'], { unique: true })
export class Employee {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  employeeId: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ unique: true })
  email: string;

  @Column({ nullable: true })
  phone?: string;

  @Column()
  department: string;

  @Column()
  position: string;

  @Column('decimal', { precision: 10, scale: 2 })
  salary: number;

  @Column('date')
  hireDate: Date;

  @Column({
    type: 'enum',
    enum: ['active', 'inactive', 'terminated'],
    default: 'active',
  })
  status: 'active' | 'inactive' | 'terminated';

  @ManyToOne(() => User, { eager: true })
  user: User;

  @ManyToOne(() => Employee, { nullable: true })
  manager?: Employee;

  @OneToMany(() => Document, document => document.employee)
  documents: Document[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Virtual properties
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }

  get isActive(): boolean {
    return this.status === 'active';
  }
}
```

### Service Classes

```typescript
// src/services/EmployeeService.ts
import { AppDataSource } from '../data-source';
import { Employee } from '../entities/Employee';
import { CreateEmployeeDto, UpdateEmployeeDto } from '../types/employee.types';
import { ValidationService } from './ValidationService';
import { logger } from '../utils/logger';

export class EmployeeService {
  private employeeRepository = AppDataSource.getRepository(Employee);

  async getAllEmployees(
    page: number = 1,
    limit: number = 20,
    filters?: any
  ): Promise<{ employees: Employee[]; total: number; totalPages: number }> {
    try {
      const queryBuilder = this.employeeRepository
        .createQueryBuilder('employee')
        .leftJoinAndSelect('employee.user', 'user')
        .leftJoinAndSelect('employee.manager', 'manager');

      // Apply filters
      if (filters?.department) {
        queryBuilder.andWhere('employee.department = :department', {
          department: filters.department,
        });
      }

      if (filters?.status) {
        queryBuilder.andWhere('employee.status = :status', {
          status: filters.status,
        });
      }

      if (filters?.search) {
        queryBuilder.andWhere(
          '(employee.firstName ILIKE :search OR employee.lastName ILIKE :search OR employee.email ILIKE :search)',
          { search: `%${filters.search}%` }
        );
      }

      const total = await queryBuilder.getCount();
      const employees = await queryBuilder
        .skip((page - 1) * limit)
        .take(limit)
        .getMany();

      return {
        employees,
        total,
        totalPages: Math.ceil(total / limit),
      };
    } catch (error) {
      logger.error('Error fetching employees:', error);
      throw new Error('Failed to fetch employees');
    }
  }

  async createEmployee(data: CreateEmployeeDto): Promise<Employee> {
    try {
      // Validate input
      await ValidationService.validateEmployee(data);

      // Generate employee ID
      const employeeId = await this.generateEmployeeId();

      const employee = this.employeeRepository.create({
        ...data,
        employeeId,
      });

      await this.employeeRepository.save(employee);

      logger.info(`Employee created: ${employee.id}`);
      return employee;
    } catch (error) {
      logger.error('Error creating employee:', error);
      throw error;
    }
  }

  async updateEmployee(
    id: string,
    data: UpdateEmployeeDto
  ): Promise<Employee> {
    try {
      const employee = await this.employeeRepository.findOneBy({ id });
      
      if (!employee) {
        throw new Error('Employee not found');
      }

      // Validate updates
      await ValidationService.validateEmployeeUpdate(data);

      Object.assign(employee, data);
      await this.employeeRepository.save(employee);

      logger.info(`Employee updated: ${id}`);
      return employee;
    } catch (error) {
      logger.error('Error updating employee:', error);
      throw error;
    }
  }

  private async generateEmployeeId(): Promise<string> {
    const lastEmployee = await this.employeeRepository.findOne({
      order: { employeeId: 'DESC' },
    });

    let nextId = 1;
    if (lastEmployee) {
      const lastIdNumber = parseInt(lastEmployee.employeeId.slice(3));
      nextId = lastIdNumber + 1;
    }

    return `EMP${nextId.toString().padStart(4, '0')}`;
  }
}
```

### API Controllers

```typescript
// src/routes/employees.ts
import { Router } from 'express';
import { EmployeeService } from '../services/EmployeeService';
import { authMiddleware } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';
import { createEmployeeSchema, updateEmployeeSchema } from '../schemas/employee.schemas';
import { logger } from '../utils/logger';

const router = Router();
const employeeService = new EmployeeService();

// GET /api/employees
router.get('/', authMiddleware, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      department,
      status,
      search,
    } = req.query;

    const result = await employeeService.getAllEmployees(
      parseInt(page as string),
      parseInt(limit as string),
      { department, status, search }
    );

    res.json({
      success: true,
      data: result.employees,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total: result.total,
        totalPages: result.totalPages,
      },
    });
  } catch (error) {
    logger.error('Error in GET /employees:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to fetch employees',
      },
    });
  }
});

// POST /api/employees
router.post(
  '/',
  authMiddleware,
  validateRequest(createEmployeeSchema),
  async (req, res) => {
    try {
      const employee = await employeeService.createEmployee(req.body);

      res.status(201).json({
        success: true,
        data: employee,
      });
    } catch (error) {
      logger.error('Error in POST /employees:', error);
      
      if (error.message.includes('validation')) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: error.message,
          },
        });
      }

      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create employee',
        },
      });
    }
  }
);

export default router;
```

### GraphQL Integration

```typescript
// src/graphql/resolvers/employee.resolvers.ts
import { EmployeeService } from '../../services/EmployeeService';
import { AuthenticationError, ForbiddenError } from 'apollo-server-express';

const employeeService = new EmployeeService();

export const employeeResolvers = {
  Query: {
    employees: async (_, { page, limit, filters }, { user }) => {
      if (!user) {
        throw new AuthenticationError('Authentication required');
      }

      return await employeeService.getAllEmployees(page, limit, filters);
    },

    employee: async (_, { id }, { user }) => {
      if (!user) {
        throw new AuthenticationError('Authentication required');
      }

      return await employeeService.getEmployeeById(id);
    },
  },

  Mutation: {
    createEmployee: async (_, { input }, { user }) => {
      if (!user || !['admin', 'hr'].includes(user.role)) {
        throw new ForbiddenError('Insufficient permissions');
      }

      return await employeeService.createEmployee(input);
    },

    updateEmployee: async (_, { id, input }, { user }) => {
      if (!user) {
        throw new AuthenticationError('Authentication required');
      }

      // Check if user can update this employee
      const canUpdate = user.role === 'admin' || 
                       user.role === 'hr' || 
                       user.employeeId === id;

      if (!canUpdate) {
        throw new ForbiddenError('Cannot update this employee');
      }

      return await employeeService.updateEmployee(id, input);
    },
  },

  Employee: {
    documents: async (employee) => {
      return await employeeService.getEmployeeDocuments(employee.id);
    },
  },
};
```

## Testing Guide

### Frontend Testing

#### Unit Tests

```dart
// test/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:care_hr_app/core/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('should create user from JSON correctly', () {
      // Arrange
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'employee',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'John Doe');
      expect(user.role, UserRole.employee);
      expect(user.isAdmin, false);
    });

    test('should convert user to JSON correctly', () {
      // Arrange
      final user = User(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.employee,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['role'], 'employee');
    });
  });
}
```

#### Widget Tests

```dart
// test/widgets/custom_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_hr_app/shared/widgets/custom_card.dart';

void main() {
  group('CustomCard Widget Tests', () {
    testWidgets('should render child widget correctly', (tester) async {
      // Arrange
      const testChild = Text('Test Content');

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomCard(child: testChild),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      // Arrange
      bool wasTapped = false;
      void onTap() => wasTapped = true;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              onTap: onTap,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomCard));

      // Assert
      expect(wasTapped, true);
    });
  });
}
```

### Backend Testing

#### Unit Tests

```typescript
// src/tests/services/EmployeeService.test.ts
import { EmployeeService } from '../../services/EmployeeService';
import { AppDataSource } from '../../data-source';
import { Employee } from '../../entities/Employee';

describe('EmployeeService', () => {
  let employeeService: EmployeeService;
  let mockRepository: any;

  beforeEach(() => {
    mockRepository = {
      find: jest.fn(),
      findOneBy: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
      createQueryBuilder: jest.fn(() => ({
        leftJoinAndSelect: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getCount: jest.fn(),
        getMany: jest.fn(),
      })),
    };

    jest.spyOn(AppDataSource, 'getRepository').mockReturnValue(mockRepository);
    employeeService = new EmployeeService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllEmployees', () => {
    it('should return paginated employees', async () => {
      // Arrange
      const mockEmployees = [
        { id: '1', firstName: 'John', lastName: 'Doe' },
        { id: '2', firstName: 'Jane', lastName: 'Smith' },
      ];

      mockRepository.createQueryBuilder().getCount.mockResolvedValue(2);
      mockRepository.createQueryBuilder().getMany.mockResolvedValue(mockEmployees);

      // Act
      const result = await employeeService.getAllEmployees(1, 10);

      // Assert
      expect(result.employees).toEqual(mockEmployees);
      expect(result.total).toBe(2);
      expect(result.totalPages).toBe(1);
    });
  });

  describe('createEmployee', () => {
    it('should create and return new employee', async () => {
      // Arrange
      const employeeData = {
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        department: 'Engineering',
        position: 'Developer',
        salary: 75000,
        hireDate: new Date('2024-01-01'),
      };

      const mockEmployee = { ...employeeData, id: '123', employeeId: 'EMP0001' };
      
      mockRepository.create.mockReturnValue(mockEmployee);
      mockRepository.save.mockResolvedValue(mockEmployee);

      // Act
      const result = await employeeService.createEmployee(employeeData);

      // Assert
      expect(mockRepository.create).toHaveBeenCalledWith({
        ...employeeData,
        employeeId: expect.any(String),
      });
      expect(mockRepository.save).toHaveBeenCalledWith(mockEmployee);
      expect(result).toEqual(mockEmployee);
    });
  });
});
```

#### Integration Tests

```typescript
// src/tests/routes/employees.integration.test.ts
import request from 'supertest';
import { app } from '../../app';
import { AppDataSource } from '../../data-source';
import { Employee } from '../../entities/Employee';
import { User } from '../../entities/User';
import jwt from 'jsonwebtoken';

describe('Employee Routes Integration', () => {
  let authToken: string;
  let testUser: User;

  beforeAll(async () => {
    await AppDataSource.initialize();
    
    // Create test user
    testUser = await AppDataSource.getRepository(User).save({
      email: 'test@example.com',
      password: 'hashedpassword',
      role: 'admin',
    });

    // Generate auth token
    authToken = jwt.sign(
      { userId: testUser.id, role: testUser.role },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
  });

  afterAll(async () => {
    await AppDataSource.destroy();
  });

  afterEach(async () => {
    await AppDataSource.getRepository(Employee).clear();
  });

  describe('GET /api/employees', () => {
    it('should return empty list when no employees exist', async () => {
      const response = await request(app)
        .get('/api/employees')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([]);
      expect(response.body.pagination.total).toBe(0);
    });

    it('should return list of employees', async () => {
      // Create test employee
      await AppDataSource.getRepository(Employee).save({
        employeeId: 'EMP0001',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        department: 'Engineering',
        position: 'Developer',
        salary: 75000,
        hireDate: new Date('2024-01-01'),
        user: testUser,
      });

      const response = await request(app)
        .get('/api/employees')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].firstName).toBe('John');
    });
  });

  describe('POST /api/employees', () => {
    it('should create new employee', async () => {
      const employeeData = {
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        department: 'Marketing',
        position: 'Manager',
        salary: 80000,
        hireDate: '2024-02-01',
      };

      const response = await request(app)
        .post('/api/employees')
        .set('Authorization', `Bearer ${authToken}`)
        .send(employeeData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.firstName).toBe('Jane');
      expect(response.body.data.employeeId).toMatch(/^EMP\d+$/);
    });

    it('should return validation error for invalid data', async () => {
      const invalidData = {
        firstName: '', // Missing required field
        email: 'invalid-email', // Invalid email format
      };

      const response = await request(app)
        .post('/api/employees')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });
});
```

## Development Workflows

### Git Workflow

```bash
# Feature development workflow
git checkout master
git pull origin master
git checkout -b feature/employee-search

# Make changes and commit
git add .
git commit -m "feat: Add employee search functionality"

# Push and create pull request
git push origin feature/employee-search
```

### Code Generation

```bash
# Generate Hive adapters (Flutter)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate TypeORM migrations (Backend)
npm run migration:generate -- src/migrations/AddEmployeeTable

# Run migrations
npm run migration:run
```

### Development Commands

#### Frontend
```bash
# Start development server
flutter run

# Run tests
flutter test

# Build for web
flutter build web --release

# Build APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
dart format .
```

#### Backend
```bash
# Start development server
npm run dev

# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint

# Format code
npm run format
```

## Debugging Guide

### Flutter Debugging

#### Debug Console
```dart
// Use debugPrint for console output
debugPrint('User logged in: ${user.email}');

// Use assert for development checks
assert(user.isAuthenticated, 'User must be authenticated');
```

#### Flutter Inspector
- Use VS Code Flutter extension
- Widget inspector for UI debugging
- Performance overlay for performance issues

#### Common Issues
1. **State not updating**: Check if `notifyListeners()` is called
2. **Navigation issues**: Verify route names and parameters
3. **API errors**: Check network connectivity and error handling

### Backend Debugging

#### Logging
```typescript
// Use structured logging
logger.info('User login attempt', {
  email: user.email,
  timestamp: new Date().toISOString(),
  ip: req.ip,
});

logger.error('Database connection failed', {
  error: error.message,
  stack: error.stack,
});
```

#### Database Debugging
```typescript
// Enable query logging
AppDataSource.initialize({
  logging: ['query', 'error'],
  logger: 'advanced-console',
});
```

## Performance Optimization

### Frontend Optimization

1. **Lazy Loading**
   ```dart
   // Lazy load heavy widgets
   class LazyEmployeeList extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return ListView.builder(
         itemBuilder: (context, index) {
           return FutureBuilder<Employee>(
             future: loadEmployeeAt(index),
             builder: (context, snapshot) {
               // Handle loading states
             },
           );
         },
       );
     }
   }
   ```

2. **Image Optimization**
   ```dart
   // Use cached network images
   CachedNetworkImage(
     imageUrl: employee.avatarUrl,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   );
   ```

### Backend Optimization

1. **Database Queries**
   ```typescript
   // Use select to limit fields
   const employees = await employeeRepository
     .createQueryBuilder('employee')
     .select(['employee.id', 'employee.firstName', 'employee.lastName'])
     .getMany();

   // Use pagination
   const employees = await employeeRepository.find({
     skip: (page - 1) * limit,
     take: limit,
   });
   ```

2. **Caching**
   ```typescript
   // Implement caching for frequently accessed data
   const cacheKey = `employees:page:${page}`;
   let employees = await cacheService.get(cacheKey);
   
   if (!employees) {
     employees = await employeeService.getAllEmployees(page);
     await cacheService.set(cacheKey, employees, 300); // 5 minutes
   }
   ```

## Security Best Practices

### Frontend Security

1. **Token Storage**
   ```dart
   // Use secure storage for sensitive data
   await secureStorage.write(key: 'auth_token', value: token);
   ```

2. **Input Validation**
   ```dart
   // Validate user input
   String? validateEmail(String? value) {
     if (value == null || value.isEmpty) {
       return 'Email is required';
     }
     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
       return 'Enter a valid email';
     }
     return null;
   }
   ```

### Backend Security

1. **Input Sanitization**
   ```typescript
   // Sanitize and validate input
   export const createEmployeeSchema = Joi.object({
     firstName: Joi.string().trim().min(1).max(50).required(),
     lastName: Joi.string().trim().min(1).max(50).required(),
     email: Joi.string().email().required(),
     salary: Joi.number().min(0).max(1000000).required(),
   });
   ```

2. **SQL Injection Prevention**
   ```typescript
   // Use parameterized queries with TypeORM
   const employees = await employeeRepository
     .createQueryBuilder('employee')
     .where('employee.department = :department', { department })
     .getMany();
   ```

This documentation provides a comprehensive guide for developers working on the Care HR system. For additional help, refer to the specific technology documentation or reach out to the development team.