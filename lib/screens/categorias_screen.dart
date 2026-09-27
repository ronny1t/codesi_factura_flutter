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
    setState(() {
      cargando = true;
    });

    try {
      final resultado =
          await CategoriaService.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        categorias = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar las categorías',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,

        title: const Text(
          'Categorías',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: cargarCategorias,
          ),
        ],
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: cargarCategorias,

              child: categorias.isEmpty
                  ? _EstadoVacio()
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [

                        // ENCABEZADO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [

                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    const Text(
                                      'Categorías de productos',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '${categorias.length} categoría${categorias.length == 1 ? '' : 's'} registrada${categorias.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Lista de categorías',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...categorias.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final categoria = entry.value;

                            return _CategoriaCard(
                              numero: index + 1,
                              categoria: categoria,
                            );
                          },
                        ),
                      ],
                    ),
            ),
    );
  }
}


// ============================================================
// TARJETA DE CATEGORÍA
// ============================================================

class _CategoriaCard extends StatelessWidget {

  final int numero;
  final Categoria categoria;

  const _CategoriaCard({
    required this.numero,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),

        leading: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: const Color(0xFF1565C0)
                .withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Icon(
            Icons.category,
            color: Color(0xFF1565C0),
            size: 25,
          ),
        ),

        title: Text(
          categoria.nombre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),

        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Categoría de productos',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFF1565C0)
                .withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Text(
            '#$numero',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// ESTADO VACÍO
// ============================================================

class _EstadoVacio extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.30,
        ),

        const Icon(
          Icons.category_outlined,
          size: 75,
          color: Colors.grey,
        ),

        const SizedBox(height: 20),

        const Center(
          child: Text(
            'No hay categorías disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(
          child: Text(
            'Las categorías registradas aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}