import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  static Future<List<Producto>> obtenerProductos() async {
    final data = await ApiService.get('Productos');

    return data
        .map<Producto>(
          (json) => Producto.fromJson(json),
        )
        .toList();
  }
}