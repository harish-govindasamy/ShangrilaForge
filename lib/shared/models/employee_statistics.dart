class EmployeeStatistics {
  final Map<String, int> departmentDistribution;
  final Map<String, int> designationDistribution;
  final double averageExperience;

  const EmployeeStatistics({
    required this.departmentDistribution,
    required this.designationDistribution,
    required this.averageExperience,
  });

  int get totalEmployees =>
      departmentDistribution.values.fold(0, (sum, count) => sum + count);

  int get totalDepartments => departmentDistribution.length;

  int get totalDesignations => designationDistribution.length;

  String get mostCommonDepartment {
    if (departmentDistribution.isEmpty) return 'N/A';
    return departmentDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostCommonDesignation {
    if (designationDistribution.isEmpty) return 'N/A';
    return designationDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
