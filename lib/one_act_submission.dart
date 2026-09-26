import 'dart:convert';
import 'package:http/http.dart' as http;

class OneActRegistration {
  const OneActRegistration({
    required this.directorName,
    required this.category,
    required this.amount,
    required this.school,
    required this.contactNumber,
    required this.emailAddress,
    required this.state,
    required this.performanceBrief,
    required this.pastEvents,
    required this.teamMembers,
    required this.referralName,
  });

  final String directorName;
  final String category;
  final int amount;
  final String school;
  final String contactNumber;
  final String emailAddress;
  final String state;
  final String performanceBrief;
  final String pastEvents;
  final String teamMembers;
  final String referralName;
}

class OneActSubmissionService {
  OneActSubmissionService._();

  static const _defaultGoogleAppsScriptUrl =
      'https://script.google.com/macros/s/AKfycbySNWck4nrWOCZEjvROZwkxvmnYwPTk86FvoOTPFuVGlZH9ToqkENPq3eD50EMeeoHR/exec';
  static const googleAppsScriptUrl = String.fromEnvironment(
    'GOOGLE_APPS_SCRIPT_URL',
    defaultValue: _defaultGoogleAppsScriptUrl,
  );

  static Future<void> submitPayment({
    required OneActRegistration registration,
    required String upiId,
    required String transactionId,
  }) async {
    final response = await http.post(
      Uri.parse(googleAppsScriptUrl),
      body: {
        'formType': 'oneActPayment',
        'submittedAt': DateTime.now().toIso8601String(),
        'directorName': registration.directorName,
        'category': registration.category,
        'amount': registration.amount.toString(),
        'school': registration.school,
        'contactNumber': registration.contactNumber,
        'emailAddress': registration.emailAddress,
        'state': registration.state,
        'performanceBrief': registration.performanceBrief,
        'pastEvents': registration.pastEvents,
        'teamMembers': registration.teamMembers,
        'referralName': registration.referralName,
        'upiId': upiId,
        'transactionId': transactionId,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OneActSubmissionException(_statusErrorMessage(response.statusCode));
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw OneActSubmissionException(
          body['message']?.toString() ?? 'The registration could not be saved.',
        );
      }
    } on FormatException {
      throw const OneActSubmissionException(
        'The server returned an invalid response.',
      );
    }
  }

  static String _statusErrorMessage(int statusCode) {
    if (statusCode == 404) {
      return 'The Apps Script web app was not found. Check the GOOGLE_APPS_SCRIPT_URL for this test environment and redeploy the script.';
    }
    return 'The server returned status $statusCode.';
  }
}

class OneActSubmissionException implements Exception {
  const OneActSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
