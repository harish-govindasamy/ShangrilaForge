enum SortBy {
  name,
  department,
  designation,
  experience,
  joinDate,
}

extension SortByExtension on SortBy {
  String get displayName {
    switch (this) {
      case SortBy.name:
        return 'Name';
      case SortBy.department:
        return 'Department';
      case SortBy.designation:
        return 'Designation';
      case SortBy.experience:
        return 'Experience';
      case SortBy.joinDate:
        return 'Join Date';
    }
  }

  String get sortKey {
    switch (this) {
      case SortBy.name:
        return 'empName';
      case SortBy.department:
        return 'department';
      case SortBy.designation:
        return 'empDesignation';
      case SortBy.experience:
        return 'empExp';
      case SortBy.joinDate:
        return 'joinDate';
    }
  }
}
