import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnantaPortfolioAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AnantaPortfolioAppBar({
    super.key,
    required this.mobile,
    required this.onFounders,
    required this.onEvents,
    required this.onContact,
  });

  final bool mobile;
  final VoidCallback onFounders;
  final VoidCallback onEvents;
  final VoidCallback onContact;

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
            mobile ? 9 : 12,
            mobile ? 8 : 16,
            mobile ? 9 : 12,
            mobile ? 8 : 16,
          ),
          child: _PortfolioNav(
            mobile: mobile,
            onFounders: onFounders,
            onEvents: onEvents,
            onContact: onContact,
          ),
        ),
      ),
    );
  }
}

class _PortfolioNav extends StatelessWidget {
  const _PortfolioNav({
    required this.mobile,
    required this.onFounders,
    required this.onEvents,
    required this.onContact,
  });

  final bool mobile;
  final VoidCallback onFounders;
  final VoidCallback onEvents;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final identity = Row(
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            color: _PortfolioColors.cream,
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
                Expanded(child: identity),
                PopupMenuButton<_PortfolioNavAction>(
                  tooltip: 'Navigation menu',
                  color: _PortfolioColors.hero,
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: _PortfolioColors.cream,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: _PortfolioColors.border),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _PortfolioNavAction.founders:
                        onFounders();
                      case _PortfolioNavAction.events:
                        onEvents();
                      case _PortfolioNavAction.contact:
                        onContact();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _PortfolioNavAction.founders,
                      child: _MobileMenuLabel('FOUNDERS'),
                    ),
                    PopupMenuItem(
                      value: _PortfolioNavAction.events,
                      child: _MobileMenuLabel('EVENTS'),
                    ),
                    PopupMenuItem(
                      value: _PortfolioNavAction.contact,
                      child: _MobileMenuLabel('CONTACT'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                identity,
                const Spacer(),
                _NavButton(label: 'FOUNDERS', onTap: onFounders),
                const SizedBox(width: 10),
                _NavButton(label: 'EVENTS', onTap: onEvents),
                const SizedBox(width: 10),
                _NavButton(label: 'CONTACT', onTap: onContact),
              ],
            ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hovered ? 1.04 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _PortfolioColors.cream.withValues(alpha: .28),
                ),
                borderRadius: BorderRadius.circular(9),
                color: Colors.white.withValues(alpha: _hovered ? .1 : .04),
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.montserrat(
                  color: _PortfolioColors.cream,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PortfolioNavAction { founders, events, contact }

class _MobileMenuLabel extends StatelessWidget {
  const _MobileMenuLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.montserrat(
      color: _PortfolioColors.cream,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    ),
  );
}

class _PortfolioColors {
  static const hero = Color(0xFF5A1725);
  static const cream = Color(0xFFF3E8D0);
  static const border = Color(0xBB8B8383);
}
