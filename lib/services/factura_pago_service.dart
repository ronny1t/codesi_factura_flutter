import '../models/factura_pago.dart';
import 'api_service.dart';

class FacturaPagoService {
  static Future<List<FacturaPago>> obtenerPorFactura(
    int idFactura,
  ) async {
    final data = await ApiService.get(
      'FacturaPagos/factura/$idFactura',
    );

    return data
        .map((json) => FacturaPago.fromJson(json))
        .toList();
  }

  static Future<FacturaPago> crearPago(
  FacturaPago pago,
) async {
  final data = await ApiService.post(
    'FacturaPagos',
    {
      'idFactura': pago.idFactura,
      'formaPago': pago.formaPago,
      'total': pago.total,
    },
  );

  return FacturaPago.fromJson(data);
}
}