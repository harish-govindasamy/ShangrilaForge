import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../widgets/report_card.dart';
import '../widgets/analytics_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadDashboardSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportProvider>().loadDashboardSummary();
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (reportProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reportProvider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      reportProvider.loadDashboardSummary();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Summary
                _buildDashboardSummary(reportProvider),

                const SizedBox(height: 24),

                // Analytics Chart
                _buildAnalyticsChart(reportProvider),

                const SizedBox(height: 24),

                // Report Cards
                _buildReportCards(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardSummary(ReportProvider reportProvider) {
    final metrics = reportProvider.getDashboardMetrics();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Summary',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard('Total Employees',
                    metrics['totalEmployees'].toString(), Icons.people),
                _buildMetricCard('Total Projects',
                    metrics['totalProjects'].toString(), Icons.work),
                _buildMetricCard('Total Customers',
                    metrics['totalCustomers'].toString(), Icons.person),
                _buildMetricCard(
                    'Total Hours',
                    '${(metrics['totalHours'] ?? 0.0).toStringAsFixed(1)}h',
                    Icons.access_time),
                _buildMetricCard('Active Projects',
                    metrics['activeProjects'].toString(), Icons.play_arrow),
                _buildMetricCard('Pending Timesheets',
                    metrics['pendingTimesheets'].toString(), Icons.pending),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart(ReportProvider reportProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Analytics Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            AnalyticsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.5,
          children: const [
            ReportCard(
              title: 'Employee Report',
              subtitle: 'Employee performance and hours',
              icon: Icons.person,
              color: Colors.blue,
            ),
            ReportCard(
              title: 'Project Report',
              subtitle: 'Project progress and costs',
              icon: Icons.work,
              color: Colors.green,
            ),
            ReportCard(
              title: 'Timesheet Report',
              subtitle: 'Time tracking and approvals',
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            ReportCard(
              title: 'Monthly Report',
              subtitle: 'Monthly summary and trends',
              icon: Icons.calendar_month,
              color: Colors.purple,
            ),
            ReportCard(
              title: 'Weekly Report',
              subtitle: 'Weekly progress and activities',
              icon: Icons.calendar_view_week,
              color: Colors.teal,
            ),
            ReportCard(
              title: 'Export Data',
              subtitle: 'Export reports in various formats',
              icon: Icons.download,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
