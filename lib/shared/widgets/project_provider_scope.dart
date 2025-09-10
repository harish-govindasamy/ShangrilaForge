import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/provider_factory.dart';
import '../../providers/enhanced_project_provider.dart';

/// This widget ensures that an EnhancedProjectProvider is available to all descendants
/// It acts as a scoped provider to avoid the "Provider not found" error
class ProjectProviderScope extends StatelessWidget {
  final Widget child;

  const ProjectProviderScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the provider is already available in the parent context
    try {
      Provider.of<EnhancedProjectProvider>(context, listen: false);
      // If we reach here, the provider exists, so just return the child
      return child;
    } catch (_) {
      // Provider not found, so create a new one
      return ChangeNotifierProvider(
        create: (_) => ProviderFactory.createEnhancedProjectProvider(),
        child: child,
      );
    }
  }
}
