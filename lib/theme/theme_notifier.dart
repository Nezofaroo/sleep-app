import 'package:flutter/material.dart';

/// Global theme mode notifier — listen to this to rebuild on theme change.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
