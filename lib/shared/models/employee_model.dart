import 'package:equatable/equatable.dart';
import 'user_model.dart';

class Employee extends Equatable {
  final String empName;
  final String empEmail;
  final DateTime empDob;
  final String empAddress;
  final String empDesignation;
  final int empExp;
  final String empBgp;
  final String empCategory;
  final String empCmob;
  final DateTime? joinDate;
  final String salary;
  final String bankAccount;
  final String ifscCode;
  final String uniqueIdentificationNumber;
  final String ssnNo;
  final String emergencyName;
  final String emergencyRelation;
  final String emergencyPhone;
  final String employeeId;
  final String userId;
  final String firstName;
  final String lastName;
  final String empCode;
  final String email;
  final String department;
  final String gender;
  final String maritalStatus;
  final String? parentName;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final List<String> skills;
  final List<RecordTracking> recordTracking;

  const Employee({
    required this.empName,
    required this.empEmail,
    required this.empDob,
    required this.empAddress,
    required this.empDesignation,
    this.empExp = 0,
    required this.empBgp,
    this.empCategory = '',
    required this.empCmob,
    this.joinDate,
    this.salary = '0.00',
    required this.bankAccount,
    required this.ifscCode,
    required this.uniqueIdentificationNumber,
    required this.ssnNo,
    required this.emergencyName,
    required this.emergencyRelation,
    required this.emergencyPhone,
    required this.employeeId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.empCode,
    required this.email,
    required this.department,
    required this.gender,
    required this.maritalStatus,
    this.parentName,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.skills = const [],
    this.recordTracking = const [],
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empName: json['emp_name']?.toString() ?? '',
      empEmail: json['emp_cemail']?.toString() ?? '',
      empDob: json['emp_dob'] != null 
          ? DateTime.parse(json['emp_dob'].toString())
          : DateTime.now(),
      empAddress: json['emp_address']?.toString() ?? '',
      empDesignation: json['emp_designation']?.toString() ?? '',
      empExp: json['emp_exp'] ?? 0,
      empBgp: json['emp_bgp']?.toString() ?? '',
      empCategory: json['emp_category']?.toString() ?? '',
      empCmob: json['emp_cmob']?.toString() ?? '',
      joinDate: json['joindate'] != null 
          ? DateTime.parse(json['joindate'].toString()) 
          : null,
      salary: json['salary']?.toString() ?? '0.00',
      bankAccount: json['bankaccount']?.toString() ?? '',
      ifscCode: json['ifsccode']?.toString() ?? '',
      uniqueIdentificationNumber: json['unique_identification_number']?.toString() ?? '',
      ssnNo: json['ssn_no']?.toString() ?? '',
      emergencyName: json['emergencyname']?.toString() ?? '',
      emergencyRelation: json['emergencyrelation']?.toString() ?? '',
      emergencyPhone: json['emergencyphone']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      empCode: json['empCode']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      maritalStatus: json['maritalStatus']?.toString() ?? '',
      parentName: json['parentName']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      recordTracking: (json['recordTracking'] as List<dynamic>?)
          ?.map((e) => RecordTracking.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_name': empName,
      'emp_cemail': empEmail,
      'emp_dob': empDob.toIso8601String(),
      'emp_address': empAddress,
      'emp_designation': empDesignation,
      'emp_exp': empExp,
      'emp_bgp': empBgp,
      'emp_category': empCategory,
      'emp_cmob': empCmob,
      'joindate': joinDate?.toIso8601String(),
      'salary': salary,
      'bankaccount': bankAccount,
      'ifsccode': ifscCode,
      'unique_identification_number': uniqueIdentificationNumber,
      'ssn_no': ssnNo,
      'emergencyname': emergencyName,
      'emergencyrelation': emergencyRelation,
      'emergencyphone': emergencyPhone,
      'employeeId': employeeId,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'empCode': empCode,
      'email': email,
      'department': department,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'parentName': parentName,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'skills': skills,
      'recordTracking': recordTracking.map((e) => e.toJson()).toList(),
    };
  }

  Employee copyWith({
    String? empName,
    String? empEmail,
    DateTime? empDob,
    String? empAddress,
    String? empDesignation,
    int? empExp,
    String? empBgp,
    String? empCategory,
    String? empCmob,
    DateTime? joinDate,
    String? salary,
    String? bankAccount,
    String? ifscCode,
    String? uniqueIdentificationNumber,
    String? ssnNo,
    String? emergencyName,
    String? emergencyRelation,
    String? emergencyPhone,
    String? employeeId,
    String? userId,
    String? firstName,
    String? lastName,
    String? empCode,
    String? email,
    String? department,
    String? gender,
    String? maritalStatus,
    String? parentName,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    List<String>? skills,
    List<RecordTracking>? recordTracking,
  }) {
    return Employee(
      empName: empName ?? this.empName,
      empEmail: empEmail ?? this.empEmail,
      empDob: empDob ?? this.empDob,
      empAddress: empAddress ?? this.empAddress,
      empDesignation: empDesignation ?? this.empDesignation,
      empExp: empExp ?? this.empExp,
      empBgp: empBgp ?? this.empBgp,
      empCategory: empCategory ?? this.empCategory,
      empCmob: empCmob ?? this.empCmob,
      joinDate: joinDate ?? this.joinDate,
      salary: salary ?? this.salary,
      bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      uniqueIdentificationNumber: uniqueIdentificationNumber ?? this.uniqueIdentificationNumber,
      ssnNo: ssnNo ?? this.ssnNo,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      empCode: empCode ?? this.empCode,
      email: email ?? this.email,
      department: department ?? this.department,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      parentName: parentName ?? this.parentName,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      skills: skills ?? this.skills,
      recordTracking: recordTracking ?? this.recordTracking,
    );
  }

  @override
  List<Object?> get props => [
        empName,
        empEmail,
        empDob,
        empAddress,
        empDesignation,
        empExp,
        empBgp,
        empCategory,
        empCmob,
        joinDate,
        salary,
        bankAccount,
        ifscCode,
        uniqueIdentificationNumber,
        ssnNo,
        emergencyName,
        emergencyRelation,
        emergencyPhone,
        employeeId,
        userId,
        firstName,
        lastName,
        empCode,
        email,
        department,
        gender,
        maritalStatus,
        parentName,
        city,
        state,
        country,
        postalCode,
        skills,
        recordTracking,
      ];
}
