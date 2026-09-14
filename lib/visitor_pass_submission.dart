import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'one_act_submission.dart';

class VisitorPassRegistrant {
  const VisitorPassRegistrant({
    required this.name,
    required this.emailAddress,
    required this.phoneNumber,
    required this.packageName,
    required this.amount,
    required this.ticketCount,
  });

  final String name;
  final String emailAddress;
  final String phoneNumber;
  final String packageName;
  final int amount;
  final int ticketCount;
}

class VisitorPass {
  const VisitorPass({required this.passIds});

  final List<String> passIds;
}

class VisitorPassSubmissionService {
  VisitorPassSubmissionService._();

  static Future<VisitorPass> submitPayment({
    required VisitorPassRegistrant registrant,
    required String upiId,
    required String transactionId,
    required List<String> passIds,
    required List<Uint8List> qrImageBytes,
  }) async {
    if (passIds.length != qrImageBytes.length) {
      throw const VisitorPassSubmissionException(
        'Could not prepare all requested ticket QR codes.',
      );
    }
    final body = await _post({
      'formType': 'visitorPassPayment',
      'submittedAt': DateTime.now().toIso8601String(),
      'name': registrant.name,
      'emailAddress': registrant.emailAddress,
      'phoneNumber': registrant.phoneNumber,
      'packageName': registrant.packageName,
      'amount': registrant.amount.toString(),
      'ticketCount': registrant.ticketCount.toString(),
      'upiId': upiId,
      'transactionId': transactionId,
      'passId': passIds.first,
      'passIds': jsonEncode(passIds),
      'qrImageBase64': base64Encode(qrImageBytes.first),
      'qrImagesBase64': jsonEncode(qrImageBytes.map(base64Encode).toList()),
    });
    final returnedPassIds = _readReturnedPassIds(body);
    if (returnedPassIds.isEmpty) {
      throw const VisitorPassSubmissionException(
        'The server did not return pass IDs.',
      );
    }
    return VisitorPass(passIds: returnedPassIds);
  }

  static List<String> _readReturnedPassIds(Map<String, dynamic> body) {
    final passIds = body['passIds'];
    if (passIds is List) {
      return passIds.map((value) => value.toString()).toList();
    }

    final passId = body['passId']?.toString();
    return passId == null || passId.isEmpty ? const [] : [passId];
  }

  static Future<Map<String, dynamic>> _post(Map<String, String> payload) async {
    final response = await http.post(
      Uri.parse(OneActSubmissionService.googleAppsScriptUrl),
      body: payload,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitorPassSubmissionException(
        _statusErrorMessage(response.statusCode),
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

  static String _statusErrorMessage(int statusCode) {
    if (statusCode == 404) {
      return 'The Apps Script web app was not found. Check the GOOGLE_APPS_SCRIPT_URL for this test environment and redeploy the script.';
    }
    return 'The server returned status $statusCode.';
  }
}

class VisitorPassSubmissionException implements Exception {
  const VisitorPassSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
