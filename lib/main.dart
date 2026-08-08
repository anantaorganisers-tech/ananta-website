import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sec_form.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secretariat Application Form',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: AppColors.pageBackground,
      ),
      home: const SecretariatApplicationFormScreen(),
    );
  }
}
