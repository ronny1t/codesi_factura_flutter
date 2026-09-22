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

  void cargarFacturas() {
    facturas = FacturaService.obtenerFacturas();
  }

  Future<void> cargarDatos() async {
    try {
      final resultados = await Future.wait([
        ClienteService.obtenerClientes(),
        ProductoService.obtenerProductos(),
      ]);

      if (!mounted) return;

      final listaClientes = resultados[0] as List<Cliente>;
      final listaProductos = resultados[1] as List<Producto>;

      Cliente? consumidorFinal;

      for (final cliente in listaClientes) {
        if (cliente.identificacion == '9999999999999' ||
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
          clienteSeleccionado = consumidorFinal;
          clienteController.text =
              consumidorFinal.razonSocial;
        } else if (clientes.isNotEmpty) {
          clienteSeleccionado = clientes.first;
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
          content: Text('Error cargando datos: $e'),
        ),
      );
    }
  }

  // ============================================================
  // BUSQUEDA DE CLIENTES
  // ============================================================

  List<Cliente> buscarClientes(String texto) {
  final busqueda = texto.trim().toLowerCase();

  if (busqueda.isEmpty) {
    return [];
  }

  return clientes.where((cliente) {
    return (cliente.razonSocial ?? '')
            .toLowerCase()
            .contains(busqueda) ||
        (cliente.identificacion ?? '')
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
    clienteController.text = cliente.razonSocial ?? '';
  });

  FocusScope.of(context).unfocus();
}
  // ============================================================
  // BUSQUEDA DE PRODUCTOS
  // ============================================================

  List<Producto> buscarProductos(String texto) {
    final busqueda = texto.trim().toLowerCase();

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

  void seleccionarProducto(Producto producto) {
    setState(() {
      productoSeleccionado = producto;
      productoController.text = producto.nombre;
    });

    FocusScope.of(context).unfocus();
  }

  void agregarProducto() {
    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un producto'),
        ),
      );
      return;
    }

    final producto = productoSeleccionado!;

    if (producto.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El producto no tiene stock'),
        ),
      );
      return;
    }

    final indice = carrito.indexWhere(
      (item) =>
          item.producto.idProducto == producto.idProducto,
    );

    setState(() {
      if (indice >= 0) {
        final item = carrito[indice];

        if (item.cantidad < producto.stock) {
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

  void aumentarCantidad(int index) {
    final item = carrito[index];

    if (item.cantidad < item.producto.stock) {
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
  // CALCULOS
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
          content: Text('Seleccione un cliente'),
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
      // 1. Crear cabecera

      final factura = Factura(
        establecimiento: '001',
        puntoEmision: '001',
        secuencial: generarSecuencial(),
        claveAcceso: '',
        fechaEmision: DateTime.now(),
        idCliente: clienteSeleccionado!.idCliente,
        subtotalSinImpuestos: subtotal,
        totalDescuento: 0,
        subtotalIva: subtotal,
        propina: 0,
        importeTotal: total,
        estadoSri: 'PENDIENTE',
      );

      final facturaCreada =
          await FacturaService.crearFactura(factura);

      final idFactura = facturaCreada.idFactura;

      if (idFactura == null) {
        throw Exception(
          'El servidor no devolvió el ID de la factura',
        );
      }

      // 2. Crear detalles

      for (final item in carrito) {
        final detalle = FacturaDetalle(
          idFactura: idFactura,
          idProducto: item.producto.idProducto,
          cantidad: item.cantidad,
          precioUnitario: item.producto.precioUnitario,
          descuento: 0,
          subtotal: item.subtotal,
          valorIva: item.iva,
          total: item.total,
        );

        await FacturaDetalleService.crearDetalle(
          detalle,
        );
      }

      // 3. Crear pago

      final pago = FacturaPago(
        idFactura: idFactura,
        formaPago: formaPago,
        total: total,
      );

      await FacturaPagoService.crearPago(pago);

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
          duration: const Duration(seconds: 5),
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
      appBar: AppBar(
        title: const Text('Facturas'),
      ),
      body: cargandoDatos
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _contenido(),
    );
  }

  Widget _contenido() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          'NUEVA FACTURA',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        _buscadorCliente(),

        const SizedBox(height: 16),

        _clienteSeleccionado(),

        const SizedBox(height: 16),

        _buscadorProducto(),

        const SizedBox(height: 16),

        _listaCarrito(),

        const SizedBox(height: 16),

        _resumen(),

        const SizedBox(height: 16),

        _formaPago(),

        const SizedBox(height: 20),

        _botonGenerar(),

        const SizedBox(height: 30),

        const Text(
          'FACTURAS REGISTRADAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        _listaFacturas(),
      ],
    );
  }

  // ============================================================
  // WIDGET BUSCADOR CLIENTE
  // ============================================================

  Widget _buscadorCliente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cliente',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: clienteController,
          decoration: InputDecoration(
            hintText:
                'Buscar por nombre, identificación, correo...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  clienteController.clear();
                  clienteSeleccionado = null;
                });
              },
            ),
            border: const OutlineInputBorder(),
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
        buscarClientes(clienteController.text);

    if (clienteController.text.trim().isEmpty ||
        resultados.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: resultados.map((cliente) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              cliente.razonSocial,
            ),
            subtitle: Text(
              '${cliente.identificacion} • ${cliente.email}',
            ),
            onTap: () {
              seleccionarCliente(cliente);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _clienteSeleccionado() {
    if (clienteSeleccionado == null) {
      return const SizedBox();
    }

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          clienteSeleccionado!.razonSocial,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Identificación: '
          '${clienteSeleccionado!.identificacion}\n'
          'Correo: ${clienteSeleccionado!.email}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              clienteSeleccionado = null;
              clienteController.clear();
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET BUSCADOR PRODUCTO
  // ============================================================

  Widget _buscadorProducto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: productoController,
          decoration: InputDecoration(
            hintText: 'Buscar producto o código...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  productoController.clear();
                  productoSeleccionado = null;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),

        _resultadosProductos(),
      ],
    );
  }

  Widget _resultadosProductos() {
    final resultados =
        buscarProductos(productoController.text);

    if (productoController.text.trim().isEmpty ||
        resultados.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: resultados.map((producto) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.inventory_2),
            ),
            title: Text(
              producto.nombre,
            ),
            subtitle: Text(
              'Código: ${producto.codigoPrincipal ?? 'Sin código'}\n'
              'Precio: ${formatoMoneda(producto.precioUnitario)}'
              ' • Stock: ${producto.stock}',
            ),
            isThreeLine: true,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              seleccionarProducto(producto);
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Icon(
                Icons.shopping_cart_outlined,
                size: 45,
              ),
              SizedBox(height: 8),
              Text(
                'No hay productos agregados',
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'Detalle de factura',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(),

          ...carrito.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return ListTile(
              title: Text(
                item.producto.nombre,
              ),
              subtitle: Text(
                '${formatoMoneda(item.producto.precioUnitario)}'
                ' x ${item.cantidad}',
              ),
              leading: CircleAvatar(
                child: Text(
                  '${item.cantidad}',
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      disminuirCantidad(index);
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),
                  Text(
                    formatoMoneda(item.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      aumentarCantidad(index);
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _resumen() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
      ),
    );
  }

  Widget _filaResumen(
    String titulo,
    double valor, {
    bool grande = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: grande ? 20 : 16,
              fontWeight: grande
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            formatoMoneda(valor),
            style: TextStyle(
              fontSize: grande ? 20 : 16,
              fontWeight: grande
                  ? FontWeight.bold
                  : FontWeight.normal,
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
    return DropdownButtonFormField<String>(
      value: formaPago,
      decoration: const InputDecoration(
        labelText: 'Forma de pago',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: const [
        DropdownMenuItem(
          value: 'EFECTIVO',
          child: Text('EFECTIVO'),
        ),
        DropdownMenuItem(
          value: 'TARJETA',
          child: Text('TARJETA'),
        ),
        DropdownMenuItem(
          value: 'TRANSFERENCIA',
          child: Text('TRANSFERENCIA'),
        ),
      ],
      onChanged: (valor) {
        if (valor == null) return;

        setState(() {
          formaPago = valor;
        });
      },
    );
  }

  // ============================================================
  // BOTON
  // ============================================================

  Widget _botonGenerar() {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed:
            generandoFactura ? null : generarFactura,
        icon: generandoFactura
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.receipt_long),
        label: Text(
          generandoFactura
              ? 'GENERANDO...'
              : 'GENERAR FACTURA',
        ),
      ),
    );
  }

  // ============================================================
  // LISTA DE FACTURAS
  // ============================================================

  Widget _listaFacturas() {
    return FutureBuilder<List<Factura>>(
      future: facturas,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No existen facturas registradas',
              ),
            ),
          );
        }

        return Column(
          children: data.map((factura) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long),
                ),
                title: Text(
                  'Factura #${factura.idFactura}',
                ),
                subtitle: Text(
                  'Cliente: ${factura.idCliente}\n'
                  'Estado: ${factura.estadoSri}',
                ),
                trailing: Text(
                  formatoMoneda(
                    factura.importeTotal,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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
    return producto.precioUnitario * cantidad;
  }

  double get iva {
    return subtotal * (producto.tarifaIva / 100);
  }

  double get total {
    return subtotal + iva;
  }
}