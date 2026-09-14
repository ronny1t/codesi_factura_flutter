import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() =>
      _CategoriasScreenState();
}

class _CategoriasScreenState
    extends State<CategoriasScreen> {

  List<Categoria> categorias = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    try {
      final resultado =
          await CategoriaService.obtenerCategorias();

      setState(() {
        categorias = resultado;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : categorias.isEmpty
              ? const Center(
                  child: Text(
                    'No hay categorías disponibles',
                  ),
                )
              : ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];

                    return ListTile(
                      leading: const Icon(
                        Icons.category,
                      ),
                      title: Text(categoria.nombre),
                    );
                  },
                ),
    );
  }
}