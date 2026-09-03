import 'package:ananta_website/ananta_page.dart';
import 'package:ananta_website/participant_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

import 'rangaksh_page.dart';
import 'one_act_page.dart';
import 'sec_form.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final browserPath = Uri.parse(web.window.location.href).path;
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
        '/one-act' => const OneActPage(),
        _ => const AnantaPage(),
      },
      routes: {
        '/rangaksh': (_) => const RangakshPage(),
        '/rangaksh/themes': (_) => const RangakshPage(initialSection: 'themes'),
        '/secretariat': (_) => const SecretariatApplicationFormScreen(),
        '/participant': (_) => const ParticipantForm(),
        '/one-act': (_) => const OneActPage(),
      },
    );
  }
}
