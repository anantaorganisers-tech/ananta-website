import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'one_act_page.dart';
import 'one_act_submission.dart';
import 'rangaksh_footer.dart';
import 'sec_form.dart';

class StallSetupForm extends StatefulWidget {
  const StallSetupForm({super.key});

  @override
  State<StallSetupForm> createState() => _StallSetupFormState();
}

class _StallSetupFormState extends State<StallSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _shopController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedShopType;
  String? _selectedStallTime;

  static const _shopTypes = ['Food', 'Art/Games', 'Clothing'];
  static const _stallTimes = ['Day', 'Night'];

  @override
  void dispose() {
    _ownerController.dispose();
    _shopController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse(OneActSubmissionService.googleAppsScriptUrl),
        body: {
          'formType': 'stallSetup',
          'submittedAt': DateTime.now().toIso8601String(),
          'ownerName': _ownerController.text.trim(),
          'shopName': _shopController.text.trim(),
          'shopType': _selectedShopType ?? '',
          'stallTime': _selectedStallTime ?? '',
          'contactNumber': _contactController.text.trim(),
          'emailAddress': _emailController.text.trim(),
        },
      );

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          _showMessage(body['message']?.toString() ?? 'Submission failed.');
          return;
        }
        await _showSuccessDialog();
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/rangaksh', (route) => false);
      } else {
        _showMessage(_statusErrorMessage(response.statusCode));
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not submit the form. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusErrorMessage(int statusCode) {
    if (statusCode == 404) {
      return 'The Apps Script web app was not found. Redeploy the script and check GOOGLE_APPS_SCRIPT_URL.';
    }
    return 'Submission failed with status $statusCode.';
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Stall Request Submitted',
          style: GoogleFonts.baloo2(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'For further details, you will be contacted by Team Rangaksh soon.',
          style: GoogleFonts.baloo2(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateContactNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'This field is required';
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 600;
    final horizontalPadding = mobile ? 20.0 : 40.0;
    final formSpacing = mobile ? 28.0 : 32.0;

    return Scaffold(
      appBar: const CompetitionAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _StallHeroTitle(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                mobile ? 48 : 74,
                horizontalPadding,
                mobile ? 64 : 120,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _StallTextInputBlock(
                          label: 'Name of Owner',
                          controller: _ownerController,
                        ),
                        SizedBox(height: formSpacing),
                        _StallTextInputBlock(
                          label: 'Name of Shop',
                          controller: _shopController,
                        ),
                        SizedBox(height: formSpacing),
                        _StallDropdownBlock(
                          label: 'Type of Shop',
                          value: _selectedShopType,
                          options: _shopTypes,
                          hint: 'Select shop type',
                          onChanged: (value) {
                            setState(() => _selectedShopType = value);
                          },
                        ),
                        SizedBox(height: formSpacing),
                        _StallDropdownBlock(
                          label: 'Time of Day for Stall',
                          value: _selectedStallTime,
                          options: _stallTimes,
                          hint: 'Select stall time',
                          onChanged: (value) {
                            setState(() => _selectedStallTime = value);
                          },
                        ),
                        SizedBox(height: formSpacing),
                        _StallTextInputBlock(
                          label: 'Contact Number',
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: _validateContactNumber,
                        ),
                        SizedBox(height: formSpacing),
                        _StallTextInputBlock(
                          label: 'Email ID',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: mobile ? 24 : 28),
                        SubmitButton(
                          onPressed: _isSubmitting ? null : _submit,
                          isSubmitting: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const RangakshFooter(),
          ],
        ),
      ),
    );
  }
}

class _StallHeroTitle extends StatelessWidget {
  const _StallHeroTitle();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: EdgeInsets.only(top: mobile ? 40 : 64),
      child: Column(
        children: [
          Text(
            'STALL SETUP REQUEST',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: AppColors.textPrimary,
              fontSize: mobile ? 27 : 44,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Register your stall interest for Rangaksh',
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              color: AppColors.textMuted,
              fontSize: mobile ? 16 : 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StallTextInputBlock extends StatelessWidget {
  const _StallTextInputBlock({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: label),
          const SizedBox(height: 14),
          AppTextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _StallDropdownBlock extends StatelessWidget {
  const _StallDropdownBlock({
    required this.label,
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: label),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: value,
            dropdownColor: AppColors.cardBackground,
            iconEnabledColor: AppColors.textPrimary,
            style: GoogleFonts.baloo2(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.inputFill,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.border, width: 1.1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.border, width: 1.4),
              ),
              errorStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            hint: Text(
              hint,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            items: options
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: onChanged,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Please select an option'
                : null,
          ),
        ],
      ),
    );
  }
}
