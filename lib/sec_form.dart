import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SecretariatApplicationFormScreen extends StatefulWidget {
  const SecretariatApplicationFormScreen({super.key});

  @override
  State<SecretariatApplicationFormScreen> createState() =>
      _SecretariatApplicationFormScreenState();
}

class _SecretariatApplicationFormScreenState
    extends State<SecretariatApplicationFormScreen> {
  static const String _googleAppsScriptUrl =
      'https://script.google.com/macros/s/AKfycbyyMgKYBHSnr5-Ct45EZhaWUiOQPRCKQ73AfmrqY5qQa9nE8gVLmM3pk30hlvB0jq4U/exec';

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsetsController = TextEditingController();
  final _timeController = TextEditingController();
  final _referralController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedClass;
  String _selectedDepartment = 'Marketing Department';
  static const List<String> _classOptions = [
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  static const List<DepartmentOption> _departments = [
    DepartmentOption(
      title: 'Marketing Department',
      description:
          'Connect with colleges, communities, and audiences to bring them to the fest.',
    ),
    DepartmentOption(
      title: 'Content Department',
      description:
          'Create the words, visuals, and stories that shape the fest’s identity.',
    ),
    DepartmentOption(
      title: 'Logistics Department',
      description:
          'Handle infrastructure, arrangements, supplies, and everything needed on-ground.',
    ),
    DepartmentOption(
      title: 'Technical Department',
      description:
          'Work on graphics, design, IT, and the digital side of the fest.',
    ),
    DepartmentOption(
      title: 'Delegate Affairs Department',
      description:
          'Coordinate with participants, address their needs, and ensure a smooth experience.',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _skillsetsController.dispose();
    _timeController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Map<String, String> _buildPayload() {
    return {
      'submittedAt': DateTime.now().toIso8601String(),
      'name': _nameController.text.trim(),
      'studentClass': _selectedClass ?? '',
      'school': _schoolController.text.trim(),
      'contactNumber': _contactController.text.trim(),
      'emailAddress': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'pastExperience': _experienceController.text.trim(),
      'skillsets': _skillsetsController.text.trim(),
      'timeContribution': _timeController.text.trim(),
      'preferredDepartment': _selectedDepartment,
      'referralName': _referralController.text.trim(),
    };
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _schoolController.clear();
    _contactController.clear();
    _emailController.clear();
    _addressController.clear();
    _experienceController.clear();
    _skillsetsController.clear();
    _timeController.clear();
    _referralController.clear();
    setState(() {
      _selectedClass = null;
      _selectedDepartment = 'Marketing Department';
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_googleAppsScriptUrl == 'YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set your deployed Google Apps Script web app URL before submitting.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        body: _buildPayload(),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Submission failed with status ${response.statusCode}.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not submit the form. Check the Apps Script URL and deployment permissions.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateContactNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final horizontalPadding = isMobile
        ? 12.0
        : isTablet
        ? 20.0
        : width >= 1200
        ? 40.0
        : 28.0;
    final formSpacing = isMobile
        ? 30.0
        : isTablet
        ? 16.0
        : 50.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const FormHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isMobile ? 16 : 24,
                  horizontalPadding,
                  isMobile ? 28 : 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextInputBlock(
                            label: 'Name',
                            controller: _nameController,
                          ),
                          SizedBox(height: formSpacing),
                          ClassSchoolRowBlock(
                            selectedClass: _selectedClass,
                            classOptions: _classOptions,
                            onClassChanged: (value) {
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                            schoolController: _schoolController,
                          ),
                          SizedBox(height: formSpacing),
                          TwoColumnRowBlock(
                            leftLabel: 'Contact Number',
                            rightLabel: 'E-Mail Address',
                            leftController: _contactController,
                            rightController: _emailController,
                            leftKeyboardType: TextInputType.phone,
                            leftInputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            leftValidator: _validateContactNumber,
                            rightKeyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: formSpacing),
                          TextInputBlock(
                            label: 'Address',
                            controller: _addressController,
                            maxLines: 3,
                          ),
                          SizedBox(height: formSpacing),
                          TextInputBlock(
                            label: 'Past Experience (If Any)',
                            controller: _experienceController,
                            maxLines: 4,
                          ),
                          SizedBox(height: formSpacing),
                          TextInputBlock(
                            label: 'A Short Description of your Skillsets',
                            controller: _skillsetsController,
                            maxLines: 4,
                          ),
                          SizedBox(height: formSpacing),
                          TextInputBlock(
                            label:
                                'How much time can you contribute to Rangaksh?',
                            controller: _timeController,
                            maxLines: 3,
                          ),
                          SizedBox(height: formSpacing),
                          PreferredDepartmentBlock(
                            options: _departments,
                            selectedValue: _selectedDepartment,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedDepartment = value;
                              });
                            },
                          ),
                          SizedBox(height: formSpacing),
                          TextInputBlock(
                            label: 'Referral Name from Team Rangaksh',
                            controller: _referralController,
                          ),
                          SizedBox(height: width < 600 ? 24 : 28),
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
            ],
          ),
        ),
      ),
    );
  }
}

class FormHeader extends StatelessWidget {
  const FormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isCompact = width < 900;
    final outerPadding = isMobile
        ? 8.0
        : width >= 1200
        ? 14.0
        : width >= 900
        ? 12.0
        : 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(outerPadding, outerPadding, outerPadding, 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.headerBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF5A2328), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x77000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 12
                : width >= 1200
                ? 18
                : width >= 900
                ? 16
                : 14,
            vertical: isMobile
                ? 10
                : width < 900
                ? 14
                : 16,
          ),
          child: isCompact
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderBrand(),
                    SizedBox(height: 14),
                    _HeaderTitleBlock(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.left,
                      isCompact: true,
                    ),
                  ],
                )
              : const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _HeaderBrand(),
                    Spacer(),
                    _HeaderTitleBlock(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final logoWidth = isMobile
        ? 32.0
        : width < 900
        ? 56.0
        : 50.0;
    final logoHeight = isMobile
        ? 36.0
        : width < 900
        ? 62.0
        : 60.0;
    final fontSize = isMobile
        ? 13.5
        : width < 900
        ? 15.0
        : 17.0;
    final letterSpacing = isMobile
        ? 2.4
        : width < 900
        ? 3.4
        : 4.8;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/assets/logo.png',
          width: logoWidth,
          height: logoHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Flexible(
          child: Text(
            'ANANTA ORGANIZERS',
            style: GoogleFonts.montserrat(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: letterSpacing,
              height: 1,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _HeaderTitleBlock extends StatelessWidget {
  const _HeaderTitleBlock({
    required this.crossAxisAlignment,
    this.textAlign = TextAlign.left,
    this.isCompact = false,
  });

  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleFontSize = isCompact ? (width < 600 ? 15.5 : 17.0) : 18.0;
    final titleSpacing = isCompact ? (width < 600 ? 1.5 : 2.6) : 4.2;
    final subtitleFontSize = width < 600
        ? 11.0
        : isCompact
        ? 11.8
        : 12.0;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          'SECRETARIAT APPLICATION FORM',
          textAlign: textAlign,
          style: GoogleFonts.montserrat(
            color: AppColors.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: titleSpacing,
            height: 1.05,
          ),
          maxLines: isCompact ? 2 : 1,
        ),
        SizedBox(height: width < 600 ? 4 : 6),
        SizedBox(
          width: isCompact ? double.infinity : 470,
          child: Text(
            'Join us behind the curtain and be a part of Rangaksh’s Organising team',
            textAlign: textAlign,
            style: GoogleFonts.montserrat(
              color: AppColors.textMuted,
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: width < 600 ? 0.05 : 0.15,
              height: 1.2,
            ),
            maxLines: isCompact ? 3 : 2,
          ),
        ),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    this.radius = 15,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.88),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x61000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TextInputBlock extends StatelessWidget {
  const TextInputBlock({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 16 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: label),
          const SizedBox(height: 14),
          AppTextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

class ClassSchoolRowBlock extends StatelessWidget {
  const ClassSchoolRowBlock({
    super.key,
    required this.selectedClass,
    required this.classOptions,
    required this.onClassChanged,
    required this.schoolController,
  });

  final String? selectedClass;
  final List<String> classOptions;
  final ValueChanged<String?> onClassChanged;
  final TextEditingController schoolController;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;
    final compact = width < 600;

    final classField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionLabel(label: 'Class'),
        const SizedBox(height: 14),
        AppDropdownField(
          value: selectedClass,
          items: classOptions,
          onChanged: onClassChanged,
        ),
      ],
    );

    final schoolField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionLabel(label: 'School'),
        const SizedBox(height: 14),
        AppTextField(controller: schoolController),
      ],
    );

    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 16 : 22,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                classField,
                SizedBox(height: compact ? 16 : 18),
                schoolField,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: classField),
                const SizedBox(width: 22),
                Expanded(child: schoolField),
              ],
            ),
    );
  }
}

class TwoColumnRowBlock extends StatelessWidget {
  const TwoColumnRowBlock({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftController,
    required this.rightController,
    this.leftKeyboardType,
    this.rightKeyboardType,
    this.leftInputFormatters,
    this.rightInputFormatters,
    this.leftValidator,
    this.rightValidator,
  });

  final String leftLabel;
  final String rightLabel;
  final TextEditingController leftController;
  final TextEditingController rightController;
  final TextInputType? leftKeyboardType;
  final TextInputType? rightKeyboardType;
  final List<TextInputFormatter>? leftInputFormatters;
  final List<TextInputFormatter>? rightInputFormatters;
  final String? Function(String?)? leftValidator;
  final String? Function(String?)? rightValidator;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;
    final compact = width < 600;

    Widget buildField({
      required String label,
      required TextEditingController controller,
      required TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
      );
    }

    final leftField = buildField(
      label: leftLabel,
      controller: leftController,
      keyboardType: leftKeyboardType,
      inputFormatters: leftInputFormatters,
      validator: leftValidator,
    );

    final rightField = buildField(
      label: rightLabel,
      controller: rightController,
      keyboardType: rightKeyboardType,
      inputFormatters: rightInputFormatters,
      validator: rightValidator,
    );

    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 16 : 22,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                leftField,
                SizedBox(height: compact ? 16 : 18),
                rightField,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: leftField),
                const SizedBox(width: 22),
                Expanded(child: rightField),
              ],
            ),
    );
  }
}

class PreferredDepartmentBlock extends StatelessWidget {
  const PreferredDepartmentBlock({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<DepartmentOption> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return SectionCard(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        compact ? 18 : 24,
        compact ? 14 : 20,
        compact ? 10 : 16,
      ),
      radius: compact ? 14 : 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 5),
            child: SectionLabel(
              label: 'Preferred Department',
              fontSize: compact ? 16 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: compact ? 14 : 18),
          _DepartmentOptionsList(
            options: options,
            selectedValue: selectedValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DepartmentOptionsList extends StatelessWidget {
  const _DepartmentOptionsList({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<DepartmentOption> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final itemSpacing = width < 600
        ? 16.0
        : width < 900
        ? 18.0
        : 22.0;
    return Column(
      children: options
          .map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: itemSpacing),
              child: _DepartmentOptionTile(
                option: option,
                selected: selectedValue == option.title,
                onTap: () => onChanged(option.title),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DepartmentOptionTile extends StatelessWidget {
  const _DepartmentOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DepartmentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: compact ? 2 : 3),
              child: _RadioMarker(selected: selected),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 14.5 : 16,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: compact ? 3 : 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      height: compact ? 1.24 : 1.18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioMarker extends StatelessWidget {
  const _RadioMarker({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      width: compact ? 24 : 28,
      height: compact ? 24 : 28,
      padding: EdgeInsets.all(compact ? 4 : 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textPrimary,
          width: compact ? 1.2 : 1.4,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.textPrimary : Colors.transparent,
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.isSubmitting,
  });

  final Future<void> Function()? onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: compact ? double.infinity : 200,
        height: compact ? 58 : 68,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: GoogleFonts.baloo2(
              fontSize: compact ? 14 : 24,
              fontWeight: FontWeight.w700,
              letterSpacing: compact ? 2.8 : 4.4,
            ),
          ),
          child: isSubmitting
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary,
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('SUBMIT'),
                      SizedBox(width: compact ? 8 : 12),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: compact ? 28 : 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
  });

  final String label;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: compact ? fontSize - 2 : fontSize,
        fontWeight: fontWeight,
        letterSpacing: compact ? 0.2 : 0.4,
        height: 1.2,
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: compact ? 14 : 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            if (keyboardType == TextInputType.emailAddress) {
              final email = value.trim();
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 18,
          vertical: maxLines > 1 ? (compact ? 16 : 18) : (compact ? 14 : 16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.72),
            width: 1.1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: AppColors.border, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFFE0A8A8), width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFFFFC4C4), width: 1.4),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFF7D9D9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.cardBackground,
      iconEnabledColor: AppColors.textPrimary,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: compact ? 14 : 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 18,
          vertical: compact ? 14 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.72),
            width: 1.1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: AppColors.border, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFFE0A8A8), width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFFFFC4C4), width: 1.4),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFF7D9D9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      hint: Text(
        'Select Class',
        style: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.9),
          fontSize: compact ? 14 : 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }
}

class DepartmentOption {
  const DepartmentOption({required this.title, required this.description});

  final String title;
  final String description;
}

class AppColors {
  static const Color pageBackground = Color(0xFF5A1725);
  static const Color headerBackground = Color(0xFF530C1F);
  static const Color cardBackground = Color(0xFF5A1725);
  static const Color buttonBackground = Color(0xFF220C0F);
  static const Color border = Color(0xFFE1C28B);
  static const Color textPrimary = Color(0xFFFFF3DE);
  static const Color textMuted = Color(0xFFE7D6B8);
  static const Color inputFill = Color(0x2EFFF3DD);
}
