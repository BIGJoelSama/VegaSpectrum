// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // Importamos Provider

// Importamos tu app principal y el proveedor
import 'package:vega_spectrum_v2/main.dart'; 
import 'package:vega_spectrum_v2/providers/theme_provider.dart';

void main() {
  // El nombre del test es solo descriptivo, no afecta la ejecución
  testWidgets('Smoke test for VegaSpectrumApp', (WidgetTester tester) async {
    // ✅ CORRECCIÓN 1: Envolvemos la app con el Provider necesario
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        // ✅ CORRECCIÓN 2: Usamos el nombre correcto de tu app ('VegaSpectrumApp')
        // ✅ CORRECCIÓN 3: Eliminamos 'const' porque VegaSpectrumApp usa Consumer
        child: VegaSpectrumApp(), 
      ),
    );

    // --- NOTA IMPORTANTE ---
    // Las siguientes líneas probablemente fallen porque tu app ya no tiene
    // un contador que muestre '0' o '1', ni un botón de '+'.
    // Esto es normal. El objetivo por ahora es que el archivo compile sin errores.
    
    // expect(find.text('0'), findsOneWidget); 
    // expect(find.text('1'), findsNothing);
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}