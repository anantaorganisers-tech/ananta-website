import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecForm extends StatefulWidget {
  const SecForm({super.key});

  @override
  State<SecForm> createState() => _SecFormState();
}

class _SecFormState extends State<SecForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Secratariat Forms are now closed!",
              style: GoogleFonts.montserrat(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Better luck next time",
              style: GoogleFonts.montserrat(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppColors {
  static const Color pageBackground = Color(0xFF5A1725);
  static const Color headerBackground = Color(0xFF530C1F);
  static const Color cardBackground = Color(0xFF5A1725);
  static const Color buttonBackground = Color(0xFF220C0F);
  static const Color border = Color(0xFFE1C28B);
  static const Color textPrimary = Color(0xFFFFF3DE);
  static const Color textMuted = Color(0xFFE7D6B8);
  static const Color inputFill = Color(0x2EFFF3DD);
}
