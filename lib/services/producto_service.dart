import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  // ============================================================
  // OBTENER PRODUCTOS ACTIVOS
  // ============================================================

  static Future<List<Producto>> obtenerProductos() async {
    final data = await ApiService.get('Productos');

    print('====================================');
    print('CONVIRTIENDO PRODUCTOS');
    print('Cantidad: ${data.length}');

    return data.map<Producto>((json) {
      print('PRODUCTO JSON: $json');

      try {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(json),
        );

        print(
          'PRODUCTO OK: ${producto.idProducto}',
        );

        return producto;
      } catch (e, stack) {
        print('ERROR CON PRODUCTO: $e');
        print(stack);
        rethrow;
      }
    }).toList();
  }

  // ============================================================
  // OBTENER PRODUCTOS DESACTIVADOS
  // ============================================================

  static Future<List<Producto>>
      obtenerProductosDesactivados() async {
    final data = await ApiService.get(
      'Productos/desactivados',
    );

    print('====================================');
    print('PRODUCTOS DESACTIVADOS');
    print('Cantidad: ${data.length}');

    return data.map<Producto>((json) {
      print('PRODUCTO DESACTIVADO JSON: $json');

      return Producto.fromJson(
        Map<String, dynamic>.from(json),
      );
    }).toList();
  }

  // ============================================================
  // CREAR PRODUCTO
  // ============================================================

  static Future<Producto> crearProducto(
    Producto producto,
  ) async {
    final data = await ApiService.post(
      'Productos',
      producto.toJson(),
    );

    return Producto.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // ACTUALIZAR PRODUCTO
  // ============================================================

  static Future<Producto> actualizarProducto(
    Producto producto,
  ) async {
    final data = await ApiService.put(
      'Productos/${producto.idProducto}',
      producto.toJson(),
    );

    return Producto.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // DESACTIVAR PRODUCTO
  // ============================================================

  static Future<void> desactivarProducto(
    int idProducto,
  ) async {
    await ApiService.put(
      'Productos/$idProducto/desactivar',
      {},
    );
  }

  // ============================================================
  // ACTIVAR PRODUCTO
  // ============================================================

  static Future<void> activarProducto(
    int idProducto,
  ) async {
    await ApiService.put(
      'Productos/$idProducto/activar',
      {},
    );
  }
}