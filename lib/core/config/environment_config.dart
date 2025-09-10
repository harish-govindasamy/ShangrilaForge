enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;
  
  static Environment get currentEnvironment => _currentEnvironment;
  
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging-api.shangrila-engineers.com';
      case Environment.production:
        return 'https://api.shangrila-engineers.com';
    }
  }
  
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  // Debug settings
  static bool get enableLogging => !isProduction;
  static bool get enableDebugMode => isDevelopment;
  
  // API settings
  static Duration get connectTimeout => isDevelopment 
      ? const Duration(seconds: 10) 
      : const Duration(seconds: 30);
      
  static Duration get receiveTimeout => isDevelopment 
      ? const Duration(seconds: 10) 
      : const Duration(seconds: 30);
}
