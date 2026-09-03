import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';

class PaymentGatewayPage extends StatefulWidget {
  const PaymentGatewayPage({super.key});

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final _formKey = GlobalKey<FormState>();
  final _upiId = TextEditingController();
  final _transactionId = TextEditingController();

  @override
  void dispose() {
    _upiId.dispose();
    _transactionId.dispose();
    super.dispose();
  }

  void _checkout() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment details recorded.')));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final scale = _paymentScale(context);

    return Scaffold(
      appBar: const CompetitionAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: _PaymentColors.page,
              padding: EdgeInsets.fromLTRB(
                mobile ? 22 : 42 * scale,
                mobile ? 48 : 70 * scale,
                mobile ? 22 : 42 * scale,
                mobile ? 82 : 118 * scale,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 460 * scale),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ONE ACT COMPETITION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: _PaymentColors.cream,
                            fontSize: (mobile ? 27 : 34) * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          'CHECKOUT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: _PaymentColors.cream.withValues(alpha: .8),
                            fontSize: (mobile ? 11 : 13) * scale,
                            letterSpacing: 2.2,
                          ),
                        ),
                        SizedBox(height: (mobile ? 44 : 58) * scale),
                        _QrPanel(scale: scale),
                        SizedBox(height: 34 * scale),
                        _PaymentField(
                          label: 'Enter UPI ID',
                          controller: _upiId,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            return trimmed.contains('@') && trimmed.length >= 5
                                ? null
                                : 'Enter a valid UPI ID';
                          },
                        ),
                        SizedBox(height: 24 * scale),
                        _PaymentField(
                          label: 'Enter Transaction ID',
                          controller: _transactionId,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_-]'),
                            ),
                          ],
                        ),
                        SizedBox(height: (mobile ? 46 : 62) * scale),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: (mobile ? 230 : 250) * scale,
                            height: 54 * scale,
                            child: OutlinedButton(
                              onPressed: _checkout,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFF201713),
                                foregroundColor: _PaymentColors.cream,
                                side: const BorderSide(
                                  color: _PaymentColors.gold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: Text(
                                'CHECKOUT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 6,
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
            const _PaymentFooter(),
          ],
        ),
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 306 * scale,
      padding: EdgeInsets.fromLTRB(
        28 * scale,
        24 * scale,
        28 * scale,
        20 * scale,
      ),
      decoration: BoxDecoration(
        color: _PaymentColors.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF823A46)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan the UPI QR Code to finish the transaction',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: _PaymentColors.cream,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14 * scale),
          Image.asset(
            'lib/assets/paydesk_qr.png',
            width: 170 * scale,
            height: 170 * scale,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: 12 * scale),
          Text(
            'Amount to be paid: ₹800',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: _PaymentColors.cream,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: _PaymentColors.cream,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
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
    final scale = _paymentScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: _PaymentColors.cream,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10 * scale),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator:
              validator ??
              (value) => value == null || value.trim().isEmpty
                  ? 'This field is required'
                  : null,
          style: GoogleFonts.montserrat(
            color: _PaymentColors.cream,
            fontSize: 14 * scale,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _PaymentColors.field,
            errorStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 11 * scale,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 13 * scale,
              vertical: 12 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFF873C48)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: _PaymentColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFE0A8A8)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFE0A8A8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentFooter extends StatelessWidget {
  const _PaymentFooter();

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
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _PaymentColors {
  static const page = Color(0xFF5A061F);
  static const field = Color(0xFF581626);
  static const cream = Color(0xFFFFF3DE);
  static const gold = Color(0xFFE1C28B);
}

double _paymentScale(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 1100 ? 1.5 : 1;
