import '../models/factura_detalle.dart';
import 'api_service.dart';

class FacturaDetalleService {
  static Future<List<FacturaDetalle>> obtenerPorFactura(
    int idFactura,
  ) async {
    final data = await ApiService.get(
      'FacturaDetalles/factura/$idFactura',
    );

    return data
        .map((json) => FacturaDetalle.fromJson(json))
        .toList();
  }

  static Future<FacturaDetalle> crearDetalle(
    FacturaDetalle detalle,
  ) async {
    final data = await ApiService.post(
      'FacturaDetalles',
      detalle.toJson(),
    );

    return FacturaDetalle.fromJson(data);
  }
}