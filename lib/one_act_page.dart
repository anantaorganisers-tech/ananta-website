import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rangaksh_footer.dart';

class OneActPage extends StatelessWidget {
  const OneActPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CompetitionAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _CompetitionContent(
              onRegister: () =>
                  Navigator.of(context).pushNamed('/talent-hunt-form'),
              onViewThemes: () =>
                  Navigator.of(context).pushNamed('/rangaksh/themes'),
            ),
            const RangakshFooter(),
          ],
        ),
      ),
    );
  }
}

class CompetitionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CompetitionAppBar({
    super.key,
    this.showRangakshLogo = true,
    this.hideOrganizerNameOnMobile = false,
    this.showFrame = true,
  });

  final bool showRangakshLogo;
  final bool hideOrganizerNameOnMobile;
  final bool showFrame;

  @override
  Size get preferredSize => const Size.fromHeight(132);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;
          final mobileRangakshMode = mobile && hideOrganizerNameOnMobile;
          final showOrganizerName = !mobileRangakshMode || !showRangakshLogo;
          return Padding(
            padding: EdgeInsets.all(mobile ? 10 : 16),
            child: Container(
              height: mobile ? 94 : null,
              padding: EdgeInsets.symmetric(horizontal: mobile ? 14 : 24),
              decoration: showFrame
                  ? BoxDecoration(
                      color: const Color(0xFF530C1F),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x88000000),
                          blurRadius: 14,
                          offset: Offset(0, 7),
                        ),
                      ],
                    )
                  : null,
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/ananta_logo.png',
                    width: mobile ? 46 : 68,
                    height: mobile ? 46 : 68,
                    filterQuality: FilterQuality.high,
                  ),
                  if (showOrganizerName) ...[
                    SizedBox(width: mobile ? 9 : 16),
                    Expanded(
                      child: Text(
                        mobile ? 'ANANTA\nORGANIZERS' : 'ANANTA ORGANIZERS',
                        maxLines: mobile ? 2 : 1,
                        overflow: TextOverflow.visible,
                        style: GoogleFonts.montserrat(
                          color: _CompetitionColors.cream,
                          fontSize: mobile ? 12 : 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: mobile ? 1.8 : 3.2,
                          height: mobile ? 1.25 : 1,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (mobileRangakshMode)
                    _AnimatedRangakshAppBarLogo(
                      mobile: mobile,
                      visible: showRangakshLogo,
                    )
                  else
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      opacity: showRangakshLogo ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        offset: showRangakshLogo
                            ? Offset.zero
                            : const Offset(.08, 0),
                        child: Transform.translate(
                          // Keep the mobile mark inside the rounded toolbar.
                          offset: Offset(mobile ? 0 : 10, 0),
                          child: SizedBox(
                            width: mobile ? 142 : 250,
                            height: mobile ? 64 : 100,
                            child: Image.asset(
                              'lib/assets/appbar_rangaksh.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedRangakshAppBarLogo extends StatelessWidget {
  const _AnimatedRangakshAppBarLogo({
    required this.mobile,
    required this.visible,
  });

  final bool mobile;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: mobile ? 142 : 250,
      height: mobile ? 64 : 100,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(.08, 0),
          child: Image.asset(
            'lib/assets/appbar_rangaksh.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _CompetitionContent extends StatelessWidget {
  const _CompetitionContent({
    required this.onRegister,
    required this.onViewThemes,
  });
  final VoidCallback onRegister;
  final VoidCallback onViewThemes;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final horizontal = mobile ? 26.0 : 44.0;
    return Container(
      width: double.infinity,
      color: _CompetitionColors.page,
      padding: EdgeInsets.fromLTRB(
        horizontal,
        mobile ? 62 : 100,
        horizontal,
        mobile ? 70 : 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TALENT HUNT CONTEST',
                style: GoogleFonts.montserrat(
                  color: _CompetitionColors.cream,
                  fontSize: mobile ? 32 : 50,
                  fontWeight: FontWeight.w700,
                  letterSpacing: mobile ? 0 : .7,
                ),
              ),
              SizedBox(height: mobile ? 20 : 28),
              Text(
                'Rangaksh invites the youth to present their originality, creativity and talent through a youth talent show. Participants will have the opportunity to bring their art style to life on stage and showcase their talent in theater, dance, music and a lot more.',
                style: GoogleFonts.baloo2(
                  color: _CompetitionColors.cream,
                  fontSize: mobile ? 18 : 25,
                  fontWeight: FontWeight.w500,
                  height: 1.48,
                ),
              ),
              SizedBox(height: mobile ? 34 : 50),
              Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  _RegisterButton(onTap: onRegister),
                  _RegisterButton(label: 'VIEW THEMES', onTap: onViewThemes),
                ],
              ),
              SizedBox(height: mobile ? 54 : 80),
              const Divider(color: Color(0xFF91636B), thickness: 1),
              SizedBox(height: mobile ? 36 : 52),
              const _RulesGroup(
                title: 'COMPETITION FORMAT:',
                rules: [
                  'The competition will be conducted as an all talent competition.',
                  'Each participating team will present one original stage performance based on the given theme.',
                  'Teams may interpret the theme creatively while maintaining a clear connection to Navratri and/or Navras.',
                ],
              ),
              const _RulesGroup(
                title: 'PERFORMANCE DURATION:',
                rules: ['Minimum: 2-5 minutes', 'Maximum: 35 minutes'],
              ),
              const _RulesGroup(
                title: 'TEAM SIZE:',
                rules: ['Minimum: 1 participant', 'Maximum: 10 participants'],
              ),
              const _RulesGroup(
                title: 'REGISTRATION FEE:',
                rules: [
                  '₹250 for solo/duet performance',
                  '₹400 for 3-5 participant team performance',
                  '₹800 for 5+ participant team performance',
                ],
              ),
              const _RulesGroup(
                title: 'LANGUAGE:',
                rules: [
                  'Performances may be presented Bilingual, in Hindi, Regional Languages like Haryanvi.',
                  'Use of Hindi is Compulsory',
                ],
              ),
              const _RulesGroup(
                title: 'PERFORMANCE & STAGE:',
                rules: [
                  'Teams will be provided with stage and lighting for their performance.',
                  'Each team will be allotted 6-8 minutes for setup and clearance.',
                  'Participants are responsible for bringing their own props, costumes and other required materials, unless otherwise specified.',
                  "The use of the venue's equipment and facilities will be subject to the organiser's guidelines.",
                ],
              ),
              const _RulesGroup(
                title: 'GENERAL GUIDELINES:',
                rules: [
                  'The performance must be suitable for a public/student audience.',
                  'Any content that is offensive, discriminatory or inappropriate may result in disqualification.',
                  'Teams must adhere to the allotted performance time.',
                  'The decision of the judging panel will be final and binding.',
                  'Any violation of the competition guidelines may lead to penalties or disqualification.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.onTap, this.label = 'REGISTER'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    height: 58,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _CompetitionColors.cream.withValues(alpha: .55),
                  width: 1.1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: .14),
                    Colors.white.withValues(alpha: .035),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: _CompetitionColors.cream,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Icon(
                    Icons.north_east_rounded,
                    color: _CompetitionColors.cream,
                    size: 38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RulesGroup extends StatelessWidget {
  const _RulesGroup({required this.title, required this.rules});
  final String title;
  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Padding(
      padding: EdgeInsets.only(bottom: mobile ? 35 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              color: _CompetitionColors.cream,
              fontSize: mobile ? 18 : 24,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: _CompetitionColors.cream,
            ),
          ),
          SizedBox(height: mobile ? 15 : 20),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '•  $rule',
                style: GoogleFonts.baloo2(
                  color: _CompetitionColors.cream,
                  fontSize: mobile ? 17 : 23,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompetitionColors {
  static const page = Color(0xFF5A061F);
  static const cream = Color(0xFFF3E8D0);
}
