import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/main.dart';

void main() {
  testWidgets('CavaPosApp tablet mode smoke test', (WidgetTester tester) async {
    // Set tablet landscape resolution (1280x800)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build POS application
    await tester.pumpWidget(const CavaPosApp());
    await tester.pumpAndSettle();

    // Verify CAVA POS branding and essential UI elements in tablet master-detail view
    expect(find.text('CAVA POS'), findsOneWidget);
    expect(find.text('Semua Menu'), findsOneWidget);
    expect(find.text('Dine In'), findsOneWidget);
    expect(find.text('Take Away'), findsOneWidget);
    expect(find.text('Keranjang Kosong'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Analitik'), findsOneWidget);
    expect(find.text('Keuangan'), findsOneWidget);
  });
}
