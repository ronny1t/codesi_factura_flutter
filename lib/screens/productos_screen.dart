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

  static const Color azul = Color(0xFF1565C0);
  static const Color fondo = Color(0xFFF5F7FA);

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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              titlePadding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                10,
              ),

              contentPadding:
                  const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                10,
              ),

              actionsPadding:
                  const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                20,
              ),

              // ==================================================
              // TÍTULO
              // ==================================================

              title: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: azul.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: azul,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo producto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          'Ingrese los datos del producto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight:
                                FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ==================================================
              // FORMULARIO
              // ==================================================

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // CÓDIGO
                        TextFormField(
                          controller:
                              codigoController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Código',
                            hint: 'Ej: CER-001',
                            icon: Icons.qr_code_2,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el código';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // NOMBRE
                        TextFormField(
                          controller:
                              nombreController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Nombre',
                            hint: 'Ej: Pilsener 600ml',
                            icon:
                                Icons.shopping_bag_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el nombre';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // PRECIO
                        TextFormField(
                          controller:
                              precioController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Precio unitario',
                            hint: 'Ej: 2.50',
                            icon:
                                Icons.attach_money,
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

                        const SizedBox(height: 14),

                        // STOCK
                        TextFormField(
                          controller:
                              stockController,
                          keyboardType:
                              TextInputType.number,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Stock',
                            hint: 'Ej: 50',
                            icon:
                                Icons.inventory_outlined,
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

                        const SizedBox(height: 14),

                        // IVA
                        TextFormField(
                          controller: ivaController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction:
                              TextInputAction.done,
                          decoration:
                              _inputDecoration(
                            label: 'IVA (%)',
                            hint: 'Ej: 15',
                            icon: Icons.percent,
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
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.grey.shade700,
                  ),
                  child: const Text(
                    'Cancelar',
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey
                              .currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                          });

                          try {
                            final precio =
                                double.parse(
                              precioController
                                  .text
                                  .replaceAll(
                                ',',
                                '.',
                              ),
                            );

                            final stock =
                                int.parse(
                              stockController
                                  .text,
                            );

                            final iva =
                                double.parse(
                              ivaController
                                  .text
                                  .replaceAll(
                                ',',
                                '.',
                              ),
                            );

                            final producto =
                                Producto(
                              idProducto: 0,
                              codigoPrincipal:
                                  codigoController
                                      .text
                                      .trim(),
                              nombre:
                                  nombreController
                                      .text
                                      .trim(),
                              precioUnitario:
                                  precio,
                              stock: stock,
                              tarifaIva: iva,
                              idCategoria: null,
                              activo: true,
                            );

                            await ProductoService
                                .crearProducto(
                              producto,
                            );

                            if (!mounted) return;

                            Navigator.pop(
                              dialogContext,
                            );

                            await cargarProductos();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .check_circle,
                                      color:
                                          Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Producto registrado correctamente',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor:
                                    Colors.green.shade700,
                                behavior:
                                    SnackBarBehavior
                                        .floating,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
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
                                behavior:
                                    SnackBarBehavior
                                        .floating,
                              ),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

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
                      : const Icon(
                          Icons.save_outlined,
                        ),

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
  // DECORACIÓN DE INPUTS
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: azul,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: azul,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DEL PRODUCTO
  // ============================================================

  Widget construirProducto(
    Producto producto,
  ) {
    final bool stockBajo =
        producto.stock <= 5;

    final bool sinStock =
        producto.stock <= 0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Row(
              children: [

                // ==================================================
                // ICONO
                // ==================================================

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: azul.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: azul,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 15),

                // ==================================================
                // INFORMACIÓN
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 14,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              producto
                                      .codigoPrincipal ??
                                  'Sin código',
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Row(
                        children: [

                          // STOCK
                          _datoProducto(
                            icono:
                                Icons.inventory_2_outlined,
                            texto:
                                'Stock ${producto.stock}',
                            color: sinStock
                                ? Colors.red
                                : stockBajo
                                    ? Colors.orange
                                    : Colors.green,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          // IVA
                          _datoProducto(
                            icono:
                                Icons.percent,
                            texto:
                                'IVA ${producto.tarifaIva}%',
                            color: Colors.grey
                                .shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ==================================================
                // PRECIO
                // ==================================================

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '\$${producto.precioUnitario.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: azul,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    if (sinStock)
                      _estadoProducto(
                        'Sin stock',
                        Colors.red,
                      )
                    else if (stockBajo)
                      _estadoProducto(
                        'Stock bajo',
                        Colors.orange,
                      )
                    else
                      _estadoProducto(
                        'Disponible',
                        Colors.green,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATO DEL PRODUCTO
  // ============================================================

  Widget _datoProducto({
    required IconData icono,
    required String texto,
    required Color color,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texto,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _estadoProducto(
    String texto,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget construirEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: azul.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: azul,
                size: 50,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No hay productos',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Todavía no tienes productos registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed:
                  mostrarFormularioProducto,
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Registrar producto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: azul,
        foregroundColor: Colors.white,

        title: const Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 24,
            ),

            SizedBox(width: 10),

            Text(
              'Productos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando
                ? null
                : cargarProductos,
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: azul,
              ),
            )
          : productos.isEmpty
              ? construirEstadoVacio()
              : RefreshIndicator(
                  color: azul,
                  onRefresh:
                      cargarProductos,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      100,
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
      // BOTÓN NUEVO PRODUCTO
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            mostrarFormularioProducto,
        backgroundColor: azul,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Nuevo producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}