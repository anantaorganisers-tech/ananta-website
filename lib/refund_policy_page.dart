import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';
import 'rangaksh_footer.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  static const _page = Color(0xFF5A061F);
  static const _cream = Color(0xFFFFF3DE);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      appBar: const CompetitionAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: _page,
              padding: EdgeInsets.fromLTRB(
                mobile ? 24 : 56,
                mobile ? 58 : 90,
                mobile ? 24 : 56,
                mobile ? 64 : 100,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFUND POLICY',
                        style: GoogleFonts.montserrat(
                          color: _cream,
                          fontSize: mobile ? 32 : 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                      SizedBox(height: mobile ? 24 : 36),
                      Text(
                        'Tickets for the event are eligible for a partial refund only if the refund request is made at least 7 days before the event date.',
                        style: _bodyStyle(mobile),
                      ),
                      SizedBox(height: mobile ? 24 : 34),
                      for (final policy in _refundPolicyPoints)
                        Padding(
                          padding: EdgeInsets.only(bottom: mobile ? 12 : 16),
                          child: Text('•  $policy', style: _bodyStyle(mobile)),
                        ),
                      SizedBox(height: mobile ? 18 : 28),
                      Text(
                        'By purchasing a ticket, the attendee acknowledges and accepts this Refund Policy.',
                        style: _bodyStyle(mobile),
                      ),
                    ],
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

  TextStyle _bodyStyle(bool mobile) => GoogleFonts.baloo2(
    color: _cream,
    fontSize: mobile ? 18 : 25,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
}

const _refundPolicyPoints = [
  'Eligible refund: 75% of the ticket price',
  '25% of the ticket price will be retained towards administrative and booking expenses.',
  'Refund requests made within 7 days of the event will not be accepted.',
  'No refunds will be issued after the event has commenced.',
  'Refunds, where approved, will be processed to the original payment method within a reasonable processing period.',
  'Convenience fees, payment gateway charges, or other applicable third-party charges may be non-refundable.',
];
