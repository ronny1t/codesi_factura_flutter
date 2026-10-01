import '../models/factura.dart';
import '../models/factura_detalle.dart';

import 'api_service.dart';
import 'factura_pdf_service.dart';

class FacturaService {
  // ============================================
  // OBTENER TODAS LAS FACTURAS
  // ============================================

  static Future<List<Factura>> obtenerFacturas() async {
    final data = await ApiService.get('Facturas');

    print('====================================');
    print('CONVIRTIENDO FACTURAS');
    print('Cantidad: ${data.length}');

    return data.map<Factura>((json) {
      print('FACTURA JSON: $json');

      try {
        final factura = Factura.fromJson(
          Map<String, dynamic>.from(json),
        );

        print(
          'FACTURA OK: ${factura.idFactura}',
        );

        return factura;
      } catch (e, stack) {
        print('ERROR CON FACTURA: $e');
        print(stack);
        rethrow;
      }
    }).toList();
  }

  // ============================================
  // CREAR SOLAMENTE LA CABECERA
  // ============================================

  static Future<Factura> crearFactura(
    Factura factura,
  ) async {
    final data = await ApiService.post(
      'Facturas',
      {
        'establecimiento': factura.establecimiento,
        'punto_emision': factura.puntoEmision,
        'secuencial': factura.secuencial,
        'clave_acceso': factura.claveAcceso,
        'fecha_emision':
            factura.fechaEmision.toIso8601String(),
        'id_cliente': factura.idCliente,
        'subtotal_sin_impuestos':
            factura.subtotalSinImpuestos,
        'total_descuento': factura.totalDescuento,
        'subtotal_iva': factura.subtotalIva,
        'propina': factura.propina,
        'importe_total': factura.importeTotal,
        'estado_sri': factura.estadoSri,
      },
    );

    return Factura.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================
  // CREAR FACTURA COMPLETA
  //
  // CABECERA + DETALLES + PAGO
  // ============================================

  static Future<Factura> crearFacturaCompleta({
    required Factura factura,
    required List<FacturaDetalle> detalles,
    required String formaPago,
    required double totalPago,
  }) async {
    print('====================================');
    print('CREANDO FACTURA COMPLETA');
    print('Cliente: ${factura.idCliente}');
    print('Detalles: ${detalles.length}');
    print('Forma de pago: $formaPago');
    print('Total pago: $totalPago');
    print('====================================');

    final data = await ApiService.post(
      'Facturas/completa',
      {
        'establecimiento':
            factura.establecimiento,

        'punto_emision':
            factura.puntoEmision,

        'fecha_emision':
            factura.fechaEmision.toIso8601String(),

        'id_cliente':
            factura.idCliente,

        'subtotal_sin_impuestos':
            factura.subtotalSinImpuestos,

        'total_descuento':
            factura.totalDescuento,

        'subtotal_iva':
            factura.subtotalIva,

        'propina':
            factura.propina,

        'importe_total':
            factura.importeTotal,

        'estado_sri':
            factura.estadoSri,

        'detalles':
            detalles.map((detalle) {
          return {
            'idProducto':
                detalle.idProducto,

            'cantidad':
                detalle.cantidad,

            'precioUnitario':
                detalle.precioUnitario,

            'descuento':
                detalle.descuento,

            'subtotal':
                detalle.subtotal,

            'valorIva':
                detalle.valorIva,

            'total':
                detalle.total,
          };
        }).toList(),

        'forma_pago':
            formaPago,

        'total_pago':
            totalPago,
      },
    );

    print('====================================');
    print('FACTURA COMPLETA CREADA');
    print('RESPUESTA: $data');
    print('====================================');

    return Factura.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================
  // ENVIAR FACTURA POR CORREO
  //
  // 1. Genera el PDF
  // 2. Convierte el PDF a bytes
  // 3. Envía el PDF al API
  // 4. El API obtiene el cliente
  // 5. El API envía el correo mediante Gmail
  // ============================================

  static Future<dynamic> enviarFacturaPorCorreo({
    required Factura factura,
    List<dynamic> productos = const [],
  }) async {
    final idFactura = factura.idFactura;

    if (idFactura == null || idFactura <= 0) {
      throw Exception(
        'La factura no tiene un ID válido.',
      );
    }

    print('====================================');
    print('ENVIANDO FACTURA POR CORREO');
    print('ID FACTURA: $idFactura');
    print('CLIENTE: ${factura.idCliente}');
    print('====================================');

    // --------------------------------------------
    // GENERAR PDF
    // --------------------------------------------

    final pdfBytes =
        await FacturaPdfService.generarPdfBytes(
      factura,
      productos: productos,
    );

    print('PDF GENERADO');
    print(
      'TAMAÑO: ${pdfBytes.length} bytes',
    );

    // --------------------------------------------
    // NOMBRE DEL ARCHIVO
    // --------------------------------------------

    final nombreArchivo =
        'factura_${factura.establecimiento}-'
        '${factura.puntoEmision}-'
        '${factura.secuencial}.pdf';

    print(
      'NOMBRE ARCHIVO: $nombreArchivo',
    );

    // --------------------------------------------
    // ENVIAR AL API
    // --------------------------------------------

    final respuesta =
        await ApiService.postMultipart(
      'Facturas/$idFactura/enviar-correo',
      fileBytes: pdfBytes,
      fileName: nombreArchivo,
      fieldName: 'pdf',
    );

    print('====================================');
    print('FACTURA ENVIADA POR CORREO');
    print('RESPUESTA API: $respuesta');
    print('====================================');

    return respuesta;
  }
}