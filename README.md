# Shangrila Engineers - Employee & Project Management System

A comprehensive Flutter application for managing employees, projects, timesheets, and customers with role-based access control.

## 🚀 Features

### Core Modules
- **Employee Management** - Complete employee profiles with personal and professional information
- **User Authentication** - Role-based access control (Admin, Principal, Employee)
- **Project Management** - Project lifecycle management with version control
- **Timesheet System** - Time tracking with approval workflows
- **Customer Management** - Customer relationship management
- **Reporting System** - Comprehensive analytics and reports

### Key Features
- **Role-Based Access Control (RBAC)** with three user types
- **Version-controlled project codes** (e.g., 0001 → 0001A → 0002B)
- **Comprehensive reporting system** (Employee, Project, Monthly, Weekly reports)
- **Email notifications** for various system events
- **Audit trail** with record tracking for all changes
- **Offline support** with local data caching
- **Responsive design** for mobile and tablet devices

## 📱 Screenshots

The app includes a modern, intuitive interface with:
- Splash screen with company branding
- Login screen with demo credentials
- Dashboard with role-based quick actions
- Overview cards showing key metrics
- Recent activities feed

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Networking**: Dio HTTP client
- **Local Storage**: SharedPreferences
- **Architecture**: Clean Architecture with feature-based modules

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  equatable: ^2.0.5
  http: ^1.1.0
  dio: ^5.3.2
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  uuid: ^4.2.1
```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and API endpoints
│   ├── network/           # API service and networking
│   └── utils/             # Utility functions
├── features/
│   ├── auth/              # Authentication module
│   ├── employee/          # Employee management
│   ├── project/           # Project management
│   ├── timesheet/         # Timesheet system
│   ├── customer/          # Customer management
│   ├── reports/           # Reporting system
│   └── dashboard/         # Dashboard and main screens
├── shared/
│   ├── models/            # Data models
│   ├── widgets/           # Reusable widgets
│   └── services/          # Shared services
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.1.0 or higher
- Dart SDK 3.1.0 or higher
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd shangrila_engineers_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Demo Credentials

The app includes demo credentials for testing:

- **Admin**: admin@shangrila.com / admin123
- **Principal**: principal@shangrila.com / principal123
- **Employee**: employee@shangrila.com / employee123

## 🔧 Configuration

### API Configuration
Update the API base URL in `lib/core/constants/api_endpoints.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### App Constants
Modify app settings in `lib/core/constants/app_constants.dart`:

```dart
static const String appName = 'Shangrila Engineers';
static const String appVersion = '1.0.0';
```

## 📊 Data Models

### Employee Model
```dart
class Employee {
  final String empName;
  final String empEmail;
  final DateTime empDob;
  final String empAddress;
  final String empDesignation;
  // ... other fields
}
```

### Project Model
```dart
class Project {
  final String projectId;
  final String jobName;
  final String jobCode;
  final ProjectStatus status;
  // ... other fields
}
```

### Timesheet Model
```dart
class Timesheet {
  final String userId;
  final String projectId;
  final DateTime weekStartDate;
  final Map<String, double> dailyHours;
  // ... other fields
}
```

## 🔐 Authentication & Authorization

### User Roles
- **Admin**: Full system access, can manage all users and data
- **Principal**: Can manage team members and projects
- **Employee**: Can view own data and log timesheets

### Permission System
```dart
bool hasPermission(String permission) {
  switch (userRole) {
    case UserRole.admin:
      return true;
    case UserRole.principal:
      return permission != 'admin_only';
    case UserRole.employee:
      return permission == 'employee_only' || permission == 'read_only';
  }
}
```

## 📈 Reporting System

The app includes comprehensive reporting features:

- **Employee Reports** - Individual performance metrics
- **Project Reports** - Project progress and costs
- **Monthly Reports** - Monthly organizational metrics
- **Weekly Reports** - Weekly progress tracking
- **Dashboard Analytics** - Real-time overview

## 🔄 API Integration

### Authentication Endpoints
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/change-password` - Change password

### Employee Endpoints
- `GET /employees` - Get all employees
- `POST /employees` - Create employee
- `PUT /employees/{id}` - Update employee
- `DELETE /employees/{id}` - Delete employee

### Project Endpoints
- `GET /projects` - Get all projects
- `POST /projects` - Create project
- `PUT /projects/{id}` - Update project
- `DELETE /projects/{id}` - Delete project

## 🧪 Testing

Run tests using:
```bash
flutter test
```

Run analysis:
```bash
flutter analyze
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact:
- Email: support@shangrila-engineers.com
- Documentation: [Link to documentation]

## 🗺️ Roadmap

### Phase 1: Core Foundation ✅
- [x] Project setup and architecture
- [x] Authentication system
- [x] Basic navigation
- [x] Employee CRUD operations

### Phase 2: Project Management (In Progress)
- [ ] Project creation and management
- [ ] Customer management
- [ ] Version control system
- [ ] Status tracking

### Phase 3: Timesheet System (Planned)
- [ ] Timesheet entry forms
- [ ] Approval workflow
- [ ] Time tracking validation
- [ ] Notification system

### Phase 4: Reporting & Analytics (Planned)
- [ ] Dashboard implementation
- [ ] Chart visualizations
- [ ] Report generation
- [ ] Export functionality

### Phase 5: Polish & Testing (Planned)
- [ ] UI/UX refinements
- [ ] Performance optimization
- [ ] Testing and bug fixes
- [ ] Deployment preparation

---

**Shangrila Engineers** - Empowering teams with efficient project management.