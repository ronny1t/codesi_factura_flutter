import '../models/factura.dart';
import 'api_service.dart';

class FacturaService {
  static Future<List<Factura>> obtenerFacturas() async {
    final data = await ApiService.get('Facturas');

    return data
        .map((json) => Factura.fromJson(json))
        .toList();
  }

  static Future<Factura> crearFactura(Factura factura) async {
    final data = await ApiService.post(
      'Facturas',
      factura.toJson(),
    );

    return Factura.fromJson(data);
  }
}