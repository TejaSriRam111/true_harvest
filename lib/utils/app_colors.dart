import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  static const Color darkGreen = Color(0xFF15352c);
  static const Color lightBackground = Color(0xFFF6F3ED);
  static const Color primary = Color(0xFFD1B36C);
  static const Color cream = Color(0xFFFDF4E3);
  static const Color washedGreen = Color(0xFF3B5951);

  //textColors
  static const Color primaryTxtClr = Color(0xFFd0ad6d);

  // More scalable colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;

  static const Color error = Colors.redAccent;

  //common colors
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;

  static const Color white = Colors.white;
  static const Color red = Colors.red;
  static const Color grey = Colors.grey;

  static const MaterialColor darkGreenSwatch =
      MaterialColor(0xFF15352C, <int, Color>{
        50: Color(0xFFE5EFEA),
        100: Color(0xFFC0D6CB),
        200: Color(0xFF99BAA9),
        300: Color(0xFF739E87),
        400: Color(0xFF53886D),
        500: Color(0xFF337253),
        600: Color(0xFF2D684B),
        700: Color(0xFF255B41),
        800: Color(0xFF1E4F38),
        900: Color(0xFF15352C),
      });
}
