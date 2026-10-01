import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';
import '../services/api_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> productos = [];
  List<Producto> productosDesactivados = [];
  List<Categoria> categorias = [];

  bool cargando = true;
  bool cargandoDesactivados = false;
  bool mostrandoDesactivados = false;

  String busqueda = '';

  // ============================================================
  // PERMISOS SEGÚN ROL
  // ============================================================

  bool get puedeGestionarProductos {
    return ApiService.esAdministrador ||
        ApiService.esBodega;
  }

  static const Color azul = Color(0xFF1565C0);
  static const Color fondo = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  // ============================================================
  // CARGAR PRODUCTOS ACTIVOS Y CATEGORÍAS
  // ============================================================

  Future<void> cargarDatos() async {
    if (!mounted) {
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final productosResultado =
          await ProductoService.obtenerProductos();

      final categoriasResultado =
          await CategoriaService.obtenerCategorias();

      if (!mounted) {
        return;
      }

      setState(() {
        productos = productosResultado;
        categorias = categoriasResultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

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
  // CARGAR PRODUCTOS DESACTIVADOS
  // ============================================================

  Future<void> cargarProductosDesactivados() async {
    if (!puedeGestionarProductos) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      cargandoDesactivados = true;
    });

    try {
      final resultado =
          await ProductoService.obtenerProductosDesactivados();

      if (!mounted) {
        return;
      }

      setState(() {
        productosDesactivados = resultado;
        cargandoDesactivados = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargandoDesactivados = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar productos desactivados: $e',
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
  // RECARGAR LA VISTA ACTUAL
  // ============================================================

  Future<void> recargarVistaActual() async {
    if (mostrandoDesactivados) {
      await cargarProductosDesactivados();
    } else {
      await cargarDatos();
    }
  }

  // ============================================================
  // LISTA ACTUAL FILTRADA
  // ============================================================

  List<Producto> get productosFiltrados {
    final lista = mostrandoDesactivados
        ? productosDesactivados
        : productos;

    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return lista;
    }

    return lista.where((producto) {
      final nombre =
          producto.nombre.toLowerCase();

      final codigo =
          producto.codigoPrincipal?.toLowerCase() ?? '';

      return nombre.contains(texto) ||
          codigo.contains(texto);
    }).toList();
  }

  // ============================================================
  // NOMBRE DE CATEGORÍA
  // ============================================================

  String nombreCategoria(int? idCategoria) {
    if (idCategoria == null) {
      return 'Sin categoría';
    }

    for (final categoria in categorias) {
      if (categoria.idCategoria == idCategoria) {
        return categoria.nombre;
      }
    }

    return 'Sin categoría';
  }

  // ============================================================
  // CAMBIAR ENTRE ACTIVOS Y DESACTIVADOS
  // ============================================================

  Future<void> cambiarVista(bool desactivados) async {
    if (desactivados &&
        !puedeGestionarProductos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para ver productos desactivados.',
          ),
        ),
      );

      return;
    }

    setState(() {
      mostrandoDesactivados = desactivados;
      busqueda = '';
    });

    if (desactivados) {
      await cargarProductosDesactivados();
    }
  }

  // ============================================================
  // FORMULARIO CREAR / EDITAR
  // ============================================================

  void mostrarFormularioProducto({
    Producto? producto,
  }) {
    if (!puedeGestionarProductos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para gestionar productos.',
          ),
        ),
      );

      return;
    }

    final bool esEdicion = producto != null;

    final codigoController =
        TextEditingController(
      text: producto?.codigoPrincipal ?? '',
    );

    final nombreController =
        TextEditingController(
      text: producto?.nombre ?? '',
    );

    final precioController =
        TextEditingController(
      text: producto != null
          ? producto.precioUnitario
              .toStringAsFixed(2)
          : '',
    );

    final stockController =
        TextEditingController(
      text: producto != null
          ? producto.stock.toString()
          : '',
    );

    final ivaController =
        TextEditingController(
      text: producto != null
          ? producto.tarifaIva
              .toStringAsFixed(2)
          : '15',
    );

    int? categoriaSeleccionada =
        producto?.idCategoria;

    bool activo =
        producto?.activo ?? true;

    bool guardando = false;

    final formKey =
        GlobalKey<FormState>();

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
                borderRadius:
                    BorderRadius.circular(24),
              ),
              titlePadding:
                  const EdgeInsets.fromLTRB(
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
              title: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: azul.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: azul,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          esEdicion
                              ? 'Editar producto'
                              : 'Nuevo producto',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          esEdicion
                              ? 'Modifique los datos del producto'
                              : 'Ingrese los datos del producto',
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller:
                              codigoController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Código',
                            hint: 'Ej: CER-001',
                            icon:
                                Icons.qr_code_2,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Ingrese el código';
                            }

                            if (value
                                    .trim()
                                    .length >
                                50) {
                              return 'Máximo 50 caracteres';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        TextFormField(
                          controller:
                              nombreController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(
                            label: 'Nombre',
                            hint:
                                'Ej: Pilsener 600ml',
                            icon: Icons
                                .shopping_bag_outlined,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Ingrese el nombre';
                            }

                            if (value
                                    .trim()
                                    .length >
                                150) {
                              return 'Máximo 150 caracteres';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        DropdownButtonFormField<
                            int?>(
                          value:
                              categoriaSeleccionada,
                          isExpanded: true,
                          decoration:
                              _inputDecoration(
                            label: 'Categoría',
                            hint:
                                'Seleccione una categoría',
                            icon: Icons
                                .category_outlined,
                          ),
                          items: [
                            const DropdownMenuItem<
                                int?>(
                              value: null,
                              child: Text(
                                'Sin categoría',
                              ),
                            ),
                            ...categorias
                                .where(
                                  (
                                    categoria,
                                  ) =>
                                      categoria
                                          .activo,
                                )
                                .map(
                                  (
                                    categoria,
                                  ) {
                                    return DropdownMenuItem<
                                        int?>(
                                      value: categoria
                                          .idCategoria,
                                      child: Text(
                                        categoria
                                            .nombre,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    );
                                  },
                                ),
                          ],
                          onChanged:
                              guardando
                                  ? null
                                  : (value) {
                                      setDialogState(
                                        () {
                                          categoriaSeleccionada =
                                              value;
                                        },
                                      );
                                    },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

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
                            label:
                                'Precio unitario',
                            hint: 'Ej: 2.50',
                            icon:
                                Icons.attach_money,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Ingrese el precio';
                            }

                            final precio =
                                double.tryParse(
                              value.replaceAll(
                                ',',
                                '.',
                              ),
                            );

                            if (precio ==
                                null) {
                              return 'Ingrese un precio válido';
                            }

                            if (precio < 0) {
                              return 'El precio no puede ser negativo';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

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
                            icon: Icons
                                .inventory_outlined,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Ingrese el stock';
                            }

                            final stock =
                                int.tryParse(
                              value.trim(),
                            );

                            if (stock == null) {
                              return 'Ingrese un número entero';
                            }

                            if (stock < 0) {
                              return 'El stock no puede ser negativo';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        TextFormField(
                          controller:
                              ivaController,
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
                            icon:
                                Icons.percent,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
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

                            if (iva < 0 ||
                                iva > 100) {
                              return 'El IVA debe estar entre 0 y 100';
                            }

                            return null;
                          },
                        ),

                        // ==================================================
                        // ESTADO DEL PRODUCTO
                        // ==================================================

                        if (esEdicion) ...[
                          const SizedBox(
                            height: 14,
                          ),
                          Container(
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFF8F9FB,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                13,
                              ),
                              border:
                                  Border.all(
                                color: Colors
                                    .grey
                                    .shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                ),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration:
                                      BoxDecoration(
                                    color: activo
                                        ? Colors
                                            .green
                                            .withValues(
                                            alpha:
                                                0.10,
                                          )
                                        : Colors
                                            .red
                                            .withValues(
                                            alpha:
                                                0.10,
                                          ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),
                                  child: Icon(
                                    activo
                                        ? Icons
                                            .check_circle_outline
                                        : Icons
                                            .cancel_outlined,
                                    color: activo
                                        ? Colors
                                            .green
                                        : Colors
                                            .red,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'Producto activo',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Disponible en el sistema',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              11,
                                          color: Colors
                                              .grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: activo,
                                  activeColor:
                                      azul,
                                  onChanged:
                                      guardando
                                          ? null
                                          : (value) {
                                              setDialogState(
                                                () {
                                                  activo =
                                                      value;
                                                },
                                              );
                                            },
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child:
                      const Text('Cancelar'),
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
                                  .text
                                  .trim(),
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

                            final productoGuardar =
                                Producto(
                              idProducto:
                                  producto
                                          ?.idProducto ??
                                      0,
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
                              idCategoria:
                                  categoriaSeleccionada,
                              activo: activo,
                            );

                            if (esEdicion) {
                              await ProductoService
                                  .actualizarProducto(
                                productoGuardar,
                              );
                            } else {
                              await ProductoService
                                  .crearProducto(
                                productoGuardar,
                              );
                            }

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                            );

                            await cargarDatos();

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger
                                    .of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  esEdicion
                                      ? 'Producto actualizado correctamente'
                                      : 'Producto registrado correctamente',
                                ),
                                backgroundColor:
                                    Colors.green
                                        .shade700,
                                behavior:
                                    SnackBarBehavior
                                        .floating,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              guardando = false;
                            });

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger
                                    .of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  esEdicion
                                      ? 'Error al actualizar producto: $e'
                                      : 'Error al registrar producto: $e',
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
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
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
                        : esEdicion
                            ? 'Actualizar'
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
  // CONFIRMAR DESACTIVACIÓN
  // ============================================================

  Future<void> confirmarDesactivacion(
    Producto producto,
  ) async {
    if (!puedeGestionarProductos) {
      return;
    }

    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Desactivar producto',
          ),
          content: Text(
            '¿Desea desactivar "${producto.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await ProductoService
          .desactivarProducto(
        producto.idProducto,
      );

      await cargarDatos();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Producto desactivado correctamente',
          ),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al desactivar producto: $e',
          ),
          backgroundColor:
              Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // CONFIRMAR ACTIVACIÓN
  // ============================================================

  Future<void> confirmarActivacion(
    Producto producto,
  ) async {
    if (!puedeGestionarProductos) {
      return;
    }

    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Activar producto',
          ),
          content: Text(
            '¿Desea activar nuevamente "${producto.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Activar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await ProductoService
          .activarProducto(
        producto.idProducto,
      );

      await cargarDatos();

      await cargarProductosDesactivados();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Producto activado correctamente',
          ),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al activar producto: $e',
          ),
          backgroundColor:
              Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
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
      fillColor:
          const Color(0xFFF8F9FB),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: azul,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA PRODUCTO ACTIVO
  // ============================================================

  Widget construirProductoActivo(
    Producto producto,
  ) {
    final bool stockBajo =
        producto.stock > 0 &&
        producto.stock <= 5;

    final bool sinStock =
        producto.stock <= 0;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(18),
          onTap:
              puedeGestionarProductos
                  ? () {
                      mostrarFormularioProducto(
                        producto: producto,
                      );
                    }
                  : null,
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration:
                      BoxDecoration(
                    color: azul.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .inventory_2_outlined,
                    color: azul,
                    size: 29,
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 14,
                            color:
                                Colors.grey,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
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
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .category_outlined,
                            size: 14,
                            color: azul,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              nombreCategoria(
                                producto
                                    .idCategoria,
                              ),
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color: azul,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      Row(
                        children: [
                          _datoProducto(
                            icono: Icons
                                .inventory_2_outlined,
                            texto:
                                'Stock ${producto.stock}',
                            color: sinStock
                                ? Colors.red
                                : stockBajo
                                    ? Colors
                                        .orange
                                    : Colors
                                        .green,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _datoProducto(
                            icono:
                                Icons.percent,
                            texto:
                                'IVA ${producto.tarifaIva}%',
                            color: Colors
                                .grey
                                .shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                  children: [
                    const Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '\$${producto.precioUnitario.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color: azul,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

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

                    if (puedeGestionarProductos) ...[
                      const SizedBox(
                        height: 5,
                      ),

                      PopupMenuButton<
                          String>(
                        tooltip:
                            'Opciones',
                        icon:
                            const Icon(
                          Icons.more_vert,
                          color:
                              Colors.grey,
                        ),
                        onSelected:
                            (opcion) {
                          if (opcion ==
                              'editar') {
                            mostrarFormularioProducto(
                              producto:
                                  producto,
                            );
                          }

                          if (opcion ==
                              'desactivar') {
                            confirmarDesactivacion(
                              producto,
                            );
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem<
                                String>(
                              value:
                                  'editar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .edit_outlined,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width:
                                        10,
                                  ),
                                  Text(
                                    'Editar',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<
                                String>(
                              value:
                                  'desactivar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .delete_outline,
                                    size: 20,
                                    color: Colors
                                        .red,
                                  ),
                                  SizedBox(
                                    width:
                                        10,
                                  ),
                                  Text(
                                    'Desactivar',
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
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
  // TARJETA PRODUCTO DESACTIVADO
  // ============================================================

  Widget construirProductoDesactivado(
    Producto producto,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.red.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons
                      .inventory_2_outlined,
                  color: Colors.red,
                  size: 29,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF263238),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          size: 14,
                          color:
                              Colors.grey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
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
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .category_outlined,
                          size: 14,
                          color:
                              Colors.grey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            nombreCategoria(
                              producto
                                  .idCategoria,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    _estadoProducto(
                      'Desactivado',
                      Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                children: [
                  Text(
                    '\$${producto.precioUnitario.toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (puedeGestionarProductos)
                    ElevatedButton.icon(
                      onPressed: () {
                        confirmarActivacion(
                          producto,
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      icon:
                          const Icon(
                        Icons
                            .check_circle_outline,
                        size: 18,
                      ),
                      label:
                          const Text(
                        'Activar',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
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
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: color,
          ),
          const SizedBox(
            width: 4,
          ),
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
      decoration:
          BoxDecoration(
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
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // SIN RESULTADOS
  // ============================================================

  Widget _construirSinResultados() {
    final buscando =
        busqueda.trim().isNotEmpty;

    final desactivados =
        mostrandoDesactivados;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              buscando
                  ? Icons.search_off
                  : Icons
                      .inventory_2_outlined,
              size: 60,
              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              buscando
                  ? 'No se encontraron productos'
                  : desactivados
                      ? 'No hay productos desactivados'
                      : 'No hay productos',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              buscando
                  ? 'Prueba con otro nombre o código.'
                  : desactivados
                      ? 'Todos los productos están activos.'
                      : 'Todavía no tienes productos registrados.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            if (buscando) ...[
              const SizedBox(
                height: 18,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    busqueda = '';
                  });
                },
                icon:
                    const Icon(
                  Icons.clear,
                ),
                label:
                    const Text(
                  'Limpiar búsqueda',
                ),
              ),
            ],

            if (!desactivados &&
                !buscando &&
                puedeGestionarProductos) ...[
              const SizedBox(
                height: 22,
              ),
              ElevatedButton.icon(
                onPressed:
                    mostrarFormularioProducto,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  'Registrar producto',
                ),
              ),
            ],
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
    final lista =
        productosFiltrados;

    return Scaffold(
      backgroundColor: fondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: azul,
        foregroundColor:
            Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons
                  .inventory_2_outlined,
              size: 24,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              mostrandoDesactivados
                  ? 'Productos desactivados'
                  : 'Productos',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // ====================================================
          // SOLO ADMINISTRADOR Y BODEGA
          // ====================================================

          if (puedeGestionarProductos)
            PopupMenuButton<String>(
              tooltip:
                  'Cambiar vista',
              icon:
                  const Icon(
                Icons.filter_list,
              ),
              onSelected:
                  (valor) {
                if (valor ==
                    'activos') {
                  cambiarVista(false);
                }

                if (valor ==
                    'desactivados') {
                  cambiarVista(true);
                }
              },
              itemBuilder:
                  (context) {
                return [
                  PopupMenuItem<
                      String>(
                    value:
                        'activos',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .check_circle_outline,
                          color: !mostrandoDesactivados
                              ? Colors
                                  .green
                              : Colors
                                  .grey,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Productos activos',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<
                      String>(
                    value:
                        'desactivados',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .cancel_outlined,
                          color: mostrandoDesactivados
                              ? Colors
                                  .red
                              : Colors
                                  .grey,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Productos desactivados',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),

          IconButton(
            tooltip:
                'Actualizar',
            onPressed:
                cargando ||
                        cargandoDesactivados
                    ? null
                    : recargarVistaActual,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(
            width: 5,
          ),
        ],
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: azul,
              ),
            )
          : Column(
              children: [
                // ==================================================
                // SELECTOR ACTIVOS / DESACTIVADOS
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    16,
                    16,
                    4,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(4),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                      border:
                          Border.all(
                        color: Colors
                            .grey
                            .shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              _botonVista(
                            texto:
                                'Activos',
                            icono: Icons
                                .check_circle_outline,
                            seleccionado:
                                !mostrandoDesactivados,
                            cantidad:
                                productos
                                    .length,
                            onTap: () {
                              cambiarVista(
                                false,
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        if (puedeGestionarProductos)
                          Expanded(
                            child:
                                _botonVista(
                              texto:
                                  'Desactivados',
                              icono: Icons
                                  .cancel_outlined,
                              seleccionado:
                                  mostrandoDesactivados,
                              cantidad:
                                  productosDesactivados
                                      .length,
                              onTap: () {
                                cambiarVista(
                                  true,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // CARGANDO DESACTIVADOS
                // ==================================================

                if (cargandoDesactivados)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 10,
                    ),
                    child:
                        LinearProgressIndicator(
                      color: azul,
                      minHeight: 2,
                    ),
                  ),

                // ==================================================
                // BUSCADOR
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    12,
                    16,
                    4,
                  ),
                  child:
                      TextField(
                    onChanged:
                        (value) {
                      setState(() {
                        busqueda =
                            value;
                      });
                    },
                    decoration:
                        InputDecoration(
                      hintText:
                          'Buscar por nombre o código...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                        color: azul,
                      ),
                      suffixIcon:
                          busqueda
                                  .isNotEmpty
                              ? IconButton(
                                  onPressed:
                                      () {
                                    setState(
                                      () {
                                        busqueda =
                                            '';
                                      },
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons.clear,
                                  ),
                                )
                              : null,
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            BorderSide
                                .none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            BorderSide(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color: azul,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTADOR
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    8,
                    18,
                    4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${lista.length} producto${lista.length == 1 ? '' : 's'}',
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade700,
                          fontSize: 13,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        mostrandoDesactivados
                            ? 'Desactivados'
                            : 'Activos',
                        style:
                            TextStyle(
                          color: mostrandoDesactivados
                              ? Colors
                                  .red
                              : Colors
                                  .green,
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // LISTA
                // ==================================================

                Expanded(
                  child: lista.isEmpty
                      ? _construirSinResultados()
                      : RefreshIndicator(
                          color: azul,
                          onRefresh:
                              recargarVistaActual,
                          child:
                              ListView.builder(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              16,
                              12,
                              16,
                              100,
                            ),
                            itemCount:
                                lista.length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final producto =
                                  lista[index];

                              if (mostrandoDesactivados) {
                                return construirProductoDesactivado(
                                  producto,
                                );
                              }

                              return construirProductoActivo(
                                producto,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),

      // ========================================================
      // BOTÓN NUEVO PRODUCTO
      // ========================================================

      floatingActionButton:
          puedeGestionarProductos &&
                  !mostrandoDesactivados
              ? FloatingActionButton
                  .extended(
                  onPressed:
                      mostrarFormularioProducto,
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  elevation: 4,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    'Nuevo producto',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                )
              : null,
    );
  }

  // ============================================================
  // BOTÓN DE VISTA
  // ============================================================

  Widget _botonVista({
    required String texto,
    required IconData icono,
    required bool seleccionado,
    required int cantidad,
    required VoidCallback onTap,
  }) {
    final Color color =
        texto == 'Desactivados'
            ? Colors.red
            : Colors.green;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        11,
      ),
      onTap: onTap,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 11,
          horizontal: 8,
        ),
        decoration:
            BoxDecoration(
          color: seleccionado
              ? color.withValues(
                  alpha: 0.10,
                )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            11,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              icono,
              size: 18,
              color: seleccionado
                  ? color
                  : Colors.grey
                      .shade600,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              texto,
              style:
                  TextStyle(
                color: seleccionado
                    ? color
                    : Colors.grey
                        .shade700,
                fontWeight:
                    seleccionado
                        ? FontWeight
                            .bold
                        : FontWeight
                            .w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration:
                  BoxDecoration(
                color: seleccionado
                    ? color
                        .withValues(
                        alpha: 0.15,
                      )
                    : Colors.grey
                        .shade200,
                borderRadius:
                    BorderRadius
                        .circular(
                  8,
                ),
              ),
              child: Text(
                cantidad
                    .toString(),
                style:
                    TextStyle(
                  color: seleccionado
                      ? color
                      : Colors.grey
                          .shade700,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}