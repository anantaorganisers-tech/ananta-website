import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ananta_portfolio_app_bar.dart';
import 'web_navigation.dart';

class AnantaPage extends StatefulWidget {
  const AnantaPage({super.key});

  @override
  State<AnantaPage> createState() => _AnantaPageState();
}

class _AnantaPageState extends State<AnantaPage> {
  final _foundersKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AnantaPortfolioAppBar(
        mobile: mobile,
        onFounders: () => _scrollTo(_foundersKey),
        onEvents: () => openRouteInNewTab('/rangaksh'),
        onContact: () => _scrollTo(_contactKey),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _AnantaHero()),
          const SliverToBoxAdapter(
            child: _PortfolioScrollReveal(child: _WhatAreWeSection()),
          ),
          SliverToBoxAdapter(
            child: _PortfolioScrollReveal(
              child: _FoundersSection(key: _foundersKey),
            ),
          ),
          const SliverToBoxAdapter(
            child: _PortfolioScrollReveal(child: _EventsSection()),
          ),
          SliverToBoxAdapter(
            child: _PortfolioScrollReveal(
              child: _ContactSection(key: _contactKey),
            ),
          ),
          const SliverToBoxAdapter(child: _PortfolioFooter()),
        ],
      ),
    );
  }
}

class _PortfolioScrollReveal extends StatefulWidget {
  const _PortfolioScrollReveal({required this.child});

  final Widget child;

  @override
  State<_PortfolioScrollReveal> createState() => _PortfolioScrollRevealState();
}

class _PortfolioScrollRevealState extends State<_PortfolioScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_position == position) return;
    _position?.removeListener(_checkVisibility);
    _position = position;
    _position?.addListener(_checkVisibility);
  }

  void _checkVisibility() {
    if (!mounted || _controller.isCompleted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    if (renderObject.localToGlobal(Offset.zero).dy <
        MediaQuery.sizeOf(context).height * .9) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => Opacity(
      opacity: _controller.value,
      child: Transform.translate(
        offset: Offset(0, 28 * (1 - _controller.value)),
        child: child,
      ),
    ),
  );
}

class _PortfolioHoverLift extends StatefulWidget {
  const _PortfolioHoverLift({required this.child});

  final Widget child;

  @override
  State<_PortfolioHoverLift> createState() => _PortfolioHoverLiftState();
}

class _PortfolioHoverLiftState extends State<_PortfolioHoverLift> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      scale: _hovered ? 1.025 : 1,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: _hovered ? const Offset(0, -.025) : Offset.zero,
        child: widget.child,
      ),
    ),
  );
}

class _AnantaHero extends StatelessWidget {
  const _AnantaHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 768;
    final tablet = width >= 768 && width < 1100;

    return SizedBox(
      height: mobile
          ? 640
          : tablet
          ? 690
          : 720,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _AnantaColors.hero),
          Opacity(
            opacity: mobile ? .085 : .11,
            child: Image.asset(
              'lib/assets/ananta_portf/hero_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.15),
                radius: 1.05,
                colors: [
                  Colors.white.withValues(alpha: .035),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  mobile ? 22 : 36,
                  mobile ? 96 : 132,
                  mobile ? 22 : 36,
                  mobile ? 70 : 96,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Where Creativity Finds Its\nStage.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: _AnantaColors.cream,
                          fontSize: mobile
                              ? 34
                              : tablet
                              ? 48
                              : 64,
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          letterSpacing: mobile ? -.8 : -1.3,
                        ),
                      ),
                      SizedBox(height: mobile ? 20 : 24),
                      Text(
                        'A youth-led organization driven by a passion for art & meaningful experiences.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: _AnantaColors.cream.withValues(alpha: .88),
                          fontSize: mobile ? 14 : 20,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: mobile ? 32 : 38),
                      _LatestEventButton(
                        compact: mobile,
                        onTap: () => openRouteInNewTab('/rangaksh'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestEventButton extends StatelessWidget {
  const _LatestEventButton({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11);
    return _PortfolioHoverLift(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Ink(
                height: compact ? 46 : 50,
                padding: EdgeInsets.symmetric(horizontal: compact ? 15 : 18),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _AnantaColors.cream.withValues(alpha: .65),
                  ),
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: .13),
                      Colors.white.withValues(alpha: .035),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Have a look at our latest event',
                      style: GoogleFonts.montserrat(
                        color: _AnantaColors.cream,
                        fontSize: compact ? 11 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: compact ? 12 : 16),
                    Icon(
                      Icons.north_east_rounded,
                      color: _AnantaColors.cream,
                      size: compact ? 18 : 20,
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
}

class _WhatAreWeSection extends StatelessWidget {
  const _WhatAreWeSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 768;
    final compact = width >= 768 && width < 1100;
    final copy = Text.rich(
      TextSpan(
        style: GoogleFonts.montserrat(
          color: _AnantaColors.cream,
          fontSize: mobile
              ? 15
              : compact
              ? 16
              : 18,
          height: 1.36,
          fontWeight: FontWeight.w400,
        ),
        children: const [
          TextSpan(text: 'We are an established '),
          TextSpan(
            text: 'theater collective',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' with over '),
          TextSpan(
            text: 'two years',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text:
                ' of experience in creating and performing theater across diverse platforms.\nOver the years, we have been actively involved with ',
          ),
          TextSpan(
            text: 'Faith in Theater',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ', presenting productions across cities ranging from ',
          ),
          TextSpan(
            text: 'Rewari to Patiala.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text:
                '\n\nThese experiences have given us first-hand exposure to different audiences, venues, production environments and the demands of live theater. Having built our foundation through these experiences, we are now taking the next step by bringing our own vision to life.',
          ),
        ],
      ),
    );

    return Container(
      constraints: BoxConstraints(
        minHeight: mobile
            ? 650
            : compact
            ? 465
            : 540,
      ),
      color: _AnantaColors.section,
      child: Stack(
        children: [
          Positioned(
            left: mobile ? -110 : 0,
            top: mobile
                ? 56
                : compact
                ? 56
                : 64,
            child: Opacity(
              opacity: .15,
              child: Image.asset(
                'lib/assets/ananta_portf/what_are_we_bg.png',
                width: mobile
                    ? 380
                    : compact
                    ? 420
                    : 500,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile
                      ? 28
                      : compact
                      ? 50
                      : 54,
                  vertical: mobile
                      ? 88
                      : compact
                      ? 90
                      : 100,
                ),
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WHAT\nARE\nWE?',
                            style: GoogleFonts.montserrat(
                              color: _AnantaColors.cream,
                              fontSize: 46,
                              height: 1.04,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 40),
                          copy,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: compact ? 3 : 4,
                            child: Text(
                              'WHAT\nARE\nWE?',
                              style: GoogleFonts.montserrat(
                                color: _AnantaColors.cream,
                                fontSize: compact ? 50 : 74,
                                height: .99,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 20 : 58),
                          Expanded(flex: compact ? 7 : 10, child: copy),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundersSection extends StatelessWidget {
  const _FoundersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 768;
    final scale = width >= 1100 ? 1.5 : 1.0;
    const founders = [
      _Founder(
        imagePath: 'lib/assets/ananta_portf/adivisor_card.png',
        biography:
            'Behind every journey is someone who has silently become the base of it all, and for us, that is Dr. Rishipal Yogi.\nHe is the Founder and CEO of Faith in Theatre, and apart from being our guru, he has been the mentor who has made us acquainted with theatre and has taught us the craft and skills of it. All that learning that we have undergone throughout our journey of lessons, rehearsals, performances has made us who we are as artists.',
      ),
      _Founder(
        imagePath: 'lib/assets/ananta_portf/ceo_card.png',
        biography:
            'Chirag is the Chief Executive Officer of the Ananta Organisation.\nHe has been taking part in theatrical events for many years and has received 10+ awards for his contribution in theatre. He serves an important role in the success of Rangaksh and the future of Ananta.',
      ),
      _Founder(
        imagePath: 'lib/assets/ananta_portf/cmo_card.png',
        biography:
            'Urshita is the Chief Marketing Officer of the Ananta Organisation. She has profound experience in marketing and theatre having participated in over 15 conferences and theatrical place all over North India. She has received numerous awards and certifications for her work in theatre.',
      ),
    ];

    return Container(
      color: _AnantaColors.section,
      padding: EdgeInsets.fromLTRB(
        mobile ? 28 : 54 * scale,
        mobile ? 74 : 106 * scale,
        mobile ? 28 : 54 * scale,
        mobile ? 82 : 118 * scale,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1080 * scale),
          child: Column(
            children: [
              Text(
                'MEET THE FOUNDERS',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: _AnantaColors.cream,
                  fontSize: (mobile ? 28 : 40) * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: mobile ? 0 : .4,
                ),
              ),
              SizedBox(height: 16 * scale),
              const _SectionDivider(),
              SizedBox(height: (mobile ? 36 : 54) * scale),
              for (var index = 0; index < founders.length; index++) ...[
                _FounderRow(founder: founders[index], mobile: mobile),
                if (index < founders.length - 1)
                  SizedBox(height: (mobile ? 56 : 68) * scale),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FounderRow extends StatelessWidget {
  const _FounderRow({required this.founder, required this.mobile});

  final _Founder founder;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final scale = _founderScale(context);
    final card = _PortfolioHoverLift(
      child: Image.asset(
        founder.imagePath,
        width: (mobile ? 190 : 246) * scale,
        filterQuality: FilterQuality.high,
      ),
    );
    final biography = Text(
      founder.biography,
      style: GoogleFonts.montserrat(
        color: _AnantaColors.cream,
        fontSize: (mobile ? 14 : 16) * scale,
        height: 1.35,
        fontWeight: FontWeight.w400,
      ),
    );

    return mobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: card),
              SizedBox(height: 24 * scale),
              biography,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              card,
              SizedBox(width: 54 * scale),
              Expanded(child: biography),
            ],
          );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: _AnantaColors.gold, thickness: 1)),
      Transform.rotate(
        angle: .785398,
        child: const SizedBox(
          width: 6,
          height: 6,
          child: ColoredBox(color: _AnantaColors.gold),
        ),
      ),
      Expanded(child: Divider(color: _AnantaColors.gold, thickness: 1)),
    ],
  );
}

class _Founder {
  const _Founder({required this.imagePath, required this.biography});

  final String imagePath;
  final String biography;
}

double _founderScale(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 1100 ? 1.5 : 1;

class _EventsSection extends StatelessWidget {
  const _EventsSection();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Container(
      color: _AnantaColors.hero,
      padding: EdgeInsets.fromLTRB(
        mobile ? 28 : 54,
        mobile ? 76 : 108,
        mobile ? 28 : 54,
        mobile ? 84 : 116,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            children: [
              Text(
                'OUR EVENTS',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: _AnantaColors.cream,
                  fontSize: mobile ? 28 : 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const _SectionDivider(),
              SizedBox(height: mobile ? 42 : 56),
              Image.asset(
                'lib/assets/ananta_portf/rangaksh_hero.png',
                width: mobile ? 440 : 840,
                filterQuality: FilterQuality.high,
              ),
              SizedBox(height: mobile ? 42 : 54),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Text(
                  'Rangaksh is a celebration of theatre, performance, imagination, and the countless stories waiting to be told. It brings together performers from diverse backgrounds to share their talent, learn from one another, and experience the magic of live performance.\n\nThrough events like Rangaksh, Ananta aims to bring together young artists, performers, and theatre enthusiasts under one roof, creating a space where talent meets opportunity and stories come alive.',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                    color: _AnantaColors.cream,
                    fontSize: mobile ? 14 : 20,
                    height: 1.38,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: mobile ? 42 : 52),
              _ExploreRangakshButton(
                compact: mobile,
                onTap: () => openRouteInNewTab('/rangaksh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreRangakshButton extends StatefulWidget {
  const _ExploreRangakshButton({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  State<_ExploreRangakshButton> createState() => _ExploreRangakshButtonState();
}

class _ExploreRangakshButtonState extends State<_ExploreRangakshButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        scale: _hovered ? 1.03 : 1,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: radius,
                child: Ink(
                  height: widget.compact ? 46 : 52,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.compact ? 18 : 22,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _AnantaColors.cream.withValues(alpha: .62),
                    ),
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: _hovered ? .18 : .13),
                        Colors.white.withValues(alpha: .035),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EXPLORE RANGAKSH',
                        style: GoogleFonts.montserrat(
                          color: _AnantaColors.cream,
                          fontSize: widget.compact ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(width: 22),
                      const Icon(
                        Icons.north_east_rounded,
                        color: _AnantaColors.cream,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Container(
      color: _AnantaColors.section,
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 54,
        mobile ? 64 : 100,
        mobile ? 20 : 54,
        mobile ? 80 : 112,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: _PortfolioHoverLift(
            child: Container(
              padding: EdgeInsets.all(mobile ? 26 : 48),
              decoration: BoxDecoration(
                color: const Color(0xB64C1020),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _AnantaColors.gold.withValues(alpha: .55),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 18,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: mobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ContactHeading(),
                        const SizedBox(height: 26),
                        const _ContactDetails(),
                      ],
                    )
                  : const Row(
                      children: [
                        Expanded(child: _ContactHeading()),
                        SizedBox(width: 70),
                        Expanded(child: _ContactDetails()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactHeading extends StatelessWidget {
  const _ContactHeading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'CONTACT US',
        style: GoogleFonts.montserrat(
          color: _AnantaColors.cream,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'For Business, Sponsorship and Event\nInquiries, contact:',
        style: GoogleFonts.montserrat(
          color: _AnantaColors.cream.withValues(alpha: .82),
          fontSize: 12,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ContactLine(
        icon: Icons.phone_in_talk_rounded,
        label: '+91 734 064 4654',
      ),
      const SizedBox(height: 12),
      _ContactLine(
        icon: Icons.email_rounded,
        label: 'anantaorganisers@gmail.com',
      ),
    ],
  );
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _AnantaColors.cream, size: 18),
      const SizedBox(width: 10),
      Text(
        label,
        style: GoogleFonts.montserrat(
          color: _AnantaColors.cream,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _PortfolioFooter extends StatelessWidget {
  const _PortfolioFooter();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF420D1B),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Image.asset(
          'lib/assets/ananta_portf/footer.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        ),
      ),
    ),
  );
}

class _AnantaColors {
  static const hero = Color(0xFF5A1725);
  static const section = Color(0xFF571726);
  static const cream = Color(0xFFF3E8D0);
  static const gold = Color(0xFFC6A15B);
}
