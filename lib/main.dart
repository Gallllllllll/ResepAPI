import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep_masakan_app/screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hilangkan banner debug
      debugShowCheckedModeBanner: false,

      // Judul aplikasi
      title: 'Yummy Recipes',

      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.orange,

        // Gunakan Google Font Rubik secara global
        textTheme: GoogleFonts.rubikTextTheme(
          Theme.of(context).textTheme,
        ),

        // Tema AppBar global
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Tema BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedLabelStyle:
              GoogleFonts.rubik(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.rubik(fontWeight: FontWeight.w500),
        ),
      ),

      // Halaman utama aplikasi
      home: const SplashScreen(),
    );
  }
}
