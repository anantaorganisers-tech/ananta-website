import 'package:ananta_website/ananta_page.dart';
import 'package:ananta_website/participant_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

import 'one_act_page.dart';
import 'one_act_submission.dart';
import 'payment_gateway_page.dart';
import 'rangaksh_page.dart';
import 'refund_policy_page.dart';
import 'sec_form.dart';
import 'stall_setup_form.dart';
import 'sponsorship_form.dart';
import 'terms_of_service_page.dart';
import 'visitor_pass_submission.dart';

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
      '/paydesk' => PaydeskPage(
        product: PaydeskProduct.fromCode(browserUri.queryParameters['prod']),
      ),
      '/paymentgateway' => const PaydeskPage(product: PaydeskProduct.oneAct),
      '/rangaksh/themes' => const RangakshPage(initialSection: 'themes'),
      '/rangaksh' => const RangakshPage(),
      '/secretariat' => const SecretariatApplicationFormScreen(),
      '/talent-hunt-form' => const ParticipantForm(),
      '/talent-hunt' => const OneActPage(),
      '/participant' => const ParticipantForm(),
      '/one-act' => const OneActPage(),
      '/sponsor-form' => const SponsorshipForm(),
      '/stall-setup' => const StallSetupForm(),
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
        colorSchemeSeed: AppColors.textPrimary,
        scaffoldBackgroundColor: AppColors.pageBackground,
      ),
      home: _StartupLoadingGate(child: homePage),
      routes: {
        '/rangaksh': (_) => const RangakshPage(),
        '/rangaksh/themes': (_) => const RangakshPage(initialSection: 'themes'),
        '/secretariat': (_) => const SecretariatApplicationFormScreen(),
        '/talent-hunt-form': (_) => const ParticipantForm(),
        '/talent-hunt': (_) => const OneActPage(),
        '/participant': (_) => const ParticipantForm(),
        '/one-act': (_) => const OneActPage(),
        '/sponsor-form': (_) => const SponsorshipForm(),
        '/stall-setup': (_) => const StallSetupForm(),
        '/refund-policy': (_) => const RefundPolicyPage(),
        '/tos': (_) => const TermsOfServicePage(),
        '/paydesk': (_) => const PaydeskPage(product: PaydeskProduct.oneAct),
        '/paymentgateway': (_) =>
            const PaydeskPage(product: PaydeskProduct.oneAct),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri?.path != '/paydesk') return null;

        final arguments = settings.arguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PaydeskPage(
            product: PaydeskProduct.fromCode(uri?.queryParameters['prod']),
            registration: arguments is OneActRegistration ? arguments : null,
            visitor: arguments is VisitorPassRegistrant ? arguments : null,
          ),
        );
      },
    );
  }
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
