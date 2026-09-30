import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, lgbt }

// Variabel global yang menyimpan status tema dan bisa diakses dari file mana pun
final ValueNotifier<AppThemeMode> appThemeNotifier = ValueNotifier(AppThemeMode.light);