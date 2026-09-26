import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RangakshFooter extends StatelessWidget {
  const RangakshFooter({super.key});

  static const _cream = Color(0xFFFFF3DE);

  void _goTo(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final footerHeight = mobile ? 96.0 : 230.0;
    return Container(
      color: const Color(0xFF410F19),
      width: double.infinity,
      height: footerHeight,
      alignment: Alignment.center,
      child: SizedBox(
        width: mobile ? width : 1320,
        height: footerHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/footer.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              top: mobile ? 52 : 62,
              right: mobile ? 20 : 0,
              child: _RangakshFooterButtons(
                mobile: mobile,
                onRefund: () => _goTo(context, '/refund-policy'),
                onHome: () => _goTo(context, '/'),
                onTerms: () => _goTo(context, '/tos'),
                onRangaksh: () => _goTo(context, '/rangaksh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangakshFooterButtons extends StatelessWidget {
  const _RangakshFooterButtons({
    required this.mobile,
    required this.onRefund,
    required this.onHome,
    required this.onTerms,
    required this.onRangaksh,
  });

  final bool mobile;
  final VoidCallback onRefund;
  final VoidCallback onHome;
  final VoidCallback onTerms;
  final VoidCallback onRangaksh;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _RangakshFooterButton(label: 'Refund Policy', onTap: onRefund),
      _RangakshFooterButton(label: 'Ananta Organizers', onTap: onHome),
      _RangakshFooterButton(label: 'Terms Of Service', onTap: onTerms),
      _RangakshFooterButton(
        label: 'Rangaksh Youth Festival 2026',
        onTap: onRangaksh,
      ),
    ];

    if (mobile) {
      return SizedBox(
        width: 270,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: buttons,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [buttons[0], const SizedBox(width: 34), buttons[1]],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [buttons[2], const SizedBox(width: 34), buttons[3]],
        ),
      ],
    );
  }
}

class _RangakshFooterButton extends StatelessWidget {
  const _RangakshFooterButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return SizedBox(
      width: mobile ? 122 : (label.length > 18 ? 420 : 260),
      height: mobile ? 28 : 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: RangakshFooter._cream,
          side: BorderSide(color: RangakshFooter._cream.withValues(alpha: .36)),
          padding: EdgeInsets.symmetric(horizontal: mobile ? 8 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(mobile ? 6 : 12),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: mobile ? 8.5 : 21,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
