import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'one_act_submission.dart';

class VisitorPassRegistrant {
  const VisitorPassRegistrant({
    required this.name,
    required this.emailAddress,
    required this.phoneNumber,
  });

  final String name;
  final String emailAddress;
  final String phoneNumber;
}

class VisitorPass {
  const VisitorPass({required this.passId});

  final String passId;
}

class VisitorPassSubmissionService {
  VisitorPassSubmissionService._();

  static Future<VisitorPass> submitPayment({
    required VisitorPassRegistrant registrant,
    required String upiId,
    required String transactionId,
    required String passId,
    required Uint8List qrImageBytes,
  }) async {
    final body = await _post({
      'formType': 'visitorPassPayment',
      'submittedAt': DateTime.now().toIso8601String(),
      'name': registrant.name,
      'emailAddress': registrant.emailAddress,
      'phoneNumber': registrant.phoneNumber,
      'upiId': upiId,
      'transactionId': transactionId,
      'passId': passId,
      'qrImageBase64': base64Encode(qrImageBytes),
    });
    final returnedPassId = body['passId']?.toString();
    if (returnedPassId == null || returnedPassId.isEmpty) {
      throw const VisitorPassSubmissionException(
        'The server did not return a pass ID.',
      );
    }
    return VisitorPass(passId: returnedPassId);
  }

  static Future<Map<String, dynamic>> _post(Map<String, String> payload) async {
    final response = await http.post(
      Uri.parse(OneActSubmissionService.googleAppsScriptUrl),
      body: payload,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitorPassSubmissionException(
        'The server returned status ${response.statusCode}.',
      );
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw VisitorPassSubmissionException(
          body['message']?.toString() ?? 'The visitor pass could not be saved.',
        );
      }
      return body;
    } on FormatException {
      throw const VisitorPassSubmissionException(
        'The server returned an invalid response.',
      );
    }
  }
}

class VisitorPassSubmissionException implements Exception {
  const VisitorPassSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
