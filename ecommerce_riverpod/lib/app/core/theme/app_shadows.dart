import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> floatingBottomBar = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, -4),
      blurRadius: 20,
    ),
  ];
}
