import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';
import 'one_act_submission.dart';
import 'rangaksh_footer.dart';

class ParticipantForm extends StatefulWidget {
  const ParticipantForm({super.key});
  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final _directorName = TextEditingController();
  final _performanceBrief = TextEditingController();
  final _school = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _state = TextEditingController();
  final _pastEvents = TextEditingController();
  final _referral = TextEditingController();
  String? _category;

  @override
  void dispose() {
    for (final controller in [
      _directorName,
      _performanceBrief,
      _school,
      _contact,
      _email,
      _state,
      _pastEvents,
      _referral,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = _category;
    if (category == null) return;

    final registration = OneActRegistration(
      directorName: _directorName.text.trim(),
      category: category,
      amount: _TalentHuntCategory.amountFor(category),
      school: _school.text.trim(),
      contactNumber: _contact.text.trim(),
      emailAddress: _email.text.trim(),
      state: _state.text.trim(),
      performanceBrief: _performanceBrief.text.trim(),
      pastEvents: _pastEvents.text.trim(),
      teamMembers: category,
      referralName: _referral.text.trim(),
    );

    Navigator.of(
      context,
    ).pushNamed('/paydesk?prod=one-act', arguments: registration);
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
                          'TALENT HUNT',
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
                          'APPLICATION FORM',
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
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/talent-hunt'),
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
                              'Click Here to View Details of the Talent Hunt Competition',
                              style: GoogleFonts.montserrat(
                                fontSize: (mobile ? 10 : 12) * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (mobile ? 58 : 72) * scale),
                        _Field(
                          label: 'Individual’s Name / Team Name',
                          controller: _directorName,
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Performance Brief',
                          helper:
                              'Give a short explanation of what you’d like to perform. All art forms are welcome.',
                          controller: _performanceBrief,
                          maxLines: 6,
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(
                          label: 'Previous Experiences (if any)',
                          controller: _pastEvents,
                          maxLines: 3,
                          validator: (_) => null,
                        ),
                        SizedBox(height: 28 * scale),
                        _CategoryField(
                          value: _category,
                          onChanged: (value) =>
                              setState(() => _category = value),
                        ),
                        SizedBox(height: 28 * scale),
                        _Field(label: 'School', controller: _school),
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
            const RangakshFooter(),
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
    this.helper,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String? helper;
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
        if (helper != null) ...[
          SizedBox(height: 4 * scale),
          Text(
            helper!,
            style: GoogleFonts.montserrat(
              color: _ParticipantColors.cream.withValues(alpha: .58),
              fontSize: 11 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            errorStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 12 * scale,
            ),
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
          'Number of team members',
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12 * scale),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: _ParticipantColors.field,
          style: GoogleFonts.montserrat(
            color: _ParticipantColors.cream,
            fontSize: 16 * scale,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _ParticipantColors.field,
            errorStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 12 * scale,
            ),
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
          items: _TalentHuntCategory.options
              .map(
                (item) => DropdownMenuItem(
                  value: item.label,
                  child: Text(
                    item.menuLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (context) => _TalentHuntCategory.options
              .map(
                (item) => Text(
                  item.menuLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Please select team size' : null,
        ),
      ],
    );
  }
}

class _TalentHuntCategory {
  const _TalentHuntCategory({
    required this.label,
    required this.menuLabel,
    required this.amount,
  });

  final String label;
  final String menuLabel;
  final int amount;

  static const options = [
    _TalentHuntCategory(
      label: 'Solo/Duet Performance',
      menuLabel: 'Solo/Duet Performance - ₹250',
      amount: 250,
    ),
    _TalentHuntCategory(
      label: '3-5 Participant Team Performance',
      menuLabel: '3-5 Participant Team Performance - ₹400',
      amount: 400,
    ),
    _TalentHuntCategory(
      label: '5+ Participant Team Performance',
      menuLabel: '5+ Participant Team Performance - ₹800',
      amount: 800,
    ),
  ];

  static int amountFor(String label) => options
      .firstWhere(
        (option) => option.label == label,
        orElse: () => throw ArgumentError('Unknown Talent Hunt category'),
      )
      .amount;
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

class _ParticipantColors {
  static const field = Color(0xFF440F1D);
  static const cream = Color(0xFFFFF3DE);
  static const gold = Color(0xFFE1C28B);
}

double _formScale(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 1100 ? 1.5 : 1;
