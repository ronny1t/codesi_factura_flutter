import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../models/factura.dart';
import '../models/factura_detalle.dart';
import '../models/factura_pago.dart';
import '../models/producto.dart';

import '../services/cliente_service.dart';
import '../services/factura_detalle_service.dart';
import '../services/factura_pago_service.dart';
import '../services/factura_service.dart';
import '../services/producto_service.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  late Future<List<Factura>> facturas;

  List<Cliente> clientes = [];
  List<Producto> productos = [];

  Cliente? clienteSeleccionado;
  Producto? productoSeleccionado;

  final List<ItemFactura> carrito = [];

  final TextEditingController clienteController =
      TextEditingController();

  final TextEditingController productoController =
      TextEditingController();

  String formaPago = 'EFECTIVO';

  bool cargandoDatos = true;
  bool generandoFactura = false;

  @override
  void initState() {
    super.initState();

    cargarFacturas();
    cargarDatos();
  }

  @override
  void dispose() {
    clienteController.dispose();
    productoController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR FACTURAS
  // ============================================================

  void cargarFacturas() {
    facturas = FacturaService.obtenerFacturas();
  }

  // ============================================================
  // CARGAR CLIENTES Y PRODUCTOS
  // ============================================================

  Future<void> cargarDatos() async {
    try {
      setState(() {
        cargandoDatos = true;
      });

      final resultados = await Future.wait([
        ClienteService.obtenerClientes(),
        ProductoService.obtenerProductos(),
      ]);

      if (!mounted) return;

      final listaClientes =
          resultados[0] as List<Cliente>;

      final listaProductos =
          resultados[1] as List<Producto>;

      Cliente? consumidorFinal;

      for (final cliente in listaClientes) {
        if (cliente.identificacion ==
                '9999999999999' ||
            cliente.razonSocial.toUpperCase() ==
                'CONSUMIDOR_FINAL') {
          consumidorFinal = cliente;
          break;
        }
      }

      setState(() {
        clientes = listaClientes;
        productos = listaProductos;

        if (consumidorFinal != null) {
          clienteSeleccionado =
              consumidorFinal;

          clienteController.text =
              consumidorFinal.razonSocial;
        } else if (clientes.isNotEmpty) {
          clienteSeleccionado =
              clientes.first;

          clienteController.text =
              clientes.first.razonSocial;
        }

        cargandoDatos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoDatos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No se pudieron cargar los datos',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUSCAR CLIENTES
  // ============================================================

  List<Cliente> buscarClientes(String texto) {
    final busqueda =
        texto.trim().toLowerCase();

    if (busqueda.isEmpty) {
      return [];
    }

    return clientes.where((cliente) {
      return cliente.razonSocial
              .toLowerCase()
              .contains(busqueda) ||
          cliente.identificacion
              .toLowerCase()
              .contains(busqueda) ||
          (cliente.telefono ?? '')
              .toLowerCase()
              .contains(busqueda) ||
          (cliente.email ?? '')
              .toLowerCase()
              .contains(busqueda);
    }).take(8).toList();
  }

  void seleccionarCliente(Cliente cliente) {
    setState(() {
      clienteSeleccionado = cliente;

      clienteController.text =
          cliente.razonSocial;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // BUSCAR PRODUCTOS
  // ============================================================

  List<Producto> buscarProductos(String texto) {
    final busqueda =
        texto.trim().toLowerCase();

    if (busqueda.isEmpty) {
      return [];
    }

    return productos.where((producto) {
      return producto.nombre
              .toLowerCase()
              .contains(busqueda) ||
          (producto.codigoPrincipal ?? '')
              .toLowerCase()
              .contains(busqueda);
    }).take(10).toList();
  }

  void seleccionarProducto(
      Producto producto) {
    setState(() {
      productoSeleccionado = producto;

      productoController.text =
          producto.nombre;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // AGREGAR PRODUCTO
  // ============================================================

  void agregarProducto() {
    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Seleccione un producto'),
        ),
      );
      return;
    }

    final producto =
        productoSeleccionado!;

    if (producto.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El producto no tiene stock'),
        ),
      );
      return;
    }

    final indice = carrito.indexWhere(
      (item) =>
          item.producto.idProducto ==
          producto.idProducto,
    );

    setState(() {
      if (indice >= 0) {
        final item = carrito[indice];

        if (item.cantidad <
            producto.stock) {
          item.cantidad++;
        }
      } else {
        carrito.add(
          ItemFactura(
            producto: producto,
            cantidad: 1,
          ),
        );
      }

      productoSeleccionado = null;
      productoController.clear();
    });
  }

  // ============================================================
  // CANTIDADES
  // ============================================================

  void aumentarCantidad(int index) {
    final item = carrito[index];

    if (item.cantidad <
        item.producto.stock) {
      setState(() {
        item.cantidad++;
      });
    }
  }

  void disminuirCantidad(int index) {
    final item = carrito[index];

    setState(() {
      if (item.cantidad > 1) {
        item.cantidad--;
      } else {
        carrito.removeAt(index);
      }
    });
  }

  // ============================================================
  // CÁLCULOS
  // ============================================================

  double get subtotal {
    double total = 0;

    for (final item in carrito) {
      total += item.subtotal;
    }

    return total;
  }

  double get totalIva {
    double total = 0;

    for (final item in carrito) {
      total += item.iva;
    }

    return total;
  }

  double get total {
    return subtotal + totalIva;
  }

  String formatoMoneda(double valor) {
    return '\$${valor.toStringAsFixed(2)}';
  }

  // ============================================================
  // GENERAR FACTURA
  // ============================================================

  Future<void> generarFactura() async {
    if (clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Seleccione un cliente'),
        ),
      );
      return;
    }

    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agregue al menos un producto',
          ),
        ),
      );
      return;
    }

    setState(() {
      generandoFactura = true;
    });

    try {
      // ==========================================================
      // 1. CREAR CABECERA
      // ==========================================================

      final factura = Factura(
        establecimiento: '001',
        puntoEmision: '001',
        secuencial: generarSecuencial(),
        claveAcceso: '',
        fechaEmision: DateTime.now(),
        idCliente:
            clienteSeleccionado!.idCliente,
        subtotalSinImpuestos: subtotal,
        totalDescuento: 0,
        subtotalIva: subtotal,
        propina: 0,
        importeTotal: total,
        estadoSri: 'PENDIENTE',
      );

      final facturaCreada =
          await FacturaService.crearFactura(
        factura,
      );

      final idFactura =
          facturaCreada.idFactura;

      if (idFactura == null) {
        throw Exception(
          'El servidor no devolvió el ID de la factura',
        );
      }

      // ==========================================================
      // 2. CREAR DETALLES
      // ==========================================================

      for (final item in carrito) {
        final detalle =
            FacturaDetalle(
          idFactura: idFactura,
          idProducto:
              item.producto.idProducto,
          cantidad: item.cantidad,
          precioUnitario:
              item.producto.precioUnitario,
          descuento: 0,
          subtotal: item.subtotal,
          valorIva: item.iva,
          total: item.total,
        );

        await FacturaDetalleService
            .crearDetalle(
          detalle,
        );
      }

      // ==========================================================
      // 3. CREAR PAGO
      // ==========================================================

      final pago = FacturaPago(
        idFactura: idFactura,
        formaPago: formaPago,
        total: total,
      );

      await FacturaPagoService.crearPago(
        pago,
      );

      if (!mounted) return;

      setState(() {
        carrito.clear();

        productoSeleccionado = null;

        productoController.clear();

        generandoFactura = false;

        cargarFacturas();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Factura #$idFactura creada correctamente',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        generandoFactura = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al generar factura: $e',
          ),
          duration:
              const Duration(seconds: 5),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String generarSecuencial() {
    final ahora = DateTime.now();

    return '${ahora.year}'
        '${ahora.month.toString().padLeft(2, '0')}'
        '${ahora.day.toString().padLeft(2, '0')}'
        '${ahora.hour.toString().padLeft(2, '0')}'
        '${ahora.minute.toString().padLeft(2, '0')}'
        '${ahora.second.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFF1565C0),
        foregroundColor: Colors.white,

        title: const Text(
          'Facturas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              cargarFacturas();
              cargarDatos();
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: cargandoDatos
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _contenido(),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido() {
    return RefreshIndicator(
      onRefresh: () async {
        cargarFacturas();
        await cargarDatos();
      },

      child: ListView(
        padding:
            const EdgeInsets.all(20),

        children: [

          // ========================================================
          // ENCABEZADO
          // ========================================================

          _encabezado(),

          const SizedBox(height: 25),

          // ========================================================
          // CLIENTE
          // ========================================================

          _seccionTitulo(
            Icons.person,
            'Cliente',
          ),

          const SizedBox(height: 10),

          _buscadorCliente(),

          const SizedBox(height: 10),

          _clienteSeleccionado(),

          const SizedBox(height: 25),

          // ========================================================
          // PRODUCTO
          // ========================================================

          _seccionTitulo(
            Icons.inventory_2,
            'Agregar productos',
          ),

          const SizedBox(height: 10),

          _buscadorProducto(),

          const SizedBox(height: 20),

          // ========================================================
          // CARRITO
          // ========================================================

          _listaCarrito(),

          const SizedBox(height: 20),

          // ========================================================
          // RESUMEN
          // ========================================================

          _resumen(),

          const SizedBox(height: 20),

          // ========================================================
          // PAGO
          // ========================================================

          _formaPago(),

          const SizedBox(height: 20),

          // ========================================================
          // BOTÓN
          // ========================================================

          _botonGenerar(),

          const SizedBox(height: 35),

          // ========================================================
          // FACTURAS REGISTRADAS
          // ========================================================

          _seccionTitulo(
            Icons.history,
            'Facturas registradas',
          ),

          const SizedBox(height: 15),

          _listaFacturas(),
        ],
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color:
            const Color(0xFF1565C0),
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Nueva factura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Registra una nueva venta',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO DE SECCIÓN
  // ============================================================

  Widget _seccionTitulo(
    IconData icono,
    String titulo,
  ) {
    return Row(
      children: [

        Icon(
          icono,
          color:
              const Color(0xFF1565C0),
          size: 23,
        ),

        const SizedBox(width: 8),

        Text(
          titulo,
          style: const TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF263238),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSCADOR CLIENTE
  // ============================================================

  Widget _buscadorCliente() {
    return Column(
      children: [

        TextField(
          controller:
              clienteController,

          decoration:
              InputDecoration(
            hintText:
                'Buscar nombre, identificación, correo...',
            prefixIcon:
                const Icon(Icons.search),

            suffixIcon:
                IconButton(
              icon:
                  const Icon(Icons.clear),

              onPressed: () {
                setState(() {
                  clienteController.clear();
                  clienteSeleccionado =
                      null;
                });
              },
            ),

            filled: true,
            fillColor: Colors.white,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
              borderSide:
                  BorderSide.none,
            ),
          ),

          onChanged: (_) {
            setState(() {});
          },
        ),

        _resultadosClientes(),
      ],
    );
  }

  // ============================================================
  // RESULTADOS CLIENTES
  // ============================================================

  Widget _resultadosClientes() {
    final resultados =
        buscarClientes(
      clienteController.text,
    );

    if (clienteController.text
            .trim()
            .isEmpty ||
        resultados.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 6,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        children:
            resultados.map((cliente) {
          return ListTile(
            leading:
                const CircleAvatar(
              backgroundColor:
                  Color(0xFFE3F2FD),
              child: Icon(
                Icons.person,
                color:
                    Color(0xFF1565C0),
              ),
            ),

            title: Text(
              cliente.razonSocial,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: Text(
              '${cliente.tipoIdentificacion}: '
              '${cliente.identificacion}',
            ),

            onTap: () {
              seleccionarCliente(
                cliente,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // CLIENTE SELECCIONADO
  // ============================================================

  Widget _clienteSeleccionado() {
    if (clienteSeleccionado ==
        null) {
      return const SizedBox();
    }

    final cliente =
        clienteSeleccionado!;

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFF1565C0)
                  .withOpacity(0.2),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFE3F2FD),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.person,
              color:
                  Color(0xFF1565C0),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  cliente.razonSocial,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${cliente.tipoIdentificacion}: '
                  '${cliente.identificacion}',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                clienteSeleccionado =
                    null;
                clienteController
                    .clear();
              });
            },
            icon:
                const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSCADOR PRODUCTO
  // ============================================================

  Widget _buscadorProducto() {
    return Column(
      children: [

        TextField(
          controller:
              productoController,

          decoration:
              InputDecoration(
            hintText:
                'Buscar producto o código...',
            prefixIcon:
                const Icon(
              Icons.search,
            ),

            suffixIcon:
                IconButton(
              icon:
                  const Icon(Icons.clear),

              onPressed: () {
                setState(() {
                  productoController
                      .clear();
                  productoSeleccionado =
                      null;
                });
              },
            ),

            filled: true,
            fillColor: Colors.white,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
              borderSide:
                  BorderSide.none,
            ),
          ),

          onChanged: (_) {
            setState(() {});
          },
        ),

        _resultadosProductos(),
      ],
    );
  }

  // ============================================================
  // RESULTADOS PRODUCTOS
  // ============================================================

  Widget _resultadosProductos() {
    final resultados =
        buscarProductos(
      productoController.text,
    );

    if (productoController.text
            .trim()
            .isEmpty ||
        resultados.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 6,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        children:
            resultados.map((producto) {
          return ListTile(
            leading:
                const CircleAvatar(
              backgroundColor:
                  Color(0xFFFFF3E0),
              child: Icon(
                Icons.inventory_2,
                color:
                    Color(0xFFEF6C00),
              ),
            ),

            title: Text(
              producto.nombre,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: Text(
              'Código: '
              '${producto.codigoPrincipal ?? 'Sin código'}\n'
              'Precio: '
              '${formatoMoneda(producto.precioUnitario)}'
              ' • Stock: ${producto.stock}',
            ),

            isThreeLine: true,

            trailing:
                const Icon(
              Icons.add_circle_outline,
              color:
                  Color(0xFF1565C0),
            ),

            onTap: () {
              seleccionarProducto(
                producto,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // CARRITO
  // ============================================================

  Widget _listaCarrito() {
    if (carrito.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(25),

        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: const Column(
          children: [

            Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: Colors.grey,
            ),

            SizedBox(height: 10),

            Text(
              'No hay productos agregados',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Busca un producto para agregarlo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.all(18),

            child: Row(
              children: [

                const Icon(
                  Icons.shopping_cart,
                  color:
                      Color(0xFF1565C0),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Detalle de factura',
                    style:
                        TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  '${carrito.length} producto${carrito.length == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          ...carrito.asMap().entries.map(
            (entry) {
              final index =
                  entry.key;

              final item =
                  entry.value;

              return Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                child: Row(
                  children: [

                    Container(
                      width: 45,
                      height: 45,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE3F2FD,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: Center(
                        child: Text(
                          '${item.cantidad}',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF1565C0,
                            ),
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            item.producto
                                .nombre,

                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            '${formatoMoneda(item.producto.precioUnitario)} × ${item.cantidad}',

                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,

                      children: [

                        Text(
                          formatoMoneda(
                            item.total,
                          ),

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            InkWell(
                              onTap: () {
                                disminuirCantidad(
                                  index,
                                );
                              },

                              child:
                                  const Icon(
                                Icons
                                    .remove_circle_outline,
                                size: 24,
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              '${item.cantidad}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            InkWell(
                              onTap: () {
                                aumentarCantidad(
                                  index,
                                );
                              },

                              child:
                                  const Icon(
                                Icons
                                    .add_circle_outline,
                                size: 24,
                                color:
                                    Color(
                                  0xFF1565C0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _resumen() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          const Align(
            alignment:
                Alignment.centerLeft,

            child: Text(
              'Resumen',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          _filaResumen(
            'Subtotal',
            subtotal,
          ),

          _filaResumen(
            'IVA',
            totalIva,
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 8,
            ),
            child:
                Divider(),
          ),

          _filaResumen(
            'TOTAL',
            total,
            grande: true,
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(
    String titulo,
    double valor, {
    bool grande = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(
            titulo,
            style: TextStyle(
              fontSize:
                  grande ? 20 : 15,
              fontWeight: grande
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: grande
                  ? const Color(
                      0xFF1565C0,
                    )
                  : const Color(
                      0xFF546E7A,
                    ),
            ),
          ),

          Text(
            formatoMoneda(valor),
            style: TextStyle(
              fontSize:
                  grande ? 22 : 15,
              fontWeight: FontWeight.bold,
              color: grande
                  ? const Color(
                      0xFF1565C0,
                    )
                  : const Color(
                      0xFF263238,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMA DE PAGO
  // ============================================================

  Widget _formaPago() {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child:
          DropdownButtonFormField<String>(
        value: formaPago,

        decoration:
            const InputDecoration(
          labelText:
              'Forma de pago',
          prefixIcon:
              Icon(Icons.payment),
          border:
              OutlineInputBorder(),
        ),

        items: const [

          DropdownMenuItem(
            value: 'EFECTIVO',
            child:
                Text('EFECTIVO'),
          ),

          DropdownMenuItem(
            value: 'TARJETA',
            child:
                Text('TARJETA'),
          ),

          DropdownMenuItem(
            value: 'TRANSFERENCIA',
            child:
                Text('TRANSFERENCIA'),
          ),
        ],

        onChanged: (valor) {
          if (valor == null) return;

          setState(() {
            formaPago = valor;
          });
        },
      ),
    );
  }

  // ============================================================
  // BOTÓN GENERAR
  // ============================================================

  Widget _botonGenerar() {
    return SizedBox(
      height: 58,

      child:
          ElevatedButton.icon(
        onPressed:
            generandoFactura
                ? null
                : generarFactura,

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFF1565C0,
          ),

          foregroundColor:
              Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),

        icon: generandoFactura
            ? const SizedBox(
                width: 21,
                height: 21,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.receipt_long,
              ),

        label: Text(
          generandoFactura
              ? 'GENERANDO FACTURA...'
              : 'GENERAR FACTURA',

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FACTURAS REGISTRADAS
  // ============================================================

  Widget _listaFacturas() {
    return FutureBuilder<List<Factura>>(
      future: facturas,

      builder:
          (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding:
                  EdgeInsets.all(20),

              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding:
                const EdgeInsets.all(20),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Text(
              'No se pudieron cargar las facturas.',
              style:
                  TextStyle(
                color:
                    Colors.red.shade700,
              ),
            ),
          );
        }

        final data =
            snapshot.data ?? [];

        if (data.isEmpty) {
          return Container(
            padding:
                const EdgeInsets.all(25),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: const Column(
              children: [

                Icon(
                  Icons.receipt_long_outlined,
                  size: 50,
                  color: Colors.grey,
                ),

                SizedBox(height: 10),

                Text(
                  'No existen facturas registradas',
                  style:
                      TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              data.map((factura) {

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: ListTile(
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                leading:
                    Container(
                  width: 48,
                  height: 48,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFE3F2FD,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),

                  child: const Icon(
                    Icons.receipt_long,
                    color:
                        Color(
                      0xFF1565C0,
                    ),
                  ),
                ),

                title: Text(
                  'Factura #${factura.idFactura}',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                subtitle:
                    Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 5,
                  ),

                  child: Text(
                    'Cliente: ${factura.idCliente}\n'
                    'Estado: ${factura.estadoSri}',
                  ),
                ),

                trailing:
                    Text(
                  formatoMoneda(
                    factura.importeTotal,
                  ),

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(
                      0xFF1565C0,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// ITEM DEL CARRITO
// ============================================================

class ItemFactura {
  final Producto producto;

  int cantidad;

  ItemFactura({
    required this.producto,
    required this.cantidad,
  });

  double get subtotal {
    return producto.precioUnitario *
        cantidad;
  }

  double get iva {
    return subtotal *
        (producto.tarifaIva / 100);
  }

  double get total {
    return subtotal + iva;
  }
}