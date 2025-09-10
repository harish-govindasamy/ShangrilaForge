import 'package:flutter/material.dart';
import '../../../shared/widgets/project_provider_scope.dart';
import 'project_list_screen.dart';

/// A wrapper widget that ensures the ProjectListScreen always has
/// access to an EnhancedProjectProvider
class ProjectListScreenWrapper extends StatelessWidget {
  const ProjectListScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectProviderScope(
      child: ProjectListScreen(),
    );
  }
}
