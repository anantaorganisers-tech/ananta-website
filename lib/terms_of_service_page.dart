import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';
import 'rangaksh_footer.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
                        'TERMS OF SERVICE',
                        style: GoogleFonts.montserrat(
                          color: _cream,
                          fontSize: mobile ? 32 : 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                      SizedBox(height: mobile ? 18 : 26),
                      Text(
                        'By purchasing a ticket or registering for the event, attendees agree to the following Terms & Conditions:',
                        style: GoogleFonts.baloo2(
                          color: _cream,
                          fontSize: mobile ? 18 : 25,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: mobile ? 34 : 52),
                      for (final section in _termsSections) ...[
                        _TermsSection(section: section),
                        SizedBox(height: mobile ? 26 : 34),
                      ],
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
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.section});

  final _TermSectionData section;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.montserrat(
            color: TermsOfServicePage._cream,
            fontSize: mobile ? 18 : 24,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationColor: TermsOfServicePage._cream,
          ),
        ),
        SizedBox(height: mobile ? 10 : 14),
        Text(
          section.body,
          style: GoogleFonts.baloo2(
            color: TermsOfServicePage._cream,
            fontSize: mobile ? 17 : 23,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _TermSectionData {
  const _TermSectionData({required this.title, required this.body});

  final String title;
  final String body;
}

const _termsSections = [
  _TermSectionData(
    title: '1. Event Details',
    body:
        'The event is a youth festival featuring a talent show in the morning, followed by a Garba festival in the evening/night. The organisers reserve the right to modify the event schedule, activities, performers, or venue arrangements if required.',
  ),
  _TermSectionData(
    title: '2. Entry & Tickets',
    body:
        'Entry is permitted only to valid ticket holders/registered participants. Tickets are non-transferable unless specifically permitted by the organisers. Attendees may be required to present their ticket and valid identification at the entrance.',
  ),
  _TermSectionData(
    title: '3. Refund Policy',
    body:
        'Refund requests will only be accepted up to 7 days before the event date. Approved refunds will be limited to 75% of the ticket price. The remaining 25% will be retained towards administrative and booking expenses.\n\nNo refund requests will be accepted within 7 days of the event or after the event has commenced.',
  ),
  _TermSectionData(
    title: '4. No Transport Facility',
    body:
        'The organisers do not provide transportation to or from the event venue. Attendees are responsible for arranging their own travel and transportation.',
  ),
  _TermSectionData(
    title: '5. Talent Show Participation',
    body:
        'Participants in the talent show must follow the rules and instructions provided by the organisers. The organisers reserve the right to restrict or disqualify performances that are unsafe, inappropriate, offensive, or violate applicable laws or event guidelines.',
  ),
  _TermSectionData(
    title: '6. Garba & Event Conduct',
    body:
        'Attendees are expected to maintain appropriate conduct and follow instructions given by the organising team, security personnel, and venue staff. Misconduct, harassment, violence, or damage to property may result in removal from the event without refund.',
  ),
  _TermSectionData(
    title: '7. Personal Belongings',
    body:
        'Attendees are responsible for their own personal belongings. The organisers will not be responsible for loss, theft, or damage to personal items brought to the event.',
  ),
  _TermSectionData(
    title: '8. Safety & Liability',
    body:
        "Attendees participate in event activities at their own responsibility. The organisers will take reasonable measures to maintain a safe environment but will not be responsible for injuries, losses, or damages arising from an attendee's negligence or failure to follow safety instructions.",
  ),
  _TermSectionData(
    title: '9. Event Changes or Cancellation',
    body:
        'In case of necessary changes to the event schedule, programme, performers, venue arrangements, or other event details, the organisers will communicate the changes through appropriate channels. In case the event is cancelled by the organisers, the refund policy applicable to the cancellation will be communicated separately.',
  ),
  _TermSectionData(
    title: '10. Photography & Recording',
    body:
        'Photography and video recording may take place during the event for promotional, documentation, and social media purposes. By attending the event, attendees acknowledge that they may appear in such photographs or recordings.',
  ),
  _TermSectionData(
    title: "11. Organiser's Rights",
    body:
        'The organisers reserve the right to deny entry or remove any attendee who violates these Terms & Conditions, event rules, or applicable laws. Such removal may be carried out without a refund.',
  ),
  _TermSectionData(
    title: '12. Acceptance of Terms',
    body:
        'By purchasing a ticket, registering for participation, or entering the event premises, the attendee confirms that they have read, understood, and agreed to these Terms & Conditions.',
  ),
];
