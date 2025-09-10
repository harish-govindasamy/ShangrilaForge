# Shangrila Engineers App - Architecture Guide

## Project Structure

This document outlines the architecture of the Shangrila Engineers App and provides guidance for maintaining and extending the codebase.

### Directory Structure

The app follows a clean architecture approach with the following main directories:

```
lib/
  ├── core/              # Core functionality used throughout the app
  │   ├── config/        # Configuration constants and settings
  │   ├── constants/     # App-wide constants
  │   ├── errors/        # Error handling and failure classes
  │   ├── network/       # Network related code (API service, interceptors)
  │   ├── services/      # Core services (provider factory, etc.)
  │   ├── theme/         # App theme configuration
  │   └── utils/         # Utility functions and extensions
  │
  ├── data/              # Data layer
  │   ├── datasources/   # Remote and local data sources
  │   └── repositories/  # Repository implementations
  │
  ├── domain/            # Business logic
  │   └── usecases/      # Use cases that encapsulate business rules
  │
  ├── features/          # Feature modules
  │   ├── auth/          # Authentication feature
  │   ├── customer/      # Customer management feature
  │   ├── dashboard/     # Dashboard feature
  │   ├── employee/      # Employee management feature
  │   ├── project/       # Project management feature
  │   ├── reports/       # Reporting feature
  │   ├── timesheet/     # Timesheet feature
  │   └── user/          # User profile feature
  │
  ├── providers/         # State management providers
  │
  ├── shared/            # Shared components used across features
  │   ├── enums/         # Enumerations
  │   ├── mixins/        # Mixins
  │   ├── models/        # Data models
  │   ├── services/      # Shared services
  │   └── widgets/       # Reusable widgets
  │
  └── main.dart          # App entry point
```

## Architectural Patterns

### Clean Architecture

The app follows Clean Architecture principles with three main layers:

1. **Presentation Layer** - UI components (screens, widgets) and providers
2. **Domain Layer** - Business logic (use cases, repository interfaces)
3. **Data Layer** - Data sources and repository implementations

### Provider Pattern for State Management

State management is handled using the Provider package, with:

1. **Basic Providers** - Simple providers for simpler features
2. **Enhanced Providers** - More complex providers with full CRUD operations and error handling

## Dependency Injection

We use a Factory pattern for dependency injection:

- `ProviderFactory` - Creates and configures providers with their dependencies
- Use `ProviderFactory.createEnhancedProjectProvider()` to get a properly configured project provider

## Best Practices

### Adding a New Feature

1. Create appropriate directories under `features/`
2. Implement models in `shared/models/` if they'll be used across features
3. Add data sources and repositories if needed
4. Create use cases in the domain layer
5. Implement UI components
6. Add provider to `main.dart` using the provider factory

### Modifying Existing Features

1. Ensure changes maintain the separation of concerns
2. Update tests for modified components
3. Follow the established patterns for error handling and state management

### Error Handling

All operations that could fail should:

1. Use the Either type from `dartz` package
2. Return appropriate `Failure` types from `core/errors/`
3. Handle errors at the UI level in a user-friendly way

## Technical Debt and Future Improvements

1. ✅ Standardize on one version of each provider implementation
2. ✅ Use proper dependency injection for all providers
3. Create unit and widget tests for critical functionality
4. Implement proper logging throughout the app
5. Create a comprehensive theme system

## Contact

For questions about the architecture, contact the lead developer at development@shangrilaengineers.com
