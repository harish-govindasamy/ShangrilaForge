import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/enterprise_theme.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/enterprise_button.dart';
import '../providers/report_provider.dart';
import '../widgets/report_card.dart';
import '../widgets/real_time_metrics.dart';
import '../widgets/advanced_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _realTimeUpdateTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _startRealTimeUpdates();
    });
    _animationController.forward();
  }

  void _loadInitialData() {
    context.read<ReportProvider>().loadDashboardSummary();
    context.read<ReportProvider>().loadTimesheetReport();
    context.read<ReportProvider>().loadEmployeeReport();
  }

  void _startRealTimeUpdates() {
    _realTimeUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          context.read<ReportProvider>().loadDashboardSummary();
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _realTimeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Analytics & Reports',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textTertiary,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: AppTheme.titleMedium,
          unselectedLabelStyle: AppTheme.titleMedium,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Reports'),
          ],
        ),
        actions: [
          EnterpriseButton(
            text: '',
            icon: Icons.refresh,
            type: EnterpriseButtonType.ghost,
            size: EnterpriseButtonSize.small,
            customColor: AppTheme.primaryBlue,
            onPressed: () {
              _loadInitialData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reports refreshed'),
                  backgroundColor: AppTheme.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: AppTheme.spacingSm),
          EnterpriseButton(
            text: '',
            icon: Icons.download,
            type: EnterpriseButtonType.ghost,
            size: EnterpriseButtonSize.small,
            customColor: AppTheme.primaryBlue,
            onPressed: () {
              _showExportDialog();
            },
          ),
          SizedBox(width: AppTheme.spacingMd),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading &&
              reportProvider.dashboardSummary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Loading premium analytics...',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (reportProvider.errorMessage != null) {
            return _buildErrorState(reportProvider);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(reportProvider),
                _buildAnalyticsTab(reportProvider),
                _buildReportsTab(reportProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ReportProvider reportProvider) {
    return Center(
      child: EnterpriseCard(
        type: EnterpriseCardType.alert,
        margin: EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorRed,
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              'Unable to Load Reports',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacingSm),
            Text(
              reportProvider.errorMessage!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingLg),
            EnterpriseButton(
              text: 'Retry',
              icon: Icons.refresh,
              type: EnterpriseButtonType.primary,
              onPressed: () => _loadInitialData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ReportProvider reportProvider) {
    final metrics = reportProvider.getDashboardMetrics();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          reportProvider.loadDashboardSummary(),
          reportProvider.loadTimesheetReport(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real-time metrics
            const RealTimeMetrics(),

            SizedBox(height: AppTheme.spacingLg),

            // Premium dashboard cards
            Text(
              'Key Performance Indicators',
              style: AppTheme.headingSmall,
            ),
            SizedBox(height: AppTheme.spacingMd),

            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid - adjust columns based on width
                final crossAxisCount = constraints.maxWidth > 800
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                final childAspectRatio = constraints.maxWidth > 800
                    ? 1.2
                    : constraints.maxWidth > 600
                        ? 1.0
                        : 1.5;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.spacingMd,
                  mainAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: childAspectRatio,
                  children: [
                    EnterpriseInfoCard(
                      title: 'Total Projects',
                      value: '${metrics['totalProjects'] ?? 0}',
                      subtitle: 'Active projects in pipeline',
                      icon: Icons.work_outline,
                      color: AppTheme.primaryBlue,
                      trend: '+12%',
                      isPositiveTrend: true,
                    ),
                    EnterpriseInfoCard(
                      title: 'Team Members',
                      value: '${metrics['totalEmployees'] ?? 0}',
                      subtitle: 'Active team members',
                      icon: Icons.people_outline,
                      color: AppTheme.secondaryBlue,
                      trend: '+5%',
                      isPositiveTrend: true,
                    ),
                    EnterpriseInfoCard(
                      title: 'Hours Logged',
                      value:
                          '${(metrics['totalHours'] ?? 0.0).toStringAsFixed(0)}h',
                      subtitle: 'This month',
                      icon: Icons.access_time_outlined,
                      color: AppTheme.accentBlue,
                      trend: '+8%',
                      isPositiveTrend: true,
                    ),
                    EnterpriseInfoCard(
                      title: 'Efficiency',
                      value: '94%',
                      subtitle: 'Overall performance',
                      icon: Icons.trending_up_outlined,
                      color: AppTheme.successGreen,
                      trend: '+3%',
                      isPositiveTrend: true,
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: AppTheme.spacingLg),

            // Quick stats
            _buildQuickStats(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(ReportProvider reportProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Analytics',
            style: AppTheme.headingSmall,
          ),
          SizedBox(height: AppTheme.spacingMd),
          const AdvancedChart(),
          SizedBox(height: AppTheme.spacingLg),
          _buildAnalyticsGrid(reportProvider),
        ],
      ),
    );
  }

  Widget _buildReportsTab(ReportProvider reportProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Reports',
            style: AppTheme.headingSmall,
          ),
          SizedBox(height: AppTheme.spacingMd),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid - adjust columns based on width
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              final childAspectRatio = constraints.maxWidth > 600 ? 0.7 : 0.6;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
                childAspectRatio: childAspectRatio,
                children: [
                  ReportCard(
                    title: 'Employee Performance',
                    subtitle:
                        'Detailed employee metrics and productivity analysis',
                    icon: Icons.person_outline,
                    color: AppTheme.primaryBlue,
                    onTap: () => _navigateToReport('employee'),
                  ),
                  ReportCard(
                    title: 'Project Analytics',
                    subtitle: 'Project progress, costs, and timeline analysis',
                    icon: Icons.work_outline,
                    color: AppTheme.secondaryBlue,
                    onTap: () => _navigateToReport('project'),
                  ),
                  ReportCard(
                    title: 'Timesheet Insights',
                    subtitle: 'Time tracking patterns and approval workflows',
                    icon: Icons.access_time_outlined,
                    color: AppTheme.accentBlue,
                    onTap: () => _navigateToReport('timesheet'),
                  ),
                  ReportCard(
                    title: 'Monthly Summary',
                    subtitle: 'Comprehensive monthly performance overview',
                    icon: Icons.calendar_month_outlined,
                    color: AppTheme.successGreen,
                    onTap: () => _navigateToReport('monthly'),
                  ),
                  ReportCard(
                    title: 'Financial Report',
                    subtitle: 'Revenue, costs, and profitability analysis',
                    icon: Icons.monetization_on_outlined,
                    color: AppTheme.infoBlue,
                    onTap: () => _navigateToReport('financial'),
                  ),
                  ReportCard(
                    title: 'Export Center',
                    subtitle: 'Download reports in PDF, Excel, or CSV format',
                    icon: Icons.download_outlined,
                    color: AppTheme.errorRed,
                    onTap: () => _showExportDialog(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> metrics) {
    return EnterpriseCard(
      type: EnterpriseCardType.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: AppTheme.titleLarge,
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pending Approval',
                  '${metrics['pendingTimesheets'] ?? 0}',
                  Icons.pending_actions,
                  AppTheme.warningOrange,
                ),
              ),
              SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  '${metrics['activeProjects'] ?? 0}',
                  Icons.check_circle_outline,
                  AppTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.headingSmall.copyWith(color: color),
                ),
                Text(
                  title,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid(ReportProvider reportProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid - adjust columns based on width
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        final childAspectRatio = constraints.maxWidth > 800
            ? 1.6
            : constraints.maxWidth > 600
                ? 1.4
                : 1.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppTheme.spacingMd,
          mainAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: childAspectRatio,
          children: [
            _buildAnalyticsCard(
              'Productivity',
              '92%',
              Icons.trending_up,
              AppTheme.primaryBlue,
              '+5% from last week',
            ),
            _buildAnalyticsCard(
              'Efficiency',
              '87%',
              Icons.speed,
              AppTheme.secondaryBlue,
              '+3% from last week',
            ),
            _buildAnalyticsCard(
              'Quality Score',
              '94%',
              Icons.star,
              AppTheme.accentBlue,
              '+2% from last week',
            ),
            _buildAnalyticsCard(
              'Team Satisfaction',
              '89%',
              Icons.sentiment_satisfied,
              AppTheme.successGreen,
              '+7% from last week',
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return EnterpriseCard(
      type: EnterpriseCardType.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTheme.titleMedium,
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(
            trend,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _navigateToReport(String reportType) {
    // TODO: Navigate to specific report screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $reportType report...'),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Export Reports',
          style: AppTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose export format:',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            _buildExportOption(
                'PDF Report', Icons.picture_as_pdf, AppTheme.errorRed),
            SizedBox(height: AppTheme.spacingXs),
            _buildExportOption(
                'Excel Spreadsheet', Icons.table_chart, AppTheme.successGreen),
            SizedBox(height: AppTheme.spacingXs),
            _buildExportOption(
                'CSV Data', Icons.text_snippet, AppTheme.infoBlue),
          ],
        ),
        actions: [
          EnterpriseButton(
            text: 'Cancel',
            type: EnterpriseButtonType.outline,
            size: EnterpriseButtonSize.medium,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting as $title...'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: AppTheme.spacingSm),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
