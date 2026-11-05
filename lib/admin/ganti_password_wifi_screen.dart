import 'package:flutter/material.dart';
import 'package:app_kampus/core/theme_builder.dart';

class GantiPasswordWifiScreen extends StatelessWidget {
  const GantiPasswordWifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Ganti Password Wifi', style: TextStyle(color: p.textPrimary)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: Center(child: Text('Formulir Ganti Password Wifi Kampus', style: TextStyle(color: p.textPrimary))),
        ),
      ),
    );
  }
}
