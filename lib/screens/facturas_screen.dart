import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../models/factura.dart';
import '../models/factura_detalle.dart';
import '../models/factura_pago.dart';
import '../models/producto.dart';

import '../services/api_service.dart';
import '../services/cliente_service.dart';
import '../services/factura_detalle_service.dart';
import '../services/factura_pago_service.dart';
import '../services/factura_pdf_service.dart';
import '../services/factura_service.dart';
import '../services/producto_service.dart';

const Color azul = Color(0xFF1565C0);
const Color fondo = Color(0xFFF5F7FA);

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() =>
      _FacturasScreenState();
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
  bool cambiandoEstado = false;

  // ============================================================
  // PERMISOS SEGÚN ROL
  // ============================================================

  bool get esAdministrador =>
      ApiService.esAdministrador;

  bool get esFacturacion =>
      ApiService.esFacturacion;

  bool get esBodega =>
      ApiService.esBodega;

  bool get puedeGestionarFacturas =>
      ApiService.puedeGestionarFacturas;

  bool get puedeCrearFactura =>
      ApiService.puedeCrearFactura;

  bool get puedeCambiarEstado =>
      ApiService.puedeCambiarEstadoFactura;

  bool get puedeEditar =>
      ApiService.puedeEditarFactura;

  bool get puedeEnviarCorreo =>
      ApiService.puedeEnviarFacturaCorreo;

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
    facturas =
        FacturaService.obtenerFacturas();
  }

  Future<void> recargarFacturas() async {
    setState(() {
      facturas =
          FacturaService.obtenerFacturas();
    });

    await facturas;
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
            cliente.razonSocial
                    .toUpperCase() ==
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar los datos.\n$e',
          ),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUSCAR CLIENTES
  // ============================================================

  List<Cliente> buscarClientes(
    String texto,
  ) {
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

  void seleccionarCliente(
    Cliente cliente,
  ) {
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

  List<Producto> buscarProductos(
    String texto,
  ) {
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
    Producto producto,
  ) {
    setState(() {
      productoSeleccionado =
          producto;

      productoController.text =
          producto.nombre;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // AGREGAR PRODUCTO
  // ============================================================

  void agregarProducto() {
    if (!puedeCrearFactura) {
      return;
    }

    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Seleccione un producto'),
        ),
      );

      return;
    }

    final producto =
        productoSeleccionado!;

    if (!producto.activo) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'El producto está inactivo',
          ),
        ),
      );

      return;
    }

    if (producto.stock <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('El producto no tiene stock'),
        ),
      );

      return;
    }

    final indice =
        carrito.indexWhere(
      (item) =>
          item.producto.idProducto ==
          producto.idProducto,
    );

    setState(() {
      if (indice >= 0) {
        final item =
            carrito[indice];

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

  void aumentarCantidad(
    int index,
  ) {
    if (!puedeCrearFactura) {
      return;
    }

    final item = carrito[index];

    if (item.cantidad <
        item.producto.stock) {
      setState(() {
        item.cantidad++;
      });
    }
  }

  void disminuirCantidad(
    int index,
  ) {
    if (!puedeCrearFactura) {
      return;
    }

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
    return carrito.fold(
      0,
      (total, item) =>
          total + item.subtotal,
    );
  }

  double get subtotalIva {
    return carrito
        .where(
          (item) =>
              item.producto.tarifaIva >
              0,
        )
        .fold(
          0,
          (total, item) =>
              total + item.subtotal,
        );
  }

  double get totalIva {
    return carrito.fold(
      0,
      (total, item) =>
          total + item.iva,
    );
  }

  double get total {
    return subtotal + totalIva;
  }

  String formatoMoneda(
    double valor,
  ) {
    return '\$${valor.toStringAsFixed(2)}';
  }

  // ============================================================
  // GENERAR FACTURA
  // ============================================================

  Future<void> generarFactura() async {
    if (!puedeCrearFactura) {
      return;
    }

    if (clienteSeleccionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Seleccione un cliente'),
        ),
      );

      return;
    }

    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
      final factura =
          Factura(
        establecimiento: '001',
        puntoEmision: '001',
        secuencial: '',
        claveAcceso: '',
        fechaEmision:
            DateTime.now(),
        idCliente:
            clienteSeleccionado!.idCliente,
        subtotalSinImpuestos:
            subtotal,
        totalDescuento: 0,
        subtotalIva:
            subtotalIva,
        propina: 0,
        importeTotal: total,
        estadoSri: 'CREADA',
      );

      final detalles =
          carrito.map((item) {
        return FacturaDetalle(
          idFactura: 0,
          idProducto:
              item.producto.idProducto,
          cantidad: item.cantidad,
          precioUnitario:
              item.producto
                  .precioUnitario,
          descuento: 0,
          subtotal:
              item.subtotal,
          valorIva: item.iva,
          total: item.total,
        );
      }).toList();

      final facturaCreada =
          await FacturaService
              .crearFacturaCompleta(
        factura: factura,
        detalles: detalles,
        formaPago: formaPago,
        totalPago: total,
      );

      if (!mounted) return;

      setState(() {
        carrito.clear();

        productoSeleccionado =
            null;

        productoController.clear();

        generandoFactura = false;

        facturas =
            FacturaService
                .obtenerFacturas();
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Factura #${facturaCreada.idFactura} creada correctamente',
          ),
          backgroundColor:
              Colors.green.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        generandoFactura = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al generar factura:\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // CAMBIAR ESTADO
  // ============================================================

  Future<void> cambiarEstadoFactura(
    Factura factura,
    String nuevoEstado,
  ) async {
    if (!puedeCambiarEstado) {
      return;
    }

    if (factura.idFactura == null) {
      return;
    }

    final estadoActual =
        factura.estadoSri.toUpperCase();

    if (estadoActual ==
        nuevoEstado.toUpperCase()) {
      return;
    }

    setState(() {
      cambiandoEstado = true;
    });

    try {
      await ApiService.put(
        'Facturas/${factura.idFactura}/estado/$nuevoEstado',
        {},
      );

      if (!mounted) return;

      setState(() {
        cambiandoEstado = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Factura #${factura.idFactura} → $nuevoEstado',
                ),
              ),
            ],
          ),
          backgroundColor:
              Colors.green.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      await recargarFacturas();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cambiandoEstado = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cambiar el estado.\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // SELECTOR DE ESTADO
  // ============================================================

  Future<void> mostrarSelectorEstado(
    Factura factura,
  ) async {
    if (!puedeCambiarEstado) {
      return;
    }

    const estados = [
      'CREADA',
      'ENVIADA',
      'FIRMADA',
      'AUTORIZADA',
      'RECHAZADA',
    ];

    final estadoActual =
        factura.estadoSri.toUpperCase();

    final nuevoEstado =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return Container(
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            25,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration:
                          BoxDecoration(
                        color: azul
                            .withOpacity(
                          0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                      child: const Icon(
                        Icons.sync_alt,
                        color: azul,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    const Expanded(
                      child: Text(
                        'Cambiar estado',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Factura #${factura.idFactura}',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 18),

                ...estados.map(
                  (estado) {
                    final seleccionado =
                        estado ==
                            estadoActual;

                    final color =
                        _colorEstado(
                      estado,
                    );

                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 8,
                      ),
                      child: ListTile(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                          side: BorderSide(
                            color:
                                seleccionado
                                    ? color
                                    : Colors
                                        .grey
                                        .shade200,
                          ),
                        ),
                        leading: Icon(
                          _iconoEstado(
                            estado,
                          ),
                          color: color,
                        ),
                        title: Text(
                          estado,
                          style:
                              TextStyle(
                            fontWeight:
                                seleccionado
                                    ? FontWeight
                                        .bold
                                    : FontWeight
                                        .w500,
                          ),
                        ),
                        trailing:
                            seleccionado
                                ? Icon(
                                    Icons
                                        .check_circle,
                                    color:
                                        color,
                                  )
                                : const Icon(
                                    Icons
                                        .chevron_right,
                                    color:
                                        Colors
                                            .grey,
                                  ),
                        onTap: () {
                          Navigator.pop(
                            context,
                            estado,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (nuevoEstado == null ||
        nuevoEstado ==
            estadoActual) {
      return;
    }

    await cambiarEstadoFactura(
      factura,
      nuevoEstado,
    );
  }

  // ============================================================
  // COLORES ESTADO
  // ============================================================

  Color _colorEstado(
    String estado,
  ) {
    switch (estado.toUpperCase()) {
      case 'CREADA':
        return Colors.blue.shade700;

      case 'ENVIADA':
        return Colors.indigo.shade700;

      case 'FIRMADA':
        return Colors.purple.shade700;

      case 'AUTORIZADA':
        return Colors.teal.shade700;

      case 'RECHAZADA':
        return Colors.orange.shade800;

      default:
        return Colors.grey.shade700;
    }
  }

  // ============================================================
  // ICONOS ESTADO
  // ============================================================

  IconData _iconoEstado(
    String estado,
  ) {
    switch (estado.toUpperCase()) {
      case 'CREADA':
        return Icons.receipt_long_outlined;

      case 'ENVIADA':
        return Icons.send_outlined;

      case 'FIRMADA':
        return Icons.draw_outlined;

      case 'AUTORIZADA':
        return Icons.verified_outlined;

      case 'RECHAZADA':
        return Icons.error_outline;

      default:
        return Icons.info_outline;
    }
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> descargarFactura(
    Factura factura,
  ) async {
    try {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Generando PDF...'),
            ],
          ),
          behavior:
              SnackBarBehavior.floating,
          duration:
              Duration(seconds: 2),
        ),
      );

      await FacturaPdfService
          .descargarFactura(
        factura: factura,
        productos: productos,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo generar el PDF.\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // ENVIAR FACTURA POR CORREO
  // ============================================================

  Future<void> enviarFacturaPorCorreo(
    Factura factura,
  ) async {
    if (!puedeEnviarCorreo) {
      return;
    }

    if (factura.idFactura == null) {
      return;
    }

    try {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Generando y enviando factura...',
                ),
              ),
            ],
          ),
          behavior:
              SnackBarBehavior.floating,
          duration:
              Duration(seconds: 4),
        ),
      );

      final pdf =
          await FacturaPdfService
              .generarPdfBytes(
        factura,
        productos: productos,
      );

      await FacturaService.enviarFacturaPorCorreo(
  factura: factura,
);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Factura enviada correctamente por correo.',
                ),
              ),
            ],
          ),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo enviar la factura.\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // EDITAR FACTURA
  // ============================================================

  Future<void> editarFactura(
    Factura factura,
  ) async {
    if (!puedeEditar) {
      return;
    }

    if (factura.idFactura == null) {
      return;
    }

    try {
      final detalles =
          await FacturaDetalleService
              .obtenerPorFactura(
        factura.idFactura!,
      );

      final pagos =
          await FacturaPagoService
              .obtenerPorFactura(
        factura.idFactura!,
      );

      if (!mounted) return;

      final resultado =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return EditarFacturaDialog(
            factura: factura,
            detalles: detalles,
            pagos: pagos,
            clientes: clientes,
            productos: productos,
          );
        },
      );

      if (resultado == true) {
        await recargarFacturas();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cargar la factura para editar.\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: azul,
        foregroundColor:
            Colors.white,

        title: const Row(
          children: [
            Icon(
              Icons.receipt_long,
            ),
            SizedBox(width: 10),
            Text(
              'Facturas',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                cargandoDatos
                    ? null
                    : () async {
                        await cargarDatos();
                        await recargarFacturas();
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
                  CircularProgressIndicator(
                color: azul,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await cargarDatos();
                await recargarFacturas();
              },
              child: _contenido(),
            ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(20),
      children: [
        _encabezado(),

        if (puedeGestionarFacturas) ...[
          const SizedBox(height: 25),

          _seccionTitulo(
            Icons.person,
            'Cliente',
          ),

          const SizedBox(height: 10),

          _buscadorCliente(),

          const SizedBox(height: 10),

          _clienteSeleccionado(),

          const SizedBox(height: 25),

          _seccionTitulo(
            Icons.inventory_2,
            'Agregar productos',
          ),

          const SizedBox(height: 10),

          _buscadorProducto(),

          const SizedBox(height: 20),

          _listaCarrito(),

          const SizedBox(height: 20),

          _resumen(),

          const SizedBox(height: 20),

          _formaPago(),

          const SizedBox(height: 20),

          _botonGenerar(),
        ],

        const SizedBox(height: 35),

        _seccionTitulo(
          Icons.history,
          'Facturas registradas',
        ),

        const SizedBox(height: 15),

        _listaFacturas(),
      ],
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
      decoration:
          BoxDecoration(
        color: azul,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  puedeGestionarFacturas
                      ? 'Nueva factura'
                      : 'Facturas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  puedeGestionarFacturas
                      ? 'Registra una nueva venta'
                      : 'Consulta las facturas registradas',
                  style: const TextStyle(
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
  // TÍTULO SECCIÓN
  // ============================================================

  Widget _seccionTitulo(
    IconData icono,
    String titulo,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          color: azul,
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
                const Icon(
              Icons.search,
            ),
            suffixIcon:
                IconButton(
              icon:
                  const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  clienteController
                      .clear();
                  clienteSeleccionado =
                      null;
                });
              },
            ),
            filled: true,
            fillColor:
                Colors.white,
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
            color: Colors.black
                .withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children:
            resultados.map(
          (cliente) {
            return ListTile(
              leading:
                  const CircleAvatar(
                backgroundColor:
                    Color(0xFFE3F2FD),
                child: Icon(
                  Icons.person,
                  color: azul,
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
          },
        ).toList(),
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
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: azul.withOpacity(
            0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE3F2FD,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.person,
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
                  cliente.razonSocial,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
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
            fillColor:
                Colors.white,
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

        if (productoSeleccionado !=
            null)
          Padding(
            padding:
                const EdgeInsets.only(
              top: 10,
            ),
            child:
                ElevatedButton.icon(
              onPressed:
                  agregarProducto,
              icon: const Icon(
                Icons.add_shopping_cart,
              ),
              label: Text(
                'Agregar ${productoSeleccionado!.nombre}',
              ),
            ),
          ),
      ],
    );
  }

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
            color: Colors.black
                .withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children:
            resultados.map(
          (producto) {
            final sinStock =
                producto.stock <= 0;

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
              trailing: Icon(
                sinStock
                    ? Icons.block
                    : Icons
                        .add_circle_outline,
                color: sinStock
                    ? Colors.red
                    : azul,
              ),
              onTap: sinStock
                  ? null
                  : () {
                      seleccionarProducto(
                        producto,
                      );
                    },
            );
          },
        ).toList(),
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
                const EdgeInsets.all(
              18,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: azul,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                  child: Text(
                    'Detalle de factura',
                    style: TextStyle(
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

          const Divider(
            height: 1,
          ),

          ...carrito
              .asMap()
              .entries
              .map(
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
                            color: azul,
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
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            IconButton(
                              onPressed: () {
                                disminuirCantidad(
                                  index,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .remove_circle_outline,
                                color:
                                    Colors.grey,
                              ),
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
                            IconButton(
                              onPressed: () {
                                aumentarCantidad(
                                  index,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .add_circle_outline,
                                color: azul,
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
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          _filaResumen(
            'Subtotal',
            subtotal,
          ),

          _filaResumen(
            'IVA',
            totalIva,
          ),

          const Divider(),

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
                  ? azul
                  : Colors.grey
                      .shade700,
            ),
          ),
          Text(
            formatoMoneda(valor),
            style: TextStyle(
              fontSize:
                  grande ? 22 : 15,
              fontWeight:
                  FontWeight.bold,
              color: grande
                  ? azul
                  : Colors.black87,
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
        initialValue: formaPago,
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
            child: Text(
              'TRANSFERENCIA',
            ),
          ),
        ],
        onChanged:
            generandoFactura
                ? null
                : (valor) {
                    if (valor ==
                        null) {
                      return;
                    }

                    setState(() {
                      formaPago =
                          valor;
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
          backgroundColor: azul,
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
  // LISTA DE FACTURAS
  // ============================================================

  Widget _listaFacturas() {
    return FutureBuilder<
        List<Factura>>(
      future: facturas,
      builder:
          (context, snapshot) {
        if (snapshot
                .connectionState ==
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
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Text(
              'No se pudieron cargar las facturas.\n${snapshot.error}',
              style: TextStyle(
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
                const EdgeInsets.all(
              25,
            ),
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
                  Icons
                      .receipt_long_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'No existen facturas registradas',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              data.map(
            (factura) {
              return _tarjetaFactura(
                factura,
              );
            },
          ).toList(),
        );
      },
    );
  }

  // ============================================================
  // TARJETA FACTURA
  // ============================================================

  Widget _tarjetaFactura(
    Factura factura,
  ) {
    final estado =
        factura.estadoSri
            .toUpperCase();

    final colorEstado =
        _colorEstado(estado);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey
              .shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.03),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
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
                  color: azul,
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
                      'Factura #${factura.idFactura}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Cliente: ${factura.idCliente}',
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

              Text(
                formatoMoneda(
                  factura.importeTotal,
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: azul,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  onTap:
                      !puedeCambiarEstado ||
                              cambiandoEstado
                          ? null
                          : () {
                              mostrarSelectorEstado(
                                factura,
                              );
                            },
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: colorEstado
                          .withOpacity(
                        0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      border:
                          Border.all(
                        color: colorEstado
                            .withOpacity(
                          0.25,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        Icon(
                          _iconoEstado(
                            estado,
                          ),
                          size: 16,
                          color:
                              colorEstado,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Flexible(
                          child: Text(
                            estado,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color:
                                  colorEstado,
                              fontSize:
                                  11,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        if (puedeCambiarEstado) ...[
                          const SizedBox(
                            width: 3,
                          ),
                          Icon(
                            Icons
                                .keyboard_arrow_down,
                            size: 17,
                            color:
                                colorEstado,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // PDF
              IconButton(
                tooltip:
                    'Descargar PDF',
                onPressed: () {
                  descargarFactura(
                    factura,
                  );
                },
                icon:
                    const Icon(
                  Icons.picture_as_pdf_outlined,
                  color:
                      Colors.red,
                ),
              ),

              // CORREO
              if (puedeEnviarCorreo)
                IconButton(
                  tooltip:
                      'Enviar por correo',
                  onPressed: () {
                    enviarFacturaPorCorreo(
                      factura,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.email_outlined,
                    color:
                        Colors.green,
                  ),
                ),

              // EDITAR
              if (puedeEditar)
                IconButton(
                  tooltip:
                      'Editar factura',
                  onPressed: () {
                    editarFactura(
                      factura,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.edit_outlined,
                    color: azul,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ITEM FACTURA
// =================================================================

class ItemFactura {
  final Producto producto;

  int cantidad;

  ItemFactura({
    required this.producto,
    required this.cantidad,
  });

  double get subtotal {
    return producto
            .precioUnitario *
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

// =================================================================
// DIALOG EDITAR FACTURA
// =================================================================

class EditarFacturaDialog
    extends StatefulWidget {
  final Factura factura;
  final List<FacturaDetalle> detalles;
  final List<FacturaPago> pagos;
  final List<Cliente> clientes;
  final List<Producto> productos;

  const EditarFacturaDialog({
    super.key,
    required this.factura,
    required this.detalles,
    required this.pagos,
    required this.clientes,
    required this.productos,
  });

  @override
  State<EditarFacturaDialog>
      createState() =>
          _EditarFacturaDialogState();
}

class _EditarFacturaDialogState
    extends State<EditarFacturaDialog> {
  late Cliente? clienteSeleccionado;

  late List<ItemFactura>
      carrito;

  late String formaPago;

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    clienteSeleccionado =
        widget.clientes
            .where(
              (cliente) =>
                  cliente.idCliente ==
                  widget.factura.idCliente,
            )
            .cast<Cliente?>()
            .firstOrNull;

    carrito = [];

    for (final detalle
        in widget.detalles) {
      Producto? producto;

      for (final item
          in widget.productos) {
        if (item.idProducto ==
            detalle.idProducto) {
          producto = item;
          break;
        }
      }

      if (producto != null) {
        carrito.add(
          ItemFactura(
            producto: producto,
            cantidad: detalle.cantidad,
          ),
        );
      }
    }

    formaPago =
        widget.pagos.isNotEmpty
            ? widget
                .pagos
                .first
                .formaPago
            : 'EFECTIVO';
  }

  double get subtotal {
    return carrito.fold(
      0,
      (total, item) =>
          total + item.subtotal,
    );
  }

  double get subtotalIva {
    return carrito
        .where(
          (item) =>
              item.producto.tarifaIva >
              0,
        )
        .fold(
          0,
          (total, item) =>
              total + item.subtotal,
        );
  }

  double get totalIva {
    return carrito.fold(
      0,
      (total, item) =>
          total + item.iva,
    );
  }

  double get total {
    return subtotal + totalIva;
  }

  String formatoMoneda(
    double valor,
  ) {
    return '\$${valor.toStringAsFixed(2)}';
  }

  // ============================================================
  // GUARDAR EDICIÓN
  // ============================================================

  Future<void> guardar() async {
    if (widget.factura.idFactura ==
        null) {
      return;
    }

    if (clienteSeleccionado ==
        null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Seleccione un cliente'),
        ),
      );

      return;
    }

    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'La factura debe tener al menos un producto',
          ),
        ),
      );

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final body = {
        'id_cliente':
            clienteSeleccionado!
                .idCliente,

        'fecha_emision':
            widget.factura
                .fechaEmision
                .toIso8601String(),

        'subtotal_sin_impuestos':
            subtotal,

        'total_descuento': 0,

        'subtotal_iva':
            subtotalIva,

        'propina': 0,

        'importe_total':
            total,

        'detalles':
            carrito.map(
          (item) {
            return {
              'idProducto':
                  item.producto
                      .idProducto,
              'cantidad':
                  item.cantidad,
              'precioUnitario':
                  item.producto
                      .precioUnitario,
              'descuento': 0,
              'subtotal':
                  item.subtotal,
              'valorIva':
                  item.iva,
              'total':
                  item.total,
            };
          },
        ).toList(),

        'forma_pago':
            formaPago,

        'total_pago':
            total,
      };

      await ApiService.put(
        'Facturas/${widget.factura.idFactura}',
        body,
      );

      if (!mounted) return;

      Navigator.of(context)
          .pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar la factura.\n$e',
          ),
          duration:
              const Duration(seconds: 6),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUSCAR CLIENTE
  // ============================================================

  List<Cliente> buscarClientes(
    String texto,
  ) {
    final busqueda =
        texto.trim().toLowerCase();

    if (busqueda.isEmpty) {
      return [];
    }

    return widget.clientes.where(
      (cliente) {
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
      },
    ).take(8).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color: azul.withOpacity(
                0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: azul,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Editar factura',
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'Factura #${widget.factura.idFactura}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'Cliente',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Autocomplete<Cliente>(
                initialValue:
                    TextEditingValue(
                  text:
                      clienteSeleccionado
                          ?.razonSocial ??
                      '',
                ),
                displayStringForOption:
                    (cliente) =>
                        cliente.razonSocial,
                optionsBuilder:
                    (value) {
                  return buscarClientes(
                    value.text,
                  );
                },
                onSelected:
                    (cliente) {
                  setState(() {
                    clienteSeleccionado =
                        cliente;
                  });
                },
                fieldViewBuilder:
                    (
                  context,
                  controller,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextField(
                    controller:
                        controller,
                    focusNode:
                        focusNode,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Cliente',
                      prefixIcon:
                          Icon(
                        Icons.person,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  );
                },
                optionsViewBuilder:
                    (
                  context,
                  onSelected,
                  options,
                ) {
                  return Align(
                    alignment:
                        Alignment
                            .topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxHeight: 250,
                          maxWidth: 500,
                        ),
                        child: ListView
                            .builder(
                          padding:
                              EdgeInsets.zero,
                          itemCount:
                              options.length,
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final cliente =
                                options
                                    .elementAt(
                              index,
                            );

                            return ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .person_outline,
                                color: azul,
                              ),
                              title:
                                  Text(
                                cliente
                                    .razonSocial,
                              ),
                              subtitle:
                                  Text(
                                cliente
                                    .identificacion,
                              ),
                              onTap: () {
                                onSelected(
                                  cliente,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Productos',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              if (carrito.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(15),
                  child: Text(
                    'No hay productos.',
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ),

              ...carrito
                  .asMap()
                  .entries
                  .map(
                (entry) {
                  final index =
                      entry.key;

                  final item =
                      entry.value;

                  return Container(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 8,
                    ),
                    padding:
                        const EdgeInsets
                            .all(
                      12,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey
                              .shade50,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
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
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                item.producto
                                    .nombre,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                formatoMoneda(
                                  item.producto
                                      .precioUnitario,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed:
                              item.cantidad >
                                      1
                                  ? () {
                                      setState(
                                        () {
                                          item.cantidad--;
                                        },
                                      );
                                    }
                                  : null,
                          icon:
                              const Icon(
                            Icons
                                .remove_circle_outline,
                          ),
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

                        IconButton(
                          onPressed:
                              item.cantidad <
                                      item.producto
                                          .stock
                                  ? () {
                                      setState(
                                        () {
                                          item.cantidad++;
                                        },
                                      );
                                    }
                                  : null,
                          icon:
                              const Icon(
                            Icons
                                .add_circle_outline,
                            color: azul,
                          ),
                        ),

                        IconButton(
                          onPressed:
                              () {
                            setState(
                              () {
                                carrito
                                    .removeAt(
                                  index,
                                );
                              },
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                            color:
                                Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              Align(
                alignment:
                    Alignment.centerRight,
                child: Text(
                  'TOTAL: ${formatoMoneda(total)}',
                  style:
                      const TextStyle(
                    color: azul,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    formaPago,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Forma de pago',
                  prefixIcon:
                      Icon(
                    Icons.payment,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value:
                        'EFECTIVO',
                    child: Text(
                      'EFECTIVO',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                        'TARJETA',
                    child: Text(
                      'TARJETA',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                        'TRANSFERENCIA',
                    child: Text(
                      'TRANSFERENCIA',
                    ),
                  ),
                ],
                onChanged:
                    guardando
                        ? null
                        : (valor) {
                            if (valor ==
                                null) {
                              return;
                            }

                            setState(() {
                              formaPago =
                                  valor;
                            });
                          },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop(false);
                },
          child:
              const Text('Cancelar'),
        ),

        ElevatedButton.icon(
          onPressed:
              guardando
                  ? null
                  : guardar,
          style:
              ElevatedButton.styleFrom(
            backgroundColor: azul,
            foregroundColor:
                Colors.white,
          ),
          icon: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                )
              : const Icon(
                  Icons.save,
                ),
          label: Text(
            guardando
                ? 'Guardando...'
                : 'Guardar cambios',
          ),
        ),
      ],
    );
  }
}

// =================================================================
// EXTENSIÓN PARA OBTENER EL PRIMER ELEMENTO NULLABLE
// =================================================================

extension FirstOrNullExtension<T>
    on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}