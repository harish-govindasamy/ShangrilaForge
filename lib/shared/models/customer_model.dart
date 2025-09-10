import 'package:equatable/equatable.dart';
import 'user_model.dart';

class Customer extends Equatable {
  final String customerId;
  final String custName;
  final String custCode;
  final String custEmail;
  final String custAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final List<RecordTracking> recordTracking;

  const Customer({
    required this.customerId,
    required this.custName,
    required this.custCode,
    required this.custEmail,
    required this.custAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.recordTracking = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['Customer_id'] ?? '',
      custName: json['Cust_name'] ?? '',
      custCode: json['Cust_code'] ?? '',
      custEmail: json['Cust_email'] ?? '',
      custAddress: json['Cust_address'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      recordTracking: (json['recordTracking'] as List<dynamic>?)
          ?.map((e) => RecordTracking.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_id': customerId,
      'Cust_name': custName,
      'Cust_code': custCode,
      'Cust_email': custEmail,
      'Cust_address': custAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'recordTracking': recordTracking.map((e) => e.toJson()).toList(),
    };
  }

  Customer copyWith({
    String? customerId,
    String? custName,
    String? custCode,
    String? custEmail,
    String? custAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    List<RecordTracking>? recordTracking,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      custName: custName ?? this.custName,
      custCode: custCode ?? this.custCode,
      custEmail: custEmail ?? this.custEmail,
      custAddress: custAddress ?? this.custAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      recordTracking: recordTracking ?? this.recordTracking,
    );
  }

  @override
  List<Object?> get props => [
        customerId,
        custName,
        custCode,
        custEmail,
        custAddress,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        recordTracking,
      ];
}
