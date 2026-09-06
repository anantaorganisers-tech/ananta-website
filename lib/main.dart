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
import 'sec_form.dart';
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
        '/paydesk' => PaydeskPage(
          product: PaydeskProduct.fromCode(browserUri.queryParameters['prod']),
        ),
        '/paymentgateway' => const PaydeskPage(product: PaydeskProduct.oneAct),
        '/rangaksh/themes' => const RangakshPage(initialSection: 'themes'),
        '/rangaksh' => const RangakshPage(),
        '/secretariat' => const SecretariatApplicationFormScreen(),
        '/participant' => const ParticipantForm(),
        '/one-act' => const OneActPage(),
        _ => const AnantaPage(),
      },
      routes: {
        '/rangaksh': (_) => const RangakshPage(),
        '/rangaksh/themes': (_) => const RangakshPage(initialSection: 'themes'),
        '/secretariat': (_) => const SecretariatApplicationFormScreen(),
        '/participant': (_) => const ParticipantForm(),
        '/one-act': (_) => const OneActPage(),
        '/paydesk': (_) => const PaydeskPage(product: PaydeskProduct.oneAct),
        '/paymentgateway': (_) =>
            const PaydeskPage(product: PaydeskProduct.oneAct),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.path == '/paydesk') {
          final arguments = settings.arguments;
          return MaterialPageRoute(
            builder: (_) => PaydeskPage(
              product: PaydeskProduct.fromCode(uri.queryParameters['prod']),
              registration: arguments is OneActRegistration ? arguments : null,
              visitor: arguments is VisitorPassRegistrant ? arguments : null,
            ),
          );
        }
        return null;
      },
    );
  }
}
