import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH8 = SizedBox(height: s);
  static const SizedBox gapH12 = SizedBox(height: m);
  static const SizedBox gapH16 = SizedBox(height: l);
  static const SizedBox gapH20 = SizedBox(height: xl);
  static const SizedBox gapH24 = SizedBox(height: xxl);
  static const SizedBox gapH32 = SizedBox(height: xxxl);

  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW8 = SizedBox(width: s);
  static const SizedBox gapW12 = SizedBox(width: m);
  static const SizedBox gapW16 = SizedBox(width: l);
  static const SizedBox gapW20 = SizedBox(width: xl);
  static const SizedBox gapW24 = SizedBox(width: xxl);
}
