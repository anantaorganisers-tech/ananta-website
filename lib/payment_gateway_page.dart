import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'one_act_page.dart';
import 'one_act_submission.dart';
import 'visitor_pass_submission.dart';

enum PaydeskProduct {
  oneAct(code: 'one-act', heading: 'ONE ACT COMPETITION', amount: 800),
  djGarba(code: 'dj-garba', heading: 'DJ & GARBA NIGHT', amount: 150);

  const PaydeskProduct({
    required this.code,
    required this.heading,
    required this.amount,
  });

  final String code;
  final String heading;
  final int amount;

  static PaydeskProduct fromCode(String? code) => values.firstWhere(
    (product) => product.code == code,
    orElse: () => PaydeskProduct.oneAct,
  );
}

class PaydeskPage extends StatefulWidget {
  const PaydeskPage({
    super.key,
    required this.product,
    this.registration,
    this.visitor,
  });

  final PaydeskProduct product;
  final OneActRegistration? registration;
  final VisitorPassRegistrant? visitor;

  @override
  State<PaydeskPage> createState() => _PaydeskPageState();
}

class _PaydeskPageState extends State<PaydeskPage> {
  final _formKey = GlobalKey<FormState>();
  final _upiId = TextEditingController();
  final _transactionId = TextEditingController();
  bool _isSubmitting = false;
  bool _paymentRecorded = false;

  int get _payableAmount => widget.visitor?.amount ?? widget.product.amount;
  String get _checkoutHeading =>
      widget.visitor?.packageName ?? widget.product.heading;

  @override
  void dispose() {
    _upiId.dispose();
    _transactionId.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.product == PaydeskProduct.oneAct &&
        widget.registration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the One Act registration form first.'),
        ),
      );
      return;
    }
    if (widget.product == PaydeskProduct.djGarba && widget.visitor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your DJ & Garba pass details first.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (widget.product == PaydeskProduct.oneAct) {
        await OneActSubmissionService.submitPayment(
          registration: widget.registration!,
          upiId: _upiId.text.trim(),
          transactionId: _transactionId.text.trim(),
        );
        if (!mounted) return;
        setState(() {
          _paymentRecorded = true;
          _isSubmitting = false;
        });
        await _showOneActConfirmation();
      } else {
        final passId = _generatePassId();
        final qrImage = await _createPassQrImage(passId);
        final pass = await VisitorPassSubmissionService.submitPayment(
          registrant: widget.visitor!,
          upiId: _upiId.text.trim(),
          transactionId: _transactionId.text.trim(),
          passId: passId,
          qrImageBytes: qrImage,
        );
        if (!mounted) return;
        setState(() {
          _paymentRecorded = true;
          _isSubmitting = false;
        });
        await _showVisitorPass(pass.passId);
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/rangaksh', (route) => false);
      }
    } on OneActSubmissionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not record payment: ${error.message}')),
      );
    } on VisitorPassSubmissionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create your pass: ${error.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not record payment. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted && _isSubmitting) setState(() => _isSubmitting = false);
    }
  }

  Future<Uint8List> _createPassQrImage(String passId) async {
    final imageData = await QrPainter(
      data: passId,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      gapless: true,
    ).toImageData(720, format: ui.ImageByteFormat.png);
    if (imageData == null) {
      throw const VisitorPassSubmissionException(
        'Could not generate the pass QR code.',
      );
    }
    return imageData.buffer.asUint8List();
  }

  String _generatePassId() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final suffix = List.generate(
      12,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return 'DJG-$suffix';
  }

  Future<void> _showOneActConfirmation() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _PaymentColors.field,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _PaymentColors.gold),
      ),
      title: Text(
        'Payment Details Submitted',
        style: GoogleFonts.montserrat(
          color: _PaymentColors.cream,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Your One Act registration has been recorded and is pending approval.',
        style: GoogleFonts.montserrat(
          color: _PaymentColors.cream.withValues(alpha: .84),
        ),
      ),
      actions: [_dialogOkButton(context)],
    ),
  );

  Future<void> _showVisitorPass(String passId) => showDialog<void>(
    context: context,
    builder: (context) {
      final mobile = MediaQuery.sizeOf(context).width < 700;
      final qrSize = mobile ? 190.0 : 230.0;
      return Dialog(
        backgroundColor: _PaymentColors.field,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _PaymentColors.gold),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mobile ? 330 : 390),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your DJ & Garba Pass',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: _PaymentColors.cream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: SizedBox.square(
                    dimension: qrSize,
                    child: QrImageView(
                      data: passId,
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  passId,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: _PaymentColors.gold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Take a screenshot of this pass. Present this QR code at entry.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: _PaymentColors.cream.withValues(alpha: .84),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _dialogOkButton(context),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _dialogOkButton(BuildContext context) => TextButton(
    onPressed: () => Navigator.pop(context),
    style: TextButton.styleFrom(foregroundColor: Colors.white),
    child: const Text('OK'),
  );

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final scale = _paymentScale(context);

    return Scaffold(
      appBar: const CompetitionAppBar(),
      bottomSheet: _isSubmitting
          ? const LinearProgressIndicator(
              minHeight: 4,
              color: _PaymentColors.gold,
              backgroundColor: _PaymentColors.field,
            )
          : null,
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
                          _checkoutHeading,
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
                        _QrPanel(amount: _payableAmount, scale: scale),
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
                              onPressed: _isSubmitting || _paymentRecorded
                                  ? null
                                  : _checkout,
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
                                _isSubmitting
                                    ? 'SAVING...'
                                    : _paymentRecorded
                                    ? 'RECORDED'
                                    : 'CHECKOUT',
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
  const _QrPanel({required this.amount, required this.scale});

  final int amount;
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
            'Amount to be paid: ₹$amount',
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
