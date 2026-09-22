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

  static Future<Producto> crearProducto(
    Producto producto,
  ) async {
    final data = await ApiService.post(
      'Productos',
      {
        'codigo_principal': producto.codigoPrincipal,
        'nombre': producto.nombre,
        'precio_unitario': producto.precioUnitario,
        'stock': producto.stock,
        'tarifa_iva': producto.tarifaIva,
        'id_categoria': producto.idCategoria,
        'activo': producto.activo,
      },
    );

    return Producto.fromJson(data);
  }
}