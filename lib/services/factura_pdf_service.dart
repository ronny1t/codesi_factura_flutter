import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cliente.dart';
import '../models/factura.dart';
import '../models/factura_detalle.dart';
import '../models/factura_pago.dart';

import '../services/cliente_service.dart';
import '../services/factura_detalle_service.dart';
import '../services/factura_pago_service.dart';

class FacturaPdfService {
  // ============================================================
  // DESCARGAR / GUARDAR PDF
  // ============================================================

  static Future<void> descargarFactura({
    required Factura factura,
    required List<dynamic> productos,
  }) async {
    final idFactura = factura.idFactura;

    if (idFactura == null || idFactura <= 0) {
      throw Exception(
        'La factura no tiene un ID válido.',
      );
    }

    final detalles =
        await FacturaDetalleService.obtenerPorFactura(
      idFactura,
    );

    final cliente =
        await _obtenerCliente(factura.idCliente);

    final pagos =
        await FacturaPagoService.obtenerPorFactura(
      idFactura,
    );

    final bytes = await _generarPdf(
      factura: factura,
      detalles: detalles,
      productos: productos,
      cliente: cliente,
      pagos: pagos,
    );

    await Printing.layoutPdf(
      name: 'RIDE_demo_${factura.secuencial}.pdf',
      onLayout: (PdfPageFormat format) async {
        return bytes;
      },
    );
  }

  // ============================================================
  // GUARDAR PDF
  // ============================================================

  static Future<void> guardarPdf(
    Factura factura,
  ) async {
    final idFactura = factura.idFactura;

    if (idFactura == null || idFactura <= 0) {
      throw Exception(
        'La factura no tiene un ID válido.',
      );
    }

    final detalles =
        await FacturaDetalleService.obtenerPorFactura(
      idFactura,
    );

    final cliente =
        await _obtenerCliente(factura.idCliente);

    final pagos =
        await FacturaPagoService.obtenerPorFactura(
      idFactura,
    );

    final bytes = await _generarPdf(
      factura: factura,
      detalles: detalles,
      productos: const [],
      cliente: cliente,
      pagos: pagos,
    );

    await Printing.layoutPdf(
      name: 'RIDE_demo_${factura.secuencial}.pdf',
      onLayout: (PdfPageFormat format) async {
        return bytes;
      },
    );
  }

  // ============================================================
  // COMPARTIR PDF
  // ============================================================

  static Future<void> compartirPdf(
    Factura factura,
  ) async {
    final idFactura = factura.idFactura;

    if (idFactura == null || idFactura <= 0) {
      throw Exception(
        'La factura no tiene un ID válido.',
      );
    }

    final detalles =
        await FacturaDetalleService.obtenerPorFactura(
      idFactura,
    );

    final cliente =
        await _obtenerCliente(factura.idCliente);

    final pagos =
        await FacturaPagoService.obtenerPorFactura(
      idFactura,
    );

    final bytes = await _generarPdf(
      factura: factura,
      detalles: detalles,
      productos: const [],
      cliente: cliente,
      pagos: pagos,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'RIDE_demo_${factura.secuencial}.pdf',
    );
  }

  // ============================================================
  // GENERAR PDF EN MEMORIA
  // ============================================================
  //
  // Este método genera exactamente el mismo PDF utilizado
  // para guardar, imprimir y compartir.
  //
  // Se utilizará posteriormente para enviarlo al backend
  // mediante multipart/form-data.
  // ============================================================

  static Future<Uint8List> generarPdfBytes(
    Factura factura, {
    List<dynamic> productos = const [],
  }) async {
    final idFactura = factura.idFactura;

    if (idFactura == null || idFactura <= 0) {
      throw Exception(
        'La factura no tiene un ID válido.',
      );
    }

    final detalles =
        await FacturaDetalleService.obtenerPorFactura(
      idFactura,
    );

    final cliente =
        await _obtenerCliente(factura.idCliente);

    final pagos =
        await FacturaPagoService.obtenerPorFactura(
      idFactura,
    );

    return await _generarPdf(
      factura: factura,
      detalles: detalles,
      productos: productos,
      cliente: cliente,
      pagos: pagos,
    );
  }

  // ============================================================
  // OBTENER CLIENTE
  // ============================================================

  static Future<Cliente?> _obtenerCliente(
    int idCliente,
  ) async {
    try {
      final clientes =
          await ClienteService.obtenerClientes();

      for (final cliente in clientes) {
        if (cliente.idCliente == idCliente) {
          return cliente;
        }
      }
    } catch (_) {
      // Si no se puede consultar el cliente,
      // el PDF continuará mostrando el ID.
    }

    return null;
  }

  // ============================================================
  // GENERAR PDF
  // ============================================================

  static Future<Uint8List> _generarPdf({
    required Factura factura,
    required List<FacturaDetalle> detalles,
    required List<dynamic> productos,
    required Cliente? cliente,
    required List<FacturaPago> pagos,
  }) async {
    final pdf = pw.Document();

    final numeroFactura =
        '${factura.establecimiento}-${factura.puntoEmision}-${factura.secuencial}';

    final formaPago =
        pagos.isNotEmpty
            ? pagos.first.formaPago
            : 'No registrada';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) {
          return _encabezadoSuperior(
            factura,
            numeroFactura,
          );
        },
        footer: (context) {
          return _piePagina(context);
        },
        build: (context) {
          return [
            pw.SizedBox(height: 14),

            // ==================================================
            // LEYENDA DEMOSTRATIVA
            // ==================================================

            _documentoDemostrativo(),

            pw.SizedBox(height: 14),

            // ==================================================
            // INFORMACIÓN DEL EMISOR
            // ==================================================

            _seccionEmisor(factura),

            pw.SizedBox(height: 12),

            // ==================================================
            // INFORMACIÓN DEL COMPROBANTE
            // ==================================================

            _seccionComprobante(
              factura,
              numeroFactura,
            ),

            pw.SizedBox(height: 12),

            // ==================================================
            // CLIENTE
            // ==================================================

            _seccionCliente(
              factura,
              cliente,
            ),

            pw.SizedBox(height: 16),

            // ==================================================
            // DETALLE
            // ==================================================

            pw.Text(
              'DETALLE DE PRODUCTOS',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 7),

            _tablaDetalles(
              detalles,
              productos,
            ),

            pw.SizedBox(height: 14),

            // ==================================================
            // FORMA DE PAGO + TOTALES
            // ==================================================

            pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: _seccionPago(
                    pagos,
                    formaPago,
                  ),
                ),

                pw.SizedBox(width: 16),

                pw.Expanded(
                  flex: 2,
                  child: _seccionTotales(
                    factura,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // ==================================================
            // CÓDIGO DE DEMOSTRACIÓN
            // ==================================================

            _seccionCodigoDemostracion(
              factura,
            ),

            pw.SizedBox(height: 14),

            // ==================================================
            // OBSERVACIÓN ACADÉMICA
            // ==================================================

            _notaAcademica(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // ENCABEZADO SUPERIOR
  // ============================================================

  static pw.Widget _encabezadoSuperior(
    Factura factura,
    String numeroFactura,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey700,
          width: 1,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // INFORMACIÓN DEL SISTEMA
          // ----------------------------------------------------

          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SISTEMA ACADÉMICO DE FACTURACIÓN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Text(
                  'Representación impresa de comprobante',
                  style: const pw.TextStyle(
                    fontSize: 8,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  'Documento generado para demostración académica',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(width: 16),

          // ----------------------------------------------------
          // FACTURA
          // ----------------------------------------------------

          pw.Expanded(
            flex: 4,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey600,
                ),
                borderRadius:
                    pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'FACTURA',
                      style: pw.TextStyle(
                        fontSize: 17,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 7),

                  _miniFila(
                    'N.º:',
                    numeroFactura,
                  ),

                  _miniFila(
                    'Fecha:',
                    _formatearFecha(
                      factura.fechaEmision,
                    ),
                  ),

                  _miniFila(
                    'Estado:',
                    factura.estadoSri,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOCUMENTO DEMOSTRATIVO
  // ============================================================

  static pw.Widget _documentoDemostrativo() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(
          color: PdfColors.orange700,
        ),
        borderRadius:
            pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'DOCUMENTO DEMOSTRATIVO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange900,
            ),
          ),

          pw.SizedBox(height: 3),

          pw.Text(
            'SIN VALIDEZ TRIBUTARIA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMISOR
  // ============================================================

  static pw.Widget _seccionEmisor(
    Factura factura,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EMISOR',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Sistema Académico de Facturación',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 3),

          pw.Text(
            'Aplicación demostrativa universitaria',
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),

          pw.SizedBox(height: 3),

          pw.Text(
            'Establecimiento: ${factura.establecimiento}    '
            'Punto de emisión: ${factura.puntoEmision}',
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPROBANTE
  // ============================================================

  static pw.Widget _seccionComprobante(
    Factura factura,
    String numeroFactura,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL COMPROBANTE',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 7),

          pw.Row(
            children: [
              pw.Expanded(
                child: _dato(
                  'Número de factura',
                  numeroFactura,
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: _dato(
                  'Fecha de emisión',
                  _formatearFecha(
                    factura.fechaEmision,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 6),

          _dato(
            'Estado del comprobante',
            factura.estadoSri,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLIENTE
  // ============================================================

  static pw.Widget _seccionCliente(
    Factura factura,
    Cliente? cliente,
  ) {
    final identificacion =
        cliente?.identificacion ??
        'ID cliente: ${factura.idCliente}';

    final razonSocial =
        cliente?.razonSocial ??
        'Cliente no disponible';

    final tipoIdentificacion =
        cliente?.tipoIdentificacion ?? '';

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL CLIENTE',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 7),

          pw.Row(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: _dato(
                  'Razón social',
                  razonSocial,
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: _dato(
                  'Tipo',
                  tipoIdentificacion.isEmpty
                      ? '—'
                      : tipoIdentificacion,
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: _dato(
                  'Identificación',
                  identificacion,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 7),

          pw.Row(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _dato(
                  'Dirección',
                  _textoOpcional(
                    cliente?.direccion,
                  ),
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: _dato(
                  'Teléfono',
                  _textoOpcional(
                    cliente?.telefono,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 7),

          _dato(
            'Correo electrónico',
            _textoOpcional(
              cliente?.email,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLA DE DETALLES
  // ============================================================

  static pw.Widget _tablaDetalles(
    List<FacturaDetalle> detalles,
    List<dynamic> productos,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.1),
        1: const pw.FlexColumnWidth(3.5),
        2: const pw.FlexColumnWidth(0.9),
        3: const pw.FlexColumnWidth(1.3),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _celdaTitulo('Código'),
            _celdaTitulo('Descripción'),
            _celdaTitulo('Cant.'),
            _celdaTitulo('P. Unit.'),
            _celdaTitulo('Desc.'),
            _celdaTitulo('Total'),
          ],
        ),

        ...detalles.map(
          (detalle) {
            return pw.TableRow(
              children: [
                _celda(
                  _codigoProducto(
                    detalle.idProducto,
                    productos,
                  ),
                ),

                _celda(
                  _nombreProductoTexto(
                    detalle.idProducto,
                    productos,
                  ),
                ),

                _celdaCentro(
                  detalle.cantidad.toString(),
                ),

                _celdaMoneda(
                  detalle.precioUnitario,
                ),

                _celdaMoneda(
                  detalle.descuento,
                ),

                _celdaMoneda(
                  detalle.total,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // PAGOS
  // ============================================================

  static pw.Widget _seccionPago(
    List<FacturaPago> pagos,
    String formaPago,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FORMA DE PAGO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          if (pagos.isEmpty)
            _dato(
              'Forma de pago',
              formaPago,
            ),

          if (pagos.isNotEmpty)
            ...pagos.map(
              (pago) => pw.Padding(
                padding:
                    const pw.EdgeInsets.only(
                  bottom: 5,
                ),
                child: _dato(
                  pago.formaPago,
                  '\$${pago.total.toStringAsFixed(2)}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTALES
  // ============================================================

  static pw.Widget _seccionTotales(
    Factura factura,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        children: [
          _filaMoneda(
            'Subtotal',
            factura.subtotalSinImpuestos,
          ),

          _filaMoneda(
            'Descuento',
            factura.totalDescuento,
          ),

          _filaMoneda(
            'Subtotal IVA',
            factura.subtotalIva,
          ),

          _filaMoneda(
            'Propina',
            factura.propina,
          ),

          pw.Divider(
            color: PdfColors.grey500,
          ),

          _filaMoneda(
            'TOTAL',
            factura.importeTotal,
            grande: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CÓDIGO DEMOSTRACIÓN
  // ============================================================

  static pw.Widget _seccionCodigoDemostracion(
    Factura factura,
  ) {
    final codigo =
        factura.claveAcceso.isEmpty
            ? 'DEMO-${factura.idFactura ?? 0}'
            : factura.claveAcceso;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CÓDIGO DE DEMOSTRACIÓN',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            codigo,
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            'Este código corresponde únicamente al entorno académico '
            'demostrativo y no representa una clave de acceso '
            'autorizada por el SRI.',
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTA ACADÉMICA
  // ============================================================

  static pw.Widget _notaAcademica() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'DOCUMENTO DEMOSTRATIVO — SIN VALIDEZ TRIBUTARIA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            'Este documento forma parte de un sistema académico '
            'de demostración de facturación electrónica. '
            'No constituye un comprobante electrónico autorizado.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PIE DE PÁGINA
  // ============================================================

  static pw.Widget _piePagina(
    pw.Context context,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: 8,
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Sistema Académico de Facturación',
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),

          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATO
  // ============================================================

  static pw.Widget _dato(
    String titulo,
    String valor,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey700,
          ),
        ),

        pw.SizedBox(height: 2),

        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MINI FILA
  // ============================================================

  static pw.Widget _miniFila(
    String titulo,
    String valor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(
        bottom: 3,
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 45,
            child: pw.Text(
              titulo,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Expanded(
            child: pw.Text(
              valor,
              style: const pw.TextStyle(
                fontSize: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILA MONEDA
  // ============================================================

  static pw.Widget _filaMoneda(
    String titulo,
    double valor, {
    bool grande = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: grande ? 10 : 8,
              fontWeight:
                  grande
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
            ),
          ),

          pw.Text(
            '\$${valor.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: grande ? 12 : 8,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CELDA TÍTULO
  // ============================================================

  static pw.Widget _celdaTitulo(
    String texto,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // CELDA
  // ============================================================

  static pw.Widget _celda(
    String texto,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: const pw.TextStyle(
          fontSize: 7,
        ),
      ),
    );
  }

  // ============================================================
  // CELDA CENTRADA
  // ============================================================

  static pw.Widget _celdaCentro(
    String texto,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Center(
        child: pw.Text(
          texto,
          style: const pw.TextStyle(
            fontSize: 7,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CELDA MONEDA
  // ============================================================

  static pw.Widget _celdaMoneda(
    double valor,
  ) {
    return _celda(
      '\$${valor.toStringAsFixed(2)}',
    );
  }

  // ============================================================
  // CÓDIGO PRODUCTO
  // ============================================================

  static String _codigoProducto(
    int idProducto,
    List<dynamic> productos,
  ) {
    for (final producto in productos) {
      try {
        if (producto.idProducto == idProducto) {
          final codigo =
              producto.codigoPrincipal;

          if (codigo != null &&
              codigo.toString().isNotEmpty) {
            return codigo.toString();
          }
        }
      } catch (_) {}
    }

    return idProducto.toString();
  }

  // ============================================================
  // NOMBRE PRODUCTO
  // ============================================================

  static String _nombreProductoTexto(
    int idProducto,
    List<dynamic> productos,
  ) {
    for (final producto in productos) {
      try {
        if (producto.idProducto == idProducto) {
          return producto.nombre.toString();
        }
      } catch (_) {}
    }

    return 'Producto #$idProducto';
  }

  // ============================================================
  // TEXTO OPCIONAL
  // ============================================================

  static String _textoOpcional(
    String? valor,
  ) {
    if (valor == null ||
        valor.trim().isEmpty) {
      return 'No registrado';
    }

    return valor;
  }

  // ============================================================
  // FECHA
  // ============================================================

  static String _formatearFecha(
    DateTime fecha,
  ) {
    final dia =
        fecha.day.toString().padLeft(2, '0');

    final mes =
        fecha.month.toString().padLeft(2, '0');

    final hora =
        fecha.hour.toString().padLeft(2, '0');

    final minuto =
        fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} '
        '$hora:$minuto';
  }
}