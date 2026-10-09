import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'one_act_page.dart';
import 'rangaksh_footer.dart';
import 'web_navigation.dart';

class RangakshPage extends StatefulWidget {
  const RangakshPage({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<RangakshPage> createState() => _RangakshPageState();
}

class _RangakshPageState extends State<RangakshPage> {
  final _aboutKey = GlobalKey();
  final _activitiesKey = GlobalKey();
  final _ticketsKey = GlobalKey();
  final _themeKey = GlobalKey();
  final _sponsorKey = GlobalKey();
  var _showAppBarRangakshLogo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSection == 'themes') {
        _scrollTo(_themeKey);
      }
    });
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical || notification.depth != 0) {
      return false;
    }

    final width = MediaQuery.sizeOf(context).width;
    final heroHeight = _heroDesignHeightForWidth(width);
    final showLogo = notification.metrics.pixels >= heroHeight;
    if (showLogo != _showAppBarRangakshLogo) {
      setState(() => _showAppBarRangakshLogo = showLogo);
    }
    return false;
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CompetitionAppBar(
        showRangakshLogo: _showAppBarRangakshLogo,
        hideOrganizerNameOnMobile: true,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: ScrollReveal(child: HeroSection())),
            SliverToBoxAdapter(
              child: ScrollReveal(child: CelebrationSection(key: _ticketsKey)),
            ),
            SliverToBoxAdapter(
              child: ScrollReveal(child: IntroSection(key: _aboutKey)),
            ),
            SliverToBoxAdapter(
              child: ScrollReveal(
                child: ActivitiesSection(key: _activitiesKey),
              ),
            ),
            SliverToBoxAdapter(
              child: ScrollReveal(child: ThemeSection(key: _themeKey)),
            ),
            const SliverToBoxAdapter(
              child: ScrollReveal(child: DjGarbaSection()),
            ),
            SliverToBoxAdapter(
              child: ScrollReveal(
                child: SponsorVisibilitySection(key: _sponsorKey),
              ),
            ),
            const SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      ),
    );
  }
}

double _heroDesignHeightForWidth(double width) {
  if (width < 768) return 735;
  if (width < 1200) return 690;
  return 830;
}

class SiteColors {
  static const page = Color(0xFF5A1725);
  static const hero = Color(0xFF530B20);
  static const deep = Color(0xFF4E0A1E);
  static const accent = Color(0xFF3D0918);
  static const cream = Color(0xFFF3E8D0);
  static const gold = Color(0xFFC6A15B);
  static const mutedBorder = Color(0xBB8B8383);
}

const _rangakshVenueMapsUrl = 'https://maps.app.goo.gl/BAu8L18WaHAXpfJ2A';

class LayoutValues {
  const LayoutValues(this.width);
  final double width;
  bool get mobile => width < 768;
  bool get tablet => width >= 768 && width < 1200;
  double get gutter => mobile
      ? 20
      : tablet
      ? 48
      : 84;
  double get maxContent => 1360;
}

class ScrollReveal extends StatefulWidget {
  const ScrollReveal({super.key, required this.child});
  final Widget child;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
        MediaQuery.sizeOf(context).height * .92) {
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

class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
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
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final values = LayoutValues(constraints.maxWidth);
        final designHeight = _heroDesignHeightForWidth(constraints.maxWidth);
        final height = MediaQuery.sizeOf(context).height > designHeight
            ? MediaQuery.sizeOf(context).height
            : designHeight;
        return SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                values.mobile
                    ? 'lib/assets/mobile_hero_background'
                    : 'lib/assets/desktop_hero_background.png',
                fit: BoxFit.cover,
                alignment: values.mobile
                    ? Alignment.topCenter
                    : Alignment.center,
                filterQuality: FilterQuality.high,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SiteColors.hero.withValues(alpha: .25),
                      SiteColors.hero.withValues(alpha: .82),
                    ],
                  ),
                ),
              ),
              values.mobile
                  ? const _MobileHeroContent()
                  : _HeroContent(values: values),
            ],
          ),
        );
      },
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 105,
              left: 24,
              right: 24,
              child: Image.asset(
                'lib/assets/mobile_hero.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              top: 315,
              left: 0,
              right: 0,
              child: const _MobileHeroLocation(),
            ),
            Positioned(
              top: 369,
              left: 0,
              right: 0,
              child: Text(
                '10 OCTOBER, 2026',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: SiteColors.cream,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHeroLocation extends StatelessWidget {
  const _MobileHeroLocation();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MobileHeroLocationButton(
          onTap: () => openExternalUrl(_rangakshVenueMapsUrl),
        ),
      ],
    );
  }
}

class _MobileHeroLocationButton extends StatelessWidget {
  const _MobileHeroLocationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: SiteColors.cream,
          side: BorderSide(color: SiteColors.cream.withValues(alpha: .58)),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'VIEW LOCATION ON MAPS',
          style: GoogleFonts.montserrat(
            fontSize: 14.25,
            fontWeight: FontWeight.w700,
            letterSpacing: .52,
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.values});
  final LayoutValues values;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: values.maxContent),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: values.gutter,
            vertical: values.mobile ? 22 : 34,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const _DesktopHeroArtwork()],
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroArtwork extends StatelessWidget {
  const _DesktopHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1711 / 370,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 1711;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'lib/assets/desktop_hero.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              Positioned(
                left: 1130 * scale,
                top: 306 * scale,
                child: _HeroLocationButton(
                  scale: scale,
                  onTap: () => openExternalUrl(_rangakshVenueMapsUrl),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroLocationButton extends StatelessWidget {
  const _HeroLocationButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: SizedBox(
        height: 54 * scale,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: SiteColors.cream,
            side: BorderSide(color: SiteColors.cream.withValues(alpha: .58)),
            padding: EdgeInsets.symmetric(horizontal: 21 * scale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * scale),
            ),
          ),
          child: Text(
            'VIEW LOCATION ON MAPS',
            style: GoogleFonts.montserrat(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: .75 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

class AnantaSiteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnantaSiteAppBar({
    super.key,
    required this.mobile,
    required this.onAbout,
    required this.onActivities,
    required this.onSponsors,
    required this.onJoin,
  });

  final bool mobile;
  final VoidCallback onAbout;
  final VoidCallback onActivities;
  final VoidCallback onSponsors;
  final VoidCallback onJoin;

  @override
  Size get preferredSize => Size.fromHeight(mobile ? 94 : 124);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 9 : 28,
            mobile ? 8 : 16,
            mobile ? 9 : 28,
            mobile ? 8 : 16,
          ),
          child: TopNav(
            mobile: mobile,
            onAbout: onAbout,
            onActivities: onActivities,
            onSponsors: onSponsors,
            onJoin: onJoin,
          ),
        ),
      ),
    );
  }
}

class TopNav extends StatelessWidget {
  const TopNav({
    super.key,
    required this.mobile,
    required this.onAbout,
    required this.onActivities,
    required this.onSponsors,
    required this.onJoin,
  });
  final bool mobile;
  final VoidCallback onAbout;
  final VoidCallback onActivities;
  final VoidCallback onSponsors;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'lib/assets/ananta_logo.png',
          width: mobile ? 42 : 58,
          height: mobile ? 42 : 58,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(width: mobile ? 8 : 12),
        Text(
          'ANANTA ORGANIZERS',
          style: GoogleFonts.montserrat(
            color: SiteColors.cream,
            fontWeight: FontWeight.w600,
            letterSpacing: mobile ? 2.3 : 3.2,
            fontSize: mobile ? 13 : 17,
          ),
        ),
      ],
    );
    return Container(
      height: mobile ? 70 : 92,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 14 : 28),
      decoration: BoxDecoration(
        color: const Color(0xEF530C1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x785A1725)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: mobile
          ? Row(
              children: [
                logo,
                const Spacer(),
                PopupMenuButton<_MobileNavAction>(
                  tooltip: 'Navigation menu',
                  color: SiteColors.hero,
                  icon: const Icon(Icons.menu_rounded, color: SiteColors.cream),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: SiteColors.mutedBorder),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _MobileNavAction.about:
                        onAbout();
                      case _MobileNavAction.activities:
                        onActivities();
                      case _MobileNavAction.sponsors:
                        onSponsors();
                      case _MobileNavAction.join:
                        onJoin();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _MobileNavAction.about,
                      child: _MobileMenuLabel('ABOUT'),
                    ),
                    PopupMenuItem(
                      value: _MobileNavAction.activities,
                      child: _MobileMenuLabel('EVENTS'),
                    ),
                    PopupMenuItem(
                      value: _MobileNavAction.sponsors,
                      child: _MobileMenuLabel('SPONSOR'),
                    ),
                    PopupMenuItem(
                      value: _MobileNavAction.join,
                      child: _MobileMenuLabel('JOIN US'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                logo,
                const Spacer(),
                _DesktopNavButton(label: 'ABOUT', onTap: onAbout),
                const SizedBox(width: 10),
                _DesktopNavButton(label: 'ACTIVITIES', onTap: onActivities),
                const SizedBox(width: 10),
                _DesktopNavButton(label: 'SPONSOR', onTap: onSponsors),
                const SizedBox(width: 10),
                _DesktopNavButton(label: 'JOIN US', onTap: onJoin),
              ],
            ),
    );
  }
}

class _DesktopNavButton extends StatelessWidget {
  const _DesktopNavButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverLift(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: SiteColors.cream.withValues(alpha: .28)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withValues(alpha: .04),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: SiteColors.cream,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.3,
            ),
          ),
        ),
      ),
    ),
  );
}

enum _MobileNavAction { about, activities, sponsors, join }

class _MobileMenuLabel extends StatelessWidget {
  const _MobileMenuLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.montserrat(
      color: SiteColors.cream,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    ),
  );
}

class CelebrationSection extends StatelessWidget {
  const CelebrationSection({super.key});

  @override
  Widget build(BuildContext context) => _SectionFrame(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final values = LayoutValues(constraints.maxWidth);
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A celebration of imagination, and the countless stories waiting to be told.',
              style: GoogleFonts.montserrat(
                color: SiteColors.cream,
                fontSize: values.mobile ? 24 : 42,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bringing together performers and theatre enthusiasts to create their talent, redefine the arts, and experience the magic of live performance.',
              style: GoogleFonts.montserrat(
                color: SiteColors.cream.withValues(alpha: .82),
                fontSize: values.mobile ? 12 : 18,
                height: 1.35,
              ),
            ),
            SizedBox(height: values.mobile ? 22 : 32),
            Align(
              alignment: values.mobile
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Column(
                crossAxisAlignment: values.mobile
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    'AUDIENCE TICKET: ₹ 80',
                    style: GoogleFonts.montserrat(
                      color: SiteColors.cream,
                      fontSize: values.mobile ? 16 : 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.symmetric(vertical: values.mobile ? 60 : 120),
          child: values.mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'lib/assets/mask_image.png',
                        width: 150,
                      ),
                    ),
                    const SizedBox(height: 26),
                    copy,
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'lib/assets/mask_image.png',
                          width: 260,
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: copy),
                  ],
                ),
        );
      },
    ),
  );
}

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});
  @override
  Widget build(BuildContext context) => _SectionFrame(
    child: LayoutBuilder(
      builder: (context, c) {
        final v = LayoutValues(c.maxWidth);
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where creativity finds its stage.',
              style: GoogleFonts.montserrat(
                color: SiteColors.cream,
                fontSize: v.mobile ? 25 : 42,
                fontWeight: FontWeight.w700,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A creative youth-led organization driven by a passion for art, expression, and meaningful experiences. We believe that creativity has no boundaries and that every individual deserves a platform to express, perform, and connect.\n\nThrough events like Rangaksh, Ananta aims to bring together young artists, performers, and theatre enthusiasts under one roof, creating a space where talent meets opportunity and stories come alive.',
              style: GoogleFonts.montserrat(
                color: SiteColors.cream.withValues(alpha: .88),
                fontSize: v.mobile ? 13 : 16,
                height: 1.45,
              ),
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.only(bottom: v.mobile ? 72 : 130),
          child: v.mobile
              ? Column(
                  children: [
                    Image.asset('lib/assets/ananta_logo.png', width: 180),
                    const SizedBox(height: 34),
                    copy,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: copy),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'lib/assets/ananta_logo.png',
                          width: 290,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    ),
  );
}

class AboutAnantaSection extends StatelessWidget {
  const AboutAnantaSection({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: SiteColors.deep,
    child: _SectionFrame(
      child: LayoutBuilder(
        builder: (context, c) {
          final v = LayoutValues(c.maxWidth);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: v.mobile ? 58 : 96),
            child: v.mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AboutCopy(v: v),
                      const SizedBox(height: 34),
                      Center(
                        child: Opacity(
                          opacity: .72,
                          child: Image.asset(
                            'lib/assets/mask_image.png',
                            width: 210,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _AboutCopy(v: v)),
                      Expanded(
                        child: Center(
                          child: Opacity(
                            opacity: .72,
                            child: Image.asset(
                              'lib/assets/mask_image.png',
                              width: 330,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    ),
  );
}

class _AboutCopy extends StatelessWidget {
  const _AboutCopy({required this.v});
  final LayoutValues v;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('ABOUT ANANTA', style: _sectionOverline(v)),
      const SizedBox(height: 18),
      Text(
        'A stage for\ncreativity.',
        style: GoogleFonts.montserrat(
          color: SiteColors.cream,
          fontWeight: FontWeight.w700,
          fontSize: v.mobile ? 50 : 76,
          height: .86,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Ananta is where young creators come together to turn expression into experience.',
        style: GoogleFonts.baloo2(
          color: SiteColors.cream,
          fontSize: v.mobile ? 18 : 22,
          height: 1.35,
        ),
      ),
    ],
  );
}

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});
  static const featured = [
    'lib/assets/one_act_card.png',
    'lib/assets/dance_card.png',
    'lib/assets/djgarba_card.png',
  ];
  @override
  Widget build(BuildContext context) => _SectionFrame(
    child: LayoutBuilder(
      builder: (context, c) {
        final v = LayoutValues(c.maxWidth);
        final columns = v.mobile ? 1 : 3;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: v.mobile ? 62 : 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'The Authentic Experience',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: SiteColors.cream,
                  fontWeight: FontWeight.w700,
                  fontSize: v.mobile ? 29 : 42,
                ),
              ),
              Text(
                'Rangaksh brings you the raw experience of these listed activites',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: SiteColors.cream.withValues(alpha: .76),
                  fontSize: v.mobile ? 11 : 14,
                ),
              ),
              SizedBox(height: v.mobile ? 34 : 54),
              v.mobile
                  ? AssetCarousel(paths: featured, aspectRatio: 1257 / 1725)
                  : _AssetGrid(paths: featured, columns: columns, gap: 25),
            ],
          ),
        );
      },
    ),
  );
}

class AssetCarousel extends StatefulWidget {
  const AssetCarousel({
    super.key,
    required this.paths,
    required this.aspectRatio,
  });

  final List<String> paths;
  final double aspectRatio;

  @override
  State<AssetCarousel> createState() => _AssetCarouselState();
}

class _AssetCarouselState extends State<AssetCarousel> {
  late final PageController _controller;
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .86);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * .86;
        return Column(
          children: [
            SizedBox(
              height: cardWidth / widget.aspectRatio,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.paths.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.paths.length - 1 ? 0 : 14,
                  ),
                  child: HoverLift(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        widget.paths[index],
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.paths.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentPage ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? SiteColors.gold
                        : SiteColors.cream.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AssetGrid extends StatelessWidget {
  const _AssetGrid({
    required this.paths,
    required this.columns,
    required this.gap,
  });
  final List<String> paths;
  final int columns;
  final double gap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final width = (c.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final path in paths)
            SizedBox(
              width: width,
              child: HoverLift(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    path,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SiteColors.accent,
      child: _SectionFrame(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final values = LayoutValues(constraints.maxWidth);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: values.mobile ? 62 : 110),
              child: Column(
                children: [
                  Text('THEME', style: _sectionOverline(values)),
                  const SizedBox(height: 20),
                  FractionallySizedBox(
                    widthFactor: values.mobile ? 1 : .78,
                    child: Image.asset(
                      'lib/assets/navratri_navras_text.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: values.mobile ? 32 : 56),
                  values.mobile
                      ? const AssetCarousel(
                          aspectRatio: 1256 / 1574,
                          paths: [
                            'lib/assets/theme_cards/Group 110.png',
                            'lib/assets/theme_cards/Group 111.png',
                            'lib/assets/theme_cards/Group 112.png',
                            'lib/assets/theme_cards/Group 113.png',
                            'lib/assets/theme_cards/Group 114.png',
                            'lib/assets/theme_cards/Group 115.png',
                            'lib/assets/theme_cards/Group 116.png',
                            'lib/assets/theme_cards/Group 117.png',
                            'lib/assets/theme_cards/Group 118.png',
                          ],
                        )
                      : const ThemeDesktopCarousel(
                          paths: [
                            'lib/assets/theme_cards/Group 110.png',
                            'lib/assets/theme_cards/Group 111.png',
                            'lib/assets/theme_cards/Group 112.png',
                            'lib/assets/theme_cards/Group 113.png',
                            'lib/assets/theme_cards/Group 114.png',
                            'lib/assets/theme_cards/Group 115.png',
                            'lib/assets/theme_cards/Group 116.png',
                            'lib/assets/theme_cards/Group 117.png',
                            'lib/assets/theme_cards/Group 118.png',
                          ],
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ThemeDesktopCarousel extends StatefulWidget {
  const ThemeDesktopCarousel({super.key, required this.paths});

  final List<String> paths;

  @override
  State<ThemeDesktopCarousel> createState() => _ThemeDesktopCarouselState();
}

class _ThemeDesktopCarouselState extends State<ThemeDesktopCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1 / 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int direction) {
    if (!_controller.hasClients) return;
    final target = (_controller.page ?? 0).round() + direction;
    _controller.animateToPage(
      target.clamp(0, widget.paths.length - 1).toInt(),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final carouselWidth = constraints.maxWidth - 112;
        final cardHeight = carouselWidth / 3 / (1256 / 1574);
        return SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              _CarouselArrow(
                icon: Icons.arrow_back_rounded,
                onPressed: () => _move(-1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  padEnds: false,
                  itemCount: widget.paths.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: HoverLift(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.paths[index],
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _CarouselArrow(
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _move(1),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 40,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: SiteColors.cream,
        side: const BorderSide(color: SiteColors.gold),
        shape: const CircleBorder(),
      ),
      child: Icon(icon, size: 22),
    ),
  );
}

class DjGarbaSection extends StatelessWidget {
  const DjGarbaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = size.width < 768;
    final height = mobile
        ? 820.0
        : size.height < 1080
        ? 1080.0
        : size.height;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/djgarba_herobg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .25),
                  Colors.black.withValues(alpha: .53),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 22 : 54,
                vertical: mobile ? 64 : 96,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DJ & GARBA NIGHT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: SiteColors.cream,
                        fontSize: mobile ? 32 : 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: mobile ? 0 : 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'WHERE EVERY STEP TELLS A STORY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: SiteColors.cream,
                        fontSize: mobile ? 10 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: mobile ? 1.6 : 2.8,
                      ),
                    ),
                    SizedBox(height: mobile ? 44 : 72),
                    _DjGarbaGlassPanel(mobile: mobile),
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

class _DjGarbaGlassPanel extends StatelessWidget {
  const _DjGarbaGlassPanel({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(18));
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DRESS CODE:',
          style: GoogleFonts.montserrat(
            color: SiteColors.cream,
            fontSize: mobile ? 22 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Traditional Wear',
          style: GoogleFonts.montserrat(
            color: SiteColors.cream,
            fontSize: mobile ? 15 : 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: mobile ? 24 : 34),
        Text(
          'JOINING FEE:',
          style: GoogleFonts.montserrat(
            color: SiteColors.cream,
            fontSize: mobile ? 22 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹400 per person',
          style: GoogleFonts.montserrat(
            color: SiteColors.cream,
            fontSize: mobile ? 15 : 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    final description = Text(
      'Step into a night where tradition meets the pulse of a new generation with an electrifying DJ & Garba experience, blending the timeless energy of Navratri with contemporary beats, vibrant rhythms, and an atmosphere made for celebration. This Navratri, the stage isn\'t just for stories - it\'s for you.',
      style: GoogleFonts.montserrat(
        color: SiteColors.cream,
        fontSize: mobile ? 14 : 17,
        height: 1.43,
        fontWeight: FontWeight.w400,
      ),
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(mobile ? 26 : 42),
          decoration: BoxDecoration(
            color: const Color(0x551B120E),
            borderRadius: radius,
            border: Border.all(color: SiteColors.cream.withValues(alpha: .68)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 30),
                    Divider(
                      color: SiteColors.gold.withValues(alpha: .78),
                      height: 1,
                    ),
                    const SizedBox(height: 30),
                    description,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: details),
                    Container(
                      width: 2,
                      height: 290,
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      color: SiteColors.gold.withValues(alpha: .78),
                    ),
                    Expanded(flex: 6, child: description),
                  ],
                ),
        ),
      ),
    );
  }
}

class SponsorVisibilitySection extends StatelessWidget {
  const SponsorVisibilitySection({super.key});
  static const cards = [
    'lib/assets/sponsor_visibility/Group 120.png',
    'lib/assets/sponsor_visibility/Group 121.png',
    'lib/assets/sponsor_visibility/Group 122.png',
    'lib/assets/sponsor_visibility/Group 123.png',
    'lib/assets/sponsor_visibility/Group 124.png',
  ];
  @override
  Widget build(BuildContext context) => _SectionFrame(
    child: LayoutBuilder(
      builder: (context, c) {
        final v = LayoutValues(c.maxWidth);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: v.mobile ? 62 : 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sponsor Visibility',
                style: GoogleFonts.montserrat(
                  color: SiteColors.cream,
                  fontSize: v.mobile ? 48 : 70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Perks and Deliverables of joining Rangaksh as a Sponsor or Partner',
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  color: SiteColors.cream,
                  fontSize: v.mobile ? 16 : 21,
                ),
              ),
              SizedBox(height: v.mobile ? 32 : 48),
              v.mobile
                  ? _AssetGrid(paths: cards, columns: 1, gap: 18)
                  : Column(
                      children: [
                        _AssetGrid(
                          paths: cards.take(4).toList(),
                          columns: 2,
                          gap: 24,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 560,
                          child: Image.asset(
                            cards.last,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    ),
  );
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) => const RangakshFooter();
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final v = LayoutValues(c.maxWidth);
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: v.maxContent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: v.gutter),
            child: child,
          ),
        ),
      );
    },
  );
}

TextStyle _sectionOverline(LayoutValues v) => GoogleFonts.montserrat(
  color: SiteColors.gold,
  fontSize: v.mobile ? 12 : 15,
  fontWeight: FontWeight.w700,
  letterSpacing: v.mobile ? 2 : 3.5,
);
