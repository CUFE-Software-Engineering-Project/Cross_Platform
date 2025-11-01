import 'package:flutter/material.dart';

class Palette {
  // Background Colors
  static const Color background = Color.fromRGBO(
    0,
    0,
    0,
    1.0,
  ); // Pure black background
  static const Color greycolor = Color.fromARGB(255, 151, 152, 153);
  static const Color cardBackground = Color.fromRGBO(
    22,
    24,
    28,
    1.0,
  ); // Card backgrounds
  static const Color modalBackground = Color.fromRGBO(
    32,
    35,
    39,
    1.0,
  ); // Bottom sheets / modals
  static const Color chatme = const Color.fromARGB(255, 79, 174, 238);
  static const Color chathim = const Color.fromARGB(255, 54, 59, 63);
  // Primary Colors
  static const Color primary = Color.fromRGBO(
    29,
    155,
    240,
    1.0,
  ); // Main blue color
  static const Color primaryHover = Color.fromRGBO(
    26,
    140,
    216,
    1.0,
  ); // Blue on hover
  static const Color primaryPressed = Color.fromRGBO(
    21,
    112,
    173,
    1.0,
  ); // Blue when pressed

  // Text Colors
  static const Color textPrimary = Color.fromRGBO(
    231,
    233,
    234,
    1.0,
  ); // Main text
  static const Color textWhite = Color.fromRGBO(
    255,
    255,
    255,
    1.0,
  ); // For titles and usernames
  static const Color textSecondary = Color.fromRGBO(
    113,
    118,
    123,
    1.0,
  ); // Secondary text
  static const Color textTertiary = Color.fromRGBO(
    83,
    100,
    113,
    1.0,
  ); // Less important text
  static const Color textDisabled = Color.fromRGBO(
    64,
    68,
    75,
    1.0,
  ); // Disabled text

  // Icon Colors
  static const Color icons = Color.fromRGBO(
    113,
    118,
    123,
    1.0,
  ); // Default icons
  static const Color iconsActive = Color.fromRGBO(
    231,
    233,
    234,
    1.0,
  ); // Active icons

  // Border Colors
  static const Color border = Color.fromRGBO(47, 51, 54, 1.0); // Default border
  static const Color borderHover = Color.fromARGB(255, 85, 88, 92);
  static const Color divider = Color.fromRGBO(47, 51, 54, 1.0); // Divider lines

  // Interaction Colors
  static const Color like = Color.fromRGBO(249, 24, 128, 1.0); // Like button
  static const Color likeHover = Color.fromRGBO(
    249,
    24,
    128,
    0.1,
  ); // Like hover background

  static const Color retweet = Color.fromRGBO(
    0,
    186,
    124,
    1.0,
  ); // Retweet button
  static const Color retweetHover = Color.fromRGBO(
    0,
    186,
    124,
    0.1,
  ); // Retweet hover background

  static const Color reply = Color.fromRGBO(113, 118, 123, 1.0); // Reply button
  static const Color replyHover = Color.fromRGBO(
    29,
    155,
    240,
    0.1,
  ); // Reply hover background

  static const Color share = Color.fromRGBO(113, 118, 123, 1.0); // Share button
  static const Color shareHover = Color.fromRGBO(
    29,
    155,
    240,
    0.1,
  ); // Share hover background

  // Status Colors
  static const Color success = Color.fromRGBO(
    0,
    186,
    124,
    1.0,
  ); // Success messages / states
  static const Color error = Color.fromRGBO(
    244,
    33,
    46,
    1.0,
  ); // Error messages / states
  static const Color warning = Color.fromRGBO(
    255,
    212,
    0,
    1.0,
  ); // Warning messages / states
  static const Color info = Color.fromRGBO(
    29,
    155,
    240,
    1.0,
  ); // Info messages / states

  // Additional Colors
  static const Color verified = Color.fromRGBO(
    29,
    155,
    240,
    1.0,
  ); // Verified badge

  static const Color premium = Color.fromRGBO(
    255,
    212,
    0,
    1.0,
  ); // Premium feature highlight

  // Input Colors
  static const Color inputBackground = Color.fromRGBO(
    32,
    35,
    39,
    1.0,
  ); // Input field background
  static const Color inputBorder = Color.fromRGBO(
    113,
    118,
    123,
    1.0,
  ); // Input border
  static const Color inputBorderFocused = Color.fromRGBO(
    29,
    155,
    240,
    1.0,
  ); // Input border when focused

  // Overlay Colors
  static const Color overlay = Color.fromRGBO(
    0,
    0,
    0,
    0.4,
  ); // Semi-transparent overlay
  static const Color shimmer = Color.fromRGBO(
    47,
    51,
    54,
    1.0,
  ); // Shimmer effect for loading

  // Gradients
  static const List<Color> primaryGradient = [
    Color.fromRGBO(29, 155, 240, 1.0),
    Color.fromRGBO(26, 140, 216, 1.0),
  ]; // Primary gradient for backgrounds or buttons
  static const Color kBrandBlue = Color(0xFF1D9BF0);
  static const Color kBrandPurple = Color(0xFF8B5CF6);
  static const Color container_message_color = const Color.fromARGB(
    255,
    28,
    34,
    41,
  );
  static const Color kDimIconwhite = Color.fromARGB(255, 184, 193, 202);
  static const Color kBrandRed = Color(0xFFF4212E);
}
