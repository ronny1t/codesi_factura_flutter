import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // ============================================================
  // CARGAR PRODUCTOS
  // ============================================================

  Future<void> cargarProductos() async {
    try {
      setState(() {
        cargando = true;
      });

      final resultado =
          await ProductoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = resultado;
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
            'Error al cargar productos: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FORMULARIO PARA REGISTRAR PRODUCTO
  // ============================================================

  void mostrarFormularioProducto() {
    final codigoController = TextEditingController();
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();
    final ivaController =
        TextEditingController(text: '15');

    bool guardando = false;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.inventory_2),
                  SizedBox(width: 10),
                  Text('Nuevo producto'),
                ],
              ),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ============================
                        // CÓDIGO
                        // ============================

                        TextFormField(
                          controller: codigoController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Código',
                            hintText:
                                'Ej: CER-001',
                            prefixIcon:
                                Icon(Icons.qr_code),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el código';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // ============================
                        // NOMBRE
                        // ============================

                        TextFormField(
                          controller: nombreController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Nombre',
                            hintText:
                                'Ej: Pilsener 600ml',
                            prefixIcon:
                                Icon(Icons.shopping_bag),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el nombre';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // ============================
                        // PRECIO
                        // ============================

                        TextFormField(
                          controller: precioController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Precio unitario',
                            hintText:
                                'Ej: 2.50',
                            prefixIcon:
                                Icon(Icons.attach_money),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el precio';
                            }

                            final precio =
                                double.tryParse(
                              value.replaceAll(
                                ',',
                                '.',
                              ),
                            );

                            if (precio == null) {
                              return 'Ingrese un precio válido';
                            }

                            if (precio < 0) {
                              return 'El precio no puede ser negativo';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // ============================
                        // STOCK
                        // ============================

                        TextFormField(
                          controller: stockController,
                          keyboardType:
                              TextInputType.number,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Stock',
                            hintText:
                                'Ej: 50',
                            prefixIcon:
                                Icon(Icons.inventory),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el stock';
                            }

                            final stock =
                                int.tryParse(value);

                            if (stock == null) {
                              return 'Ingrese un número entero';
                            }

                            if (stock < 0) {
                              return 'El stock no puede ser negativo';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // ============================
                        // IVA
                        // ============================

                        TextFormField(
                          controller: ivaController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction:
                              TextInputAction.done,
                          decoration:
                              const InputDecoration(
                            labelText: 'IVA (%)',
                            hintText:
                                'Ej: 15',
                            prefixIcon:
                                Icon(Icons.percent),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el IVA';
                            }

                            final iva =
                                double.tryParse(
                              value.replaceAll(
                                ',',
                                '.',
                              ),
                            );

                            if (iva == null) {
                              return 'Ingrese un IVA válido';
                            }

                            if (iva < 0 || iva > 100) {
                              return 'El IVA debe estar entre 0 y 100';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BOTONES
              // ==================================================

              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text(
                    'Cancelar',
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          // Validar formulario
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                          });

                          try {
                            final precio =
                                double.parse(
                              precioController.text
                                  .replaceAll(',', '.'),
                            );

                            final stock =
                                int.parse(
                              stockController.text,
                            );

                            final iva =
                                double.parse(
                              ivaController.text
                                  .replaceAll(',', '.'),
                            );

                            // Crear objeto Producto
                            final producto =
                                Producto(
                              idProducto: 0,

                              codigoPrincipal:
                                  codigoController.text
                                      .trim(),

                              nombre:
                                  nombreController.text
                                      .trim(),

                              precioUnitario:
                                  precio,

                              stock: stock,

                              tarifaIva: iva,

                              idCategoria: null,

                              activo: true,
                            );

                            // Enviar al backend
                            await ProductoService
                                .crearProducto(
                              producto,
                            );

                            if (!mounted) return;

                            // Cerrar formulario
                            Navigator.pop(
                              dialogContext,
                            );

                            // Recargar productos
                            await cargarProductos();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Producto registrado correctamente',
                                ),
                                backgroundColor:
                                    Colors.green,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              guardando = false;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al registrar producto: $e',
                                ),
                                backgroundColor:
                                    Colors.red,
                              ),
                            );
                          }
                        },
                  icon: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    guardando
                        ? 'Guardando...'
                        : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TARJETA DEL PRODUCTO
  // ============================================================

  Widget construirProducto(
    Producto producto,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: const Icon(
            Icons.inventory_2,
          ),
        ),

        title: Text(
          producto.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            Text(
              'Código: ${producto.codigoPrincipal ?? 'Sin código'}',
            ),

            Text(
              'Stock: ${producto.stock}',
            ),

            Text(
              'IVA: ${producto.tarifaIva}%',
            ),
          ],
        ),

        trailing: Text(
          '\$${producto.precioUnitario.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        isThreeLine: true,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productos',
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargarProductos,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : productos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 70,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'No hay productos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed:
                            mostrarFormularioProducto,
                        icon: const Icon(
                          Icons.add,
                        ),
                        label: const Text(
                          'Registrar producto',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarProductos,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      top: 8,
                      bottom: 90,
                    ),
                    itemCount:
                        productos.length,
                    itemBuilder:
                        (context, index) {
                      final producto =
                          productos[index];

                      return construirProducto(
                        producto,
                      );
                    },
                  ),
                ),

      // ========================================================
      // BOTÓN AGREGAR
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            mostrarFormularioProducto,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Nuevo producto',
        ),
      ),
    );
  }
}