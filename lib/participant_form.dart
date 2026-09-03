import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';
import 'web_navigation.dart';

class ParticipantForm extends StatefulWidget {
  const ParticipantForm({super.key});
  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final _directorName = TextEditingController();
  final _school = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _state = TextEditingController();
  final _pastEvents = TextEditingController();
  final _brochure = TextEditingController();
  final _members = TextEditingController();
  final _referral = TextEditingController();
  String? _category;

  @override
  void dispose() {
    for (final controller in [
      _directorName,
      _school,
      _contact,
      _email,
      _state,
      _pastEvents,
      _brochure,
      _members,
      _referral,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _ParticipantColors.field,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _ParticipantColors.gold),
        ),
        title: Text(
          'Registration details saved',
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your team registration is ready for the payment step.',
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream.withValues(alpha: .82),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final scale = _formScale(context);
    return Scaffold(
      appBar: const CompetitionAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 22 : 42 * scale,
                mobile ? 60 : 84 * scale,
                mobile ? 22 : 42 * scale,
                mobile ? 84 : 120 * scale,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640 * scale),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ONE ACT COMPETITION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: _ParticipantColors.cream,
                            fontSize: (mobile ? 27 : 34) * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          'SIGN UP FORM',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: _ParticipantColors.cream.withValues(
                              alpha: .8,
                            ),
                            fontSize: (mobile ? 11 : 13) * scale,
                          ),
                        ),
                        SizedBox(height: 24 * scale),
                        Align(
                          alignment: Alignment.center,
                          child: OutlinedButton.icon(
                            onPressed: () => openRouteInNewTab('/one-act'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _ParticipantColors.cream,
                              side: const BorderSide(color: Color(0xFF9A7177)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: Icon(
                              Icons.north_east_rounded,
                              size: 18 * scale,
                            ),
                            label: Text(
                              'Click Here to View Details of the One Act Competition',
                              style: GoogleFonts.montserrat(
                                fontSize: (mobile ? 10 : 12) * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (mobile ? 58 : 72) * scale),
                        _Field(
                          label: 'Team Director Name',
                          controller: _directorName,
                        ),
                        SizedBox(height: 28 * scale),
                        _ResponsiveFieldRow(
                          left: _CategoryField(
                            value: _category,
                            onChanged: (value) =>
                                setState(() => _category = value),
                          ),
                          right: _Field(label: 'School', controller: _school),
                        ),
                        SizedBox(height: 28 * scale),
                        _ResponsiveFieldRow(
                          left: _Field(
                            label: 'Contact Number',
                            controller: _contact,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) =>
                                RegExp(r'^\d{10}$').hasMatch(value ?? '')
                                ? null
                                : 'Enter a valid 10-digit number',
                          ),
                          right: _Field(
                            label: 'E-Mail Address',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(value ?? '')
                                ? null
                                : 'Enter a valid email address',
                          ),
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(label: 'State', controller: _state),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Past Events Attended (if any)',
                          controller: _pastEvents,
                          maxLines: 3,
                          validator: (_) => null,
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Brochure of your Play (PDF)',
                          controller: _brochure,
                          maxLines: 5,
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Number of team members',
                          controller: _members,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            final count = int.tryParse(value ?? '');
                            return count != null && count >= 8 && count <= 10
                                ? null
                                : 'Enter a number between 8 and 10';
                          },
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Referral name from Team Rangaksh',
                          controller: _referral,
                          validator: (_) => null,
                        ),
                        SizedBox(height: (mobile ? 50 : 62) * scale),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: (mobile ? 230 : 290) * scale,
                            height: 58 * scale,
                            child: OutlinedButton(
                              onPressed: _submit,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFF220C0F),
                                foregroundColor: _ParticipantColors.cream,
                                side: const BorderSide(
                                  color: _ParticipantColors.gold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Text(
                                'SUBMIT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const _ParticipantFooter(),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    final scale = _formScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12 * scale),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator:
              validator ??
              (value) => value == null || value.trim().isEmpty
                  ? 'This field is required'
                  : null,
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _ParticipantColors.field,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 15 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8D4B55)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _ParticipantColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0A8A8)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0A8A8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scale = _formScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12 * scale),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: _ParticipantColors.field,
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _ParticipantColors.field,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 15 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8D4B55)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _ParticipantColors.gold),
            ),
          ),
          items: const ['School Team', 'College Team', 'Independent Team']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Please select a category' : null,
        ),
      ],
    );
  }
}

class _ResponsiveFieldRow extends StatelessWidget {
  const _ResponsiveFieldRow({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < 520
        ? Column(children: [left, const SizedBox(height: 28), right])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              SizedBox(width: 20 * _formScale(context)),
              Expanded(child: right),
            ],
          ),
  );
}

class _ParticipantFooter extends StatelessWidget {
  const _ParticipantFooter();
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Container(
      color: const Color(0xFF410F19),
      height: mobile ? 92 : 145,
      alignment: Alignment.center,
      child: Image.asset(
        'lib/assets/footer.png',
        width: mobile ? double.infinity : 820,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ParticipantColors {
  static const field = Color(0xFF440F1D);
  static const cream = Color(0xFFFFF3DE);
  static const gold = Color(0xFFE1C28B);
}

double _formScale(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 1100 ? 1.5 : 1;
