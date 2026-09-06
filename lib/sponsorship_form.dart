import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'one_act_page.dart';
import 'one_act_submission.dart';
import 'sec_form.dart';

class SponsorshipForm extends StatefulWidget {
  const SponsorshipForm({super.key});

  @override
  State<SponsorshipForm> createState() => _SponsorshipFormState();
}

class _SponsorshipFormState extends State<SponsorshipForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = TextEditingController();
  final _ownerController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _queriesController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedPackage;

  static const _packageOptions = [
    'Supporting Sponsor',
    'Associate Sponsor',
    'Principal Sponsor',
    'Power Sponsor',
  ];

  @override
  void dispose() {
    _businessController.dispose();
    _ownerController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _deliverablesController.dispose();
    _queriesController.dispose();
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
          'formType': 'sponsor',
          'submittedAt': DateTime.now().toIso8601String(),
          'businessName': _businessController.text.trim(),
          'ownerName': _ownerController.text.trim(),
          'contactNumber': _contactController.text.trim(),
          'emailAddress': _emailController.text.trim(),
          'sponsorshipPackage': _selectedPackage ?? '',
          'operationalAddress': _addressController.text.trim(),
          'deliverables': _deliverablesController.text.trim(),
          'queries': _queriesController.text.trim(),
        },
      );

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _showSuccessDialog();
        if (mounted) _clearForm();
      } else {
        _showMessage('Submission failed with status ${response.statusCode}.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not submit the form. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _businessController.clear();
    _ownerController.clear();
    _contactController.clear();
    _emailController.clear();
    _addressController.clear();
    _deliverablesController.clear();
    _queriesController.clear();
    setState(() => _selectedPackage = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
          'Sponsor Form Submitted',
          style: GoogleFonts.baloo2(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your response has been recorded.',
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
            const _SponsorHeroTitle(),
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
                        TextInputBlock(
                          label: 'Name of Business/Shop',
                          controller: _businessController,
                        ),
                        SizedBox(height: formSpacing),
                        TextInputBlock(
                          label: 'Name of Owner',
                          controller: _ownerController,
                        ),
                        SizedBox(height: formSpacing),
                        TwoColumnRowBlock(
                          leftLabel: 'Contact Number',
                          rightLabel: 'E-Mail Address',
                          leftController: _contactController,
                          rightController: _emailController,
                          leftKeyboardType: TextInputType.phone,
                          rightKeyboardType: TextInputType.emailAddress,
                          leftInputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          leftValidator: _validateContactNumber,
                        ),
                        SizedBox(height: formSpacing),
                        _SponsorshipPackageBlock(
                          selectedPackage: _selectedPackage,
                          packageOptions: _packageOptions,
                          onPackageChanged: (value) {
                            setState(() => _selectedPackage = value);
                          },
                        ),
                        SizedBox(height: formSpacing),
                        TextInputBlock(
                          label: 'Operational Address',
                          controller: _addressController,
                        ),
                        SizedBox(height: formSpacing),
                        TextInputBlock(
                          label: 'List your deliverables',
                          controller: _deliverablesController,
                          maxLines: 4,
                        ),
                        SizedBox(height: formSpacing),
                        TextInputBlock(
                          label: 'Any queries',
                          controller: _queriesController,
                          maxLines: 6,
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
            const _SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _SponsorHeroTitle extends StatelessWidget {
  const _SponsorHeroTitle();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: EdgeInsets.only(top: mobile ? 40 : 64),
      child: Column(
        children: [
          Text(
            'SPONSORSHIP APPLICATION',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: AppColors.textPrimary,
              fontSize: mobile ? 27 : 44,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'S I G N  U P  F O R M',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: AppColors.textMuted,
              fontSize: mobile ? 13 : 19,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorshipPackageBlock extends StatelessWidget {
  const _SponsorshipPackageBlock({
    required this.selectedPackage,
    required this.packageOptions,
    required this.onPackageChanged,
  });

  final String? selectedPackage;
  final List<String> packageOptions;
  final ValueChanged<String?> onPackageChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'Choose your Sponsorship Package'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const _SponsorshipMatrixDialog(),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('View Sponsorship Packages'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: .68),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedPackage,
            isExpanded: true,
            dropdownColor: AppColors.cardBackground,
            iconEnabledColor: AppColors.textPrimary,
            style: const TextStyle(
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
            hint: const Text(
              'Select Sponsorship Package',
              style: TextStyle(color: AppColors.textMuted),
            ),
            items: packageOptions
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: onPackageChanged,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Please select a sponsorship package'
                : null,
          ),
        ],
      ),
    );
  }
}

class _SponsorshipMatrixDialog extends StatelessWidget {
  const _SponsorshipMatrixDialog();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final compact = screenSize.width < 700;
    final dialogWidth = compact
        ? screenSize.width - 28
        : (screenSize.width * .88).clamp(760.0, 1180.0);
    final imageWidth = compact
        ? (screenSize.width * 2.45).clamp(860.0, 1180.0)
        : dialogWidth - 36;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 32,
        vertical: compact ? 22 : 36,
      ),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: compact
              ? screenSize.height * .78
              : screenSize.height * .84,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.headerBackground,
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            border: Border.all(color: AppColors.border, width: 1.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 18,
                  compact ? 10 : 14,
                  compact ? 8 : 12,
                  compact ? 8 : 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SPONSORSHIP MATRIX',
                        style: GoogleFonts.montserrat(
                          color: AppColors.textPrimary,
                          fontSize: compact ? 16 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      color: AppColors.textPrimary,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(
                    compact ? 10 : 18,
                    0,
                    compact ? 10 : 18,
                    compact ? 12 : 18,
                  ),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: imageWidth,
                      child: Image.asset(
                        'lib/assets/sponsor-matrix.png',
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SponsorFooter extends StatelessWidget {
  const _SponsorFooter();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Container(
      height: mobile ? 92 : 145,
      width: double.infinity,
      color: const Color(0xFF410F19),
      alignment: Alignment.center,
      child: Image.asset(
        'lib/assets/footer.png',
        width: mobile ? double.infinity : 820,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
