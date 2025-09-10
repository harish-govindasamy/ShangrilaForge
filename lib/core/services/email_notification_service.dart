import 'package:logging/logging.dart';

class EmailNotificationService {
  static final EmailNotificationService _instance =
      EmailNotificationService._internal();
  static final Logger _logger = Logger('EmailNotificationService');
  factory EmailNotificationService() => _instance;
  EmailNotificationService._internal();

  // Send email when user credentials are created
  Future<void> sendUserCredentialsEmail(
      String userEmail, String userName, String tempPassword) async {
    try {
      final emailData = {
        'to': userEmail,
        'subject': 'Welcome to Shangrila Engineers - Login Credentials',
        'template': 'user_credentials',
        'data': {
          'userName': userName,
          'tempPassword': tempPassword,
          'loginUrl': 'https://app.shangrilaengineers.com/login',
        }
      };

      // This would integrate with actual email service (SendGrid, AWS SES, etc.)
      await _sendEmail(emailData);
      _logger.info('Credentials email sent to $userEmail');
    } catch (e) {
      _logger.severe('Failed to send credentials email: $e');
    }
  }

  // Send email when user limit (200) is reached
  Future<void> sendUserLimitNotificationEmail(String adminEmail) async {
    try {
      final emailData = {
        'to': adminEmail,
        'subject': 'Alert: User Limit Reached (200 users)',
        'template': 'user_limit_alert',
        'data': {
          'currentDate': DateTime.now().toIso8601String(),
          'maxUsers': 200,
        }
      };

      await _sendEmail(emailData);
      _logger.info('User limit notification sent to admin');
    } catch (e) {
      _logger.severe('Failed to send user limit notification: $e');
    }
  }

  // Send email when new project is created
  Future<void> sendProjectCreatedEmail(
      String adminEmail, String projectName, String jobCode) async {
    try {
      final emailData = {
        'to': adminEmail,
        'subject': 'New Project Created - $projectName',
        'template': 'project_created',
        'data': {
          'projectName': projectName,
          'jobCode': jobCode,
          'createdDate': DateTime.now().toIso8601String(),
        }
      };

      await _sendEmail(emailData);
      _logger.info('Project creation notification sent to admin');
    } catch (e) {
      _logger.severe('Failed to send project creation notification: $e');
    }
  }

  // Send weekly timesheet reports
  Future<void> sendWeeklyTimesheetReport(
      List<String> recipientEmails, Map<String, dynamic> reportData) async {
    try {
      for (final email in recipientEmails) {
        final emailData = {
          'to': email,
          'subject':
              'Weekly Timesheet Report - ${DateTime.now().toIso8601String().split('T')[0]}',
          'template': 'weekly_timesheet_report',
          'data': reportData,
          'attachments': [
            {
              'filename': 'weekly_timesheet_report.pdf',
              'content': reportData['pdfContent'] ?? '',
            }
          ]
        };

        await _sendEmail(emailData);
      }
      _logger.info(
          'Weekly timesheet reports sent to ${recipientEmails.length} recipients');
    } catch (e) {
      _logger.severe('Failed to send weekly timesheet reports: $e');
    }
  }

  // Send monthly reports
  Future<void> sendMonthlyReport(
      List<String> recipientEmails, Map<String, dynamic> reportData) async {
    try {
      for (final email in recipientEmails) {
        final emailData = {
          'to': email,
          'subject':
              'Monthly Report - ${DateTime.now().toIso8601String().split('T')[0]}',
          'template': 'monthly_report',
          'data': reportData,
          'attachments': [
            {
              'filename': 'monthly_report.xlsx',
              'content': reportData['excelContent'] ?? '',
            }
          ]
        };

        await _sendEmail(emailData);
      }
      _logger
          .info('Monthly reports sent to ${recipientEmails.length} recipients');
    } catch (e) {
      _logger.severe('Failed to send monthly reports: $e');
    }
  }

  // Send timesheet submission notification to Principal
  Future<void> sendTimesheetSubmissionNotification(
      String principalEmail, String employeeName, String timesheetId) async {
    try {
      final emailData = {
        'to': principalEmail,
        'subject': 'Timesheet Submission Requires Approval',
        'template': 'timesheet_submission',
        'data': {
          'employeeName': employeeName,
          'timesheetId': timesheetId,
          'submissionDate': DateTime.now().toIso8601String(),
          'approvalUrl':
              'https://app.shangrilaengineers.com/timesheets/$timesheetId',
        }
      };

      await _sendEmail(emailData);
      _logger.info('Timesheet submission notification sent to principal');
    } catch (e) {
      _logger.severe('Failed to send timesheet submission notification: $e');
    }
  }

  // Send timesheet approval/rejection notification to employee
  Future<void> sendTimesheetStatusNotification(String employeeEmail,
      String status, String timesheetId, String? feedback) async {
    try {
      final emailData = {
        'to': employeeEmail,
        'subject': 'Timesheet ${status.toUpperCase()} - $timesheetId',
        'template': 'timesheet_status',
        'data': {
          'status': status,
          'timesheetId': timesheetId,
          'feedback': feedback ?? '',
          'statusDate': DateTime.now().toIso8601String(),
        }
      };

      await _sendEmail(emailData);
      _logger.info('Timesheet status notification sent to employee');
    } catch (e) {
      _logger.severe('Failed to send timesheet status notification: $e');
    }
  }

  // Schedule automatic weekly reports
  Future<void> scheduleWeeklyReports() async {
    // This would integrate with a job scheduler (cron, etc.)
    _logger.info('Weekly report scheduler activated');
  }

  // Schedule automatic monthly reports
  Future<void> scheduleMonthlyReports() async {
    // This would integrate with a job scheduler (cron, etc.)
    _logger.info('Monthly report scheduler activated');
  }

  // Private method to handle actual email sending
  Future<void> _sendEmail(Map<String, dynamic> emailData) async {
    // This would integrate with actual email service provider
    // Examples: SendGrid, AWS SES, Mailgun, etc.

    // Mock implementation for development
    await Future.delayed(const Duration(milliseconds: 500));

    // In production, this would be something like:
    // final response = await http.post(
    //   Uri.parse('https://api.sendgrid.v3/mail/send'),
    //   headers: {
    //     'Authorization': 'Bearer $apiKey',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(emailData),
    // );

    _logger.info('Email sent: ${emailData['subject']} to ${emailData['to']}');
  }
}
