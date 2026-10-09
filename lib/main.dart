import 'package:ananta_website/ananta_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

import 'one_act_page.dart';
import 'rangaksh_page.dart';
import 'refund_policy_page.dart';
import 'terms_of_service_page.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final browserUri = Uri.parse(web.window.location.href);
    final browserPath = browserUri.path;
    final homePage = switch (browserPath) {
      '/rangaksh/themes' => const _RangakshTitle(
        child: RangakshPage(initialSection: 'themes'),
      ),
      '/rangaksh' => const _RangakshTitle(child: RangakshPage()),
      '/talent-hunt' => const OneActPage(),
      '/one-act' => const OneActPage(),
      '/refund-policy' => const RefundPolicyPage(),
      '/tos' => const TermsOfServicePage(),
      _ => const AnantaPage(),
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ananta Organizers',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.baloo2TextTheme(),
        colorSchemeSeed: const Color(0xFFFFF4DE),
        scaffoldBackgroundColor: const Color(0xFF5A061F),
      ),
      home: _StartupLoadingGate(child: homePage),
      routes: {
        '/rangaksh': (_) => const _RangakshTitle(child: RangakshPage()),
        '/rangaksh/themes': (_) =>
            const _RangakshTitle(child: RangakshPage(initialSection: 'themes')),
        '/talent-hunt': (_) => const OneActPage(),
        '/one-act': (_) => const OneActPage(),
        '/refund-policy': (_) => const RefundPolicyPage(),
        '/tos': (_) => const TermsOfServicePage(),
      },
    );
  }
}

class _RangakshTitle extends StatelessWidget {
  const _RangakshTitle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Title(
    title: 'Rangaksh 2026- Ananta Organizers',
    color: const Color(0xFF5A061F),
    child: child,
  );
}

class _StartupLoadingGate extends StatefulWidget {
  const _StartupLoadingGate({required this.child});

  final Widget child;

  @override
  State<_StartupLoadingGate> createState() => _StartupLoadingGateState();
}

class _StartupLoadingGateState extends State<_StartupLoadingGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 260),
    child: _ready ? widget.child : const _MaroonLoadingScreen(),
  );
}

class _MaroonLoadingScreen extends StatelessWidget {
  const _MaroonLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFF5A061F),
    body: Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          strokeWidth: 3.4,
          color: Color(0xFFFFF3DE),
        ),
      ),
    ),
  );
}
