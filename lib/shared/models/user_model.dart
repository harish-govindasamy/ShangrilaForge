import 'package:equatable/equatable.dart';

enum UserRole { 
  admin, 
  principal, 
  employee;
  
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.principal:
        return 'Principal';
      case UserRole.employee:
        return 'Employee';
    }
  }
}

class User extends Equatable {
  final String userId;
  final String userName;
  final String employeeId;
  final DateTime? lastLogin;
  final DateTime? lastLoginAt;
  final UserRole role;
  final String password;
  final String newPassword;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final List<RecordTracking> recordTracking;

  const User({
    required this.userId,
    required this.userName,
    required this.employeeId,
    this.lastLogin,
    this.lastLoginAt,
    required this.role,
    required this.password,
    required this.newPassword,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.recordTracking = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'].toString()) 
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'].toString()) 
          : null,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role']?.toString(),
        orElse: () => UserRole.employee,
      ),
      password: json['password']?.toString() ?? '',
      newPassword: json['new_password']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? '',
      updatedBy: json['updatedBy']?.toString() ?? '',
      recordTracking: (json['recordTracking'] as List<dynamic>?)
          ?.map((e) => RecordTracking.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'employeeId': employeeId,
      'lastLogin': lastLogin?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'role': role.name,
      'password': password,
      'new_password': newPassword,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'recordTracking': recordTracking.map((e) => e.toJson()).toList(),
    };
  }

  User copyWith({
    String? userId,
    String? userName,
    String? employeeId,
    DateTime? lastLogin,
    DateTime? lastLoginAt,
    UserRole? role,
    String? password,
    String? newPassword,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    List<RecordTracking>? recordTracking,
  }) {
    return User(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      employeeId: employeeId ?? this.employeeId,
      lastLogin: lastLogin ?? this.lastLogin,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      password: password ?? this.password,
      newPassword: newPassword ?? this.newPassword,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      recordTracking: recordTracking ?? this.recordTracking,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        employeeId,
        lastLogin,
        lastLoginAt,
        role,
        password,
        newPassword,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        recordTracking,
      ];
}

class RecordTracking extends Equatable {
  final int id;
  final String module;
  final String method;
  final String userId;
  final String userName;
  final DateTime modifiedAt;
  final Map<String, dynamic> changedFields;

  const RecordTracking({
    required this.id,
    required this.module,
    required this.method,
    required this.userId,
    required this.userName,
    required this.modifiedAt,
    required this.changedFields,
  });

  factory RecordTracking.fromJson(Map<String, dynamic> json) {
    return RecordTracking(
      id: json['id'] ?? 0,
      module: json['module']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      modifiedAt: json['modifiedAt'] != null 
          ? DateTime.parse(json['modifiedAt'].toString())
          : DateTime.now(),
      changedFields: Map<String, dynamic>.from(json['changedFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'method': method,
      'userId': userId,
      'userName': userName,
      'modifiedAt': modifiedAt.toIso8601String(),
      'changedFields': changedFields,
    };
  }

  @override
  List<Object?> get props => [
        id,
        module,
        method,
        userId,
        userName,
        modifiedAt,
        changedFields,
      ];
}
