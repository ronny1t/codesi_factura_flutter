import 'package:flutter/material.dart';
import 'screens/categorias_screen.dart';

void main() {
  runApp(const CodesiFacturaApp());
}

class CodesiFacturaApp extends StatelessWidget {
  const CodesiFacturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Codesi Factura',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      home: const CategoriasScreen(),
    );
  }
}