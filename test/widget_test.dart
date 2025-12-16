import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resep_masakan_app/main.dart';

void main() {
  testWidgets('Aplikasi dapat berjalan dan menampilkan halaman utama', 
      (WidgetTester tester) async {
    // Bangun aplikasi kita
    await tester.pumpWidget( MyApp());

    // Tunggu hingga semua frame selesai di-render
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verifikasi bahwa MaterialApp ditampilkan
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verifikasi bahwa tidak ada exception yang terjadi
    expect(tester.takeException(), isNull);
    
    // Verifikasi bahwa ada teks "Resep Masakan" (judul app)
    expect(find.text('Resep'), findsAtLeast(1));
    
    // Verifikasi bahwa ada tombol search
    expect(find.byIcon(Icons.search), findsOneWidget);
    
    // Verifikasi bahwa ada tombol favorite
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('Test navigasi ke halaman favorit', (WidgetTester tester) async {
    await tester.pumpWidget( MyApp());
    await tester.pumpAndSettle();

    // Tap tombol favorite
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    // Verifikasi bahwa kita berada di halaman favorit
    expect(find.text('Favorit Saya'), findsOneWidget);
  });
}