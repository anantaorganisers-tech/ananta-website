import 'package:ananta_website/ananta_page.dart';
import 'package:ananta_website/participant_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

import 'rangaksh_page.dart';
import 'one_act_page.dart';
import 'payment_gateway_page.dart';
import 'sec_form.dart';
import 'one_act_submission.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ananta Organizers',
      theme: ThemeData(
        useMaterial3: true,

        textTheme: GoogleFonts.baloo2TextTheme(),
        colorSchemeSeed: AppColors.textPrimary,
        scaffoldBackgroundColor: AppColors.pageBackground,
      ),
      home: switch (browserPath) {
        '/rangaksh/themes' => const RangakshPage(initialSection: 'themes'),
        '/rangaksh' => const RangakshPage(),
        '/secretariat' => const SecretariatApplicationFormScreen(),
        '/participant' => const ParticipantForm(),
        '/paydesk' => PaydeskPage(
          product: PaydeskProduct.fromCode(browserUri.queryParameters['prod']),
        ),
        '/paymentgateway' => const PaydeskPage(product: PaydeskProduct.oneAct),
        '/one-act' => const OneActPage(),
        _ => const AnantaPage(),
      },
      routes: {
        '/rangaksh': (_) => const RangakshPage(),
        '/rangaksh/themes': (_) => const RangakshPage(initialSection: 'themes'),
        '/secretariat': (_) => const SecretariatApplicationFormScreen(),
        '/participant': (_) => const ParticipantForm(),
        '/paydesk': (_) => const PaydeskPage(product: PaydeskProduct.oneAct),
        '/paymentgateway': (_) =>
            const PaydeskPage(product: PaydeskProduct.oneAct),
        '/one-act': (_) => const OneActPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri?.path != '/paydesk') return null;

        final registration = settings.arguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PaydeskPage(
            product: PaydeskProduct.fromCode(uri?.queryParameters['prod']),
            registration: registration is OneActRegistration
                ? registration
                : null,
            visitor: registration is VisitorPassRegistrant
                ? registration
                : null,
          ),
        );
      },
    );
  }
}
