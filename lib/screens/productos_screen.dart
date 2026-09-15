import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() =>
      _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    try {
      final resultado =
          await ProductoService.obtenerProductos();

      setState(() {
        productos = resultado;
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
        title: const Text('Productos'),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : productos.isEmpty
              ? const Center(
                  child: Text('No hay productos'),
                )
              : ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];

                    return ListTile(
                      leading: const Icon(
                        Icons.inventory,
                      ),
                      title: Text(producto.nombre),
                      subtitle: Text(
                        'Código: ${producto.codigoPrincipal ?? 'Sin código'}\n'
                        'Stock: ${producto.stock}',
                      ),
                      trailing: Text(
                        '\$${producto.precioUnitario.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
    );
  }
}