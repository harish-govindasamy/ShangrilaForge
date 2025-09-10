# API Setup Guide

## Problem
The app was getting `net::ERR_NAME_NOT_RESOLVED` errors when trying to connect to `https://api.shangrila-engineers.com`.

## Solutions Implemented

### 1. Environment-Based Configuration
- Created `EnvironmentConfig` class to manage different environments
- Automatically switches between development, staging, and production URLs
- Currently set to development mode with localhost

### 2. Mock API Service
- Created `MockApiService` for development when real API is not available
- Includes mock data for all demo users:
  - Admin: admin@shangrila.com / admin123
  - Principal: principal@shangrila.com / principal123
  - Employee: employee@shangrila.com / employee123

### 3. Enhanced Error Handling
- Better error messages for DNS resolution failures
- More descriptive timeout messages
- Graceful fallback from mock to real API

## How to Use

### For Development
The app is currently configured for development mode and will use the mock API service. You can login with any of the demo credentials.

### For Production
1. Update `EnvironmentConfig._currentEnvironment` to `Environment.production`
2. Ensure your production API server is running at `https://api.shangrila-engineers.com`

### For Local API Server
1. Start your local API server (e.g., on port 3000)
2. The app will automatically connect to `http://localhost:3000` in development mode

## Environment Switching
To switch environments, modify the `_currentEnvironment` variable in `lib/core/config/environment_config.dart`:

```dart
static const Environment _currentEnvironment = Environment.development; // or staging/production
```

## Testing
The mock service provides realistic responses and can be used for testing the UI without a real backend.
