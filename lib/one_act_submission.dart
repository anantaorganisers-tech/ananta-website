import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OneActRegistration {
  const OneActRegistration({
    required this.directorName,
    required this.category,
    required this.school,
    required this.contactNumber,
    required this.emailAddress,
    required this.state,
    required this.pastEvents,
    required this.teamMembers,
    required this.referralName,
    required this.brochureName,
    required this.brochureMimeType,
    required this.brochureBytes,
  });

  final String directorName;
  final String category;
  final String school;
  final String contactNumber;
  final String emailAddress;
  final String state;
  final String pastEvents;
  final String teamMembers;
  final String referralName;
  final String brochureName;
  final String brochureMimeType;
  final Uint8List brochureBytes;
}

class OneActSubmissionService {
  OneActSubmissionService._();

  static const googleAppsScriptUrl =
      'https://script.google.com/macros/s/AKfycbzqztAwr8fgKZt-q93kxIa_Yhj4S8WHTmp9LQpF_PdLe5YbxqHomcXu9zvKI014zx-1/exec';

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
        'school': registration.school,
        'contactNumber': registration.contactNumber,
        'emailAddress': registration.emailAddress,
        'state': registration.state,
        'pastEvents': registration.pastEvents,
        'teamMembers': registration.teamMembers,
        'referralName': registration.referralName,
        'brochureName': registration.brochureName,
        'brochureMimeType': registration.brochureMimeType,
        'brochureBase64': base64Encode(registration.brochureBytes),
        'upiId': upiId,
        'transactionId': transactionId,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OneActSubmissionException(
        'The server returned status ${response.statusCode}.',
      );
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
}

class OneActSubmissionException implements Exception {
  const OneActSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
