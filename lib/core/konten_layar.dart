import 'package:flutter/material.dart';

/// Lebar maksimum isi halaman saat jendela lebar.
///
/// 1100dp cukup untuk dua kolom kartu tanpa membuat baris teks melewati
/// ~90 karakter, yang membuat mata sulit kembali ke awal baris.
const double kLebarKontenMaks = 1100;

/// Ambang lebar untuk memakai bantalan gaya desktop.
///
/// Sama dengan ambang dashboard (`_ConstraintData.minDesktop`) dan ambang
/// rail navigasi (`_minLebarDesktop`), supaya seluruh aplikasi berubah bentuk
/// pada lebar jendela yang sama.
const double kAmbangLayarLebar = 980;

/// Bungkus isi halaman supaya kolomnya tidak ikut meregang mengikuti jendela.
///
/// Di HP bantalan tetap seperti semula. Di Web/laptop isi dipusatkan pada
/// lebar maksimum [maxWidth] dengan bantalan lebih lega. Tanpa pembungkus ini
/// setiap kartu daftar ikut melebar selebar jendela: barisnya jadi sangat
/// lonjong, tinggi kartu membengkak, dan jarak antar elemen tidak lagi terbaca
/// sebagai satu kelompok.
class KontenLayar extends StatelessWidget {
  const KontenLayar({
    super.key,
    required this.child,
    this.maxWidth = kLebarKontenMaks,
    this.paddingHp = const EdgeInsets.fromLTRB(16, 16, 16, 28),
    this.paddingLebar = const EdgeInsets.fromLTRB(28, 28, 28, 40),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry paddingHp;
  final EdgeInsetsGeometry paddingLebar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layarLebar = constraints.maxWidth >= kAmbangLayarLebar;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: layarLebar ? paddingLebar : paddingHp,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Apakah lebar [context] termasuk layar lebar (Web/laptop).
///
/// Dipakai halaman yang butuh mengganti susunannya sendiri, bukan hanya
/// membatasi lebar kolomnya.
bool layarLebar(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kAmbangLayarLebar;
