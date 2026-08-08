import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secretariat Application Form',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: _AppColors.pageBackground,
      ),
      home: const SecretariatApplicationFormScreen(),
    );
  }
}

class SecretariatApplicationFormScreen extends StatefulWidget {
  const SecretariatApplicationFormScreen({super.key});

  @override
  State<SecretariatApplicationFormScreen> createState() =>
      _SecretariatApplicationFormScreenState();
}

class _SecretariatApplicationFormScreenState
    extends State<SecretariatApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsetsController = TextEditingController();
  final _timeController = TextEditingController();
  final _referralController = TextEditingController();

  String _selectedDepartment = 'Marketing Department';

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
    _classController.dispose();
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

  void _submit() {
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200
        ? 40.0
        : width >= 900
        ? 28.0
        : 16.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const FormHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  40,
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
                          const SizedBox(height: 18),
                          TwoColumnRowBlock(
                            leftLabel: 'Class',
                            rightLabel: 'School',
                            leftController: _classController,
                            rightController: _schoolController,
                          ),
                          const SizedBox(height: 18),
                          TwoColumnRowBlock(
                            leftLabel: 'Contact Number',
                            rightLabel: 'E-Mail Address',
                            leftController: _contactController,
                            rightController: _emailController,
                            leftKeyboardType: TextInputType.phone,
                            rightKeyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),
                          TextInputBlock(
                            label: 'Address',
                            controller: _addressController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 18),
                          TextInputBlock(
                            label: 'Past Experience (If Any)',
                            controller: _experienceController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 18),
                          TextInputBlock(
                            label: 'A Short Description of your Skillsets',
                            controller: _skillsetsController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 18),
                          TextInputBlock(
                            label:
                                'How much time can you contribute to Rangaksh?',
                            controller: _timeController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 18),
                          TextInputBlock(
                            label: 'Referral name from Team Rangaksh',
                            controller: _referralController,
                          ),
                          const SizedBox(height: 28),
                          SubmitButton(onPressed: _submit),
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
    final isCompact = width < 760;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _AppColors.headerBackground,
        boxShadow: [
          BoxShadow(
            color: Color(0x52000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width >= 1200
              ? 42
              : width >= 900
              ? 28
              : 16,
          vertical: 22,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: isCompact
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderBrand(),
                      SizedBox(height: 22),
                      _HeaderTitleBlock(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _HeaderBrand()),
                      SizedBox(width: 24),
                      Expanded(
                        child: _HeaderTitleBlock(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 82,
          height: 82,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0x12FFF4D4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _AppColors.border.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset('lib/assets/logo.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 16),
        const Flexible(
          child: Text(
            'ANANTA ORGANIZERS',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1.15,
            ),
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
  });

  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: const [
        Text(
          'SECRETARIAT APPLICATION FORM',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            height: 1.1,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 420,
          child: Text(
            'Join us behind the curtain and be a part of Rangaksh’s Organising team',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _AppColors.textMuted,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.5,
            ),
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
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _AppColors.border, width: 1.3),
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
    return SectionCard(
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

class TwoColumnRowBlock extends StatelessWidget {
  const TwoColumnRowBlock({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftController,
    required this.rightController,
    this.leftKeyboardType,
    this.rightKeyboardType,
  });

  final String leftLabel;
  final String rightLabel;
  final TextEditingController leftController;
  final TextEditingController rightController;
  final TextInputType? leftKeyboardType;
  final TextInputType? rightKeyboardType;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 720;

    final fields = [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label: leftLabel),
            const SizedBox(height: 14),
            AppTextField(
              controller: leftController,
              keyboardType: leftKeyboardType,
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label: rightLabel),
            const SizedBox(height: 14),
            AppTextField(
              controller: rightController,
              keyboardType: rightKeyboardType,
            ),
          ],
        ),
      ),
    ];

    return SectionCard(
      child: stacked
          ? Column(children: [fields[0], const SizedBox(height: 18), fields[1]])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [fields[0], const SizedBox(width: 22), fields[1]],
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
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 820;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(label: 'Preferred Department'),
                const SizedBox(height: 18),
                const _DepartmentDecoration(),
                const SizedBox(height: 18),
                _DepartmentOptionsList(
                  options: options,
                  selectedValue: selectedValue,
                  onChanged: onChanged,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(label: 'Preferred Department'),
                      SizedBox(height: 22),
                      _DepartmentDecoration(),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 7,
                  child: _DepartmentOptionsList(
                    options: options,
                    selectedValue: selectedValue,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DepartmentDecoration extends StatelessWidget {
  const _DepartmentDecoration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x1EFFF4D4), Color(0x08FFF4D4)],
          ),
          border: Border.all(
            color: _AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 26,
              top: 24,
              child: Container(
                width: 138,
                height: 138,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x20E1C28B),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 42,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xB7E1C28B),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 34,
              right: 34,
              bottom: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Container(
                    width: index == 2 ? 22 : 16,
                    height: index == 2 ? 22 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 2
                          ? const Color(0xCCFFF4D4)
                          : const Color(0x5CFFF4D4),
                      border: Border.all(color: _AppColors.border, width: 1),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Opacity(
                  opacity: 0.92,
                  child: Image.asset(
                    'lib/assets/logo.png',
                    width: 132,
                    height: 132,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Column(
      children: options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0x22FFF4D4) : const Color(0x12FFF4D4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _AppColors.border
                : _AppColors.border.withValues(alpha: 0.45),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _RadioMarker(selected: selected),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      color: _AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: _AppColors.textMuted,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
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
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _AppColors.border, width: 1.5),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? _AppColors.border : Colors.transparent,
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 58,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: _AppColors.buttonBackground,
            foregroundColor: _AppColors.textPrimary,
            side: const BorderSide(color: _AppColors.border, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          child: const Text('SUBMIT'),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
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
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: _AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: _AppColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: maxLines > 1 ? 18 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: _AppColors.border.withValues(alpha: 0.72),
            width: 1.1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: _AppColors.border, width: 1.4),
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

class DepartmentOption {
  const DepartmentOption({required this.title, required this.description});

  final String title;
  final String description;
}

class _AppColors {
  static const Color pageBackground = Color(0xFF49161A);
  static const Color headerBackground = Color(0xFF341013);
  static const Color cardBackground = Color(0xFF5A1D21);
  static const Color buttonBackground = Color(0xFF220C0F);
  static const Color border = Color(0xFFE1C28B);
  static const Color textPrimary = Color(0xFFFFF3DE);
  static const Color textMuted = Color(0xFFE7D6B8);
  static const Color inputFill = Color(0x2EFFF3DD);
}
