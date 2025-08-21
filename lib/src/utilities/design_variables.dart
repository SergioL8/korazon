import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------- Final Design Variables ------------

// Colors:
const backgroundColorBM = Color.fromARGB(255, 19, 19, 19);

const korazonColor = Color.fromRGBO(219, 0, 131, 1);

const mainGradient = SweepGradient(
  colors: [
    Color.fromRGBO(219, 0, 131, 1),
    Color.fromRGBO(255, 58, 176, 1),
    Color.fromARGB(255, 103, 132, 224),
    Color.fromRGBO(255, 18, 129, 1),
    Color.fromARGB(255, 162, 0, 138),
    Color.fromRGBO(219, 0, 131, 1),
  ],
  stops: [0.05, 0.20, 0.35, 0.6, 0.95, 0.99],
);

const borderGradient = SweepGradient(
  colors: [
    Color.fromARGB(255, 213, 11, 102),
    Color.fromARGB(255, 159, 4, 113),
    Color.fromARGB(255, 170, 0, 94),
    Color.fromARGB(255, 235, 0, 94),
    Color.fromARGB(255, 132, 90, 189),
    Color.fromARGB(255, 103, 132, 224),
    Color.fromARGB(255, 91, 122, 223),
    Color.fromARGB(255, 132, 90, 189),
    Color.fromARGB(255, 193, 74, 182),
    Color.fromRGBO(255, 58, 176, 1),
    Color.fromARGB(255, 210, 15, 132),
    Color.fromARGB(255, 213, 11, 102),
  ],
  stops: [
    0.05,
    0.1,
    0.23,
    0.40,
    0.50,
    0.52,
    0.60,
    0.65,
    0.80,
    0.85,
    0.95,
    0.99
  ],
);

const linearGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [
    Color.fromARGB(255, 255, 0, 204),
    Color.fromARGB(255, 203, 29, 29),
  ],
);

// const linearGradientOff = LinearGradient(
//   begin: Alignment.bottomLeft,
//   end: Alignment.topRight,
//   colors: [
//     Color(0xFF99007A), // darkened magenta
//     Color(0xFF7A1111), // darkened red
//   ],
// );

const linearGradientOff = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [
    // 255,0,204  →  77,0,61  (≈ #4D003D)
    Color(0xFF4D003D),  // very dark magenta
    // 203,29,29  →  61,9,9   (≈ #3D0909)
    Color(0xFF3D0909),  // very dark red
  ],
);

// Text Styles:
var whiteSubtitle = GoogleFonts.josefinSans(
    fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white);

var whiteBody = GoogleFonts.josefinSans(
    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white);

var whiteTitle = GoogleFonts.josefinSans(
    fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white);

// -------------Old Design Variables (don't use for new development)---------------

// Colors
const korazonColorOld = Color.fromRGBO(250, 177, 177, 1);
const secondaryColor = Color.fromARGB(255, 3, 0, 54);
const tertiaryColor = Colors.white;

const appBarColor = tertiaryColor;
const secondaryColorLP = Color.fromRGBO(3, 0, 54, 0.8);

const dividerColor = Colors.grey;

const allowGreen = Color.fromARGB(255, 23, 177, 30);
const denyRed = Color.fromARGB(255, 177, 23, 23);

// Colors balck mode
const korazonColorBM = Color.fromARGB(255, 226, 130, 229);

// Radius

// border radius of the event cards is 16

// Text Styles
const titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: secondaryColor,
    fontFamily: primaryFont);

const buttonBlackText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: secondaryColor,
    fontFamily: primaryFont);

const double barThickness = 0.5;

// Font styles:
const primaryFont = 'Pacifico';
const double primaryFontSize = 16;
const primaryFontWeight = FontWeight.w800;
const double primaryBorderWidth = 4;
const double navBarElevation = 20;
