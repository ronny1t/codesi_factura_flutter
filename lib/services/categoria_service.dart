import '../models/categoria.dart';
import 'api_service.dart';

class CategoriaService {
  // ============================================================
  // OBTENER CATEGORÍAS
  // ============================================================

  static Future<List<Categoria>> obtenerCategorias() async {
    final data = await ApiService.get('Categorias');

    return data
        .map<Categoria>(
          (json) => Categoria.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ============================================================
  // CREAR CATEGORÍA
  // ============================================================

  static Future<Categoria> crearCategoria(
    Categoria categoria,
  ) async {
    final data = await ApiService.post(
      'Categorias',
      categoria.toJson(),
    );

    return Categoria.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // ACTUALIZAR CATEGORÍA
  // ============================================================

  static Future<void> actualizarCategoria(
    Categoria categoria,
  ) async {
    await ApiService.put(
      'Categorias/${categoria.idCategoria}',
      categoria.toJson(),
    );
  }

  // ============================================================
  // DESACTIVAR CATEGORÍA
  // ============================================================

  static Future<void> desactivarCategoria(
    int idCategoria,
  ) async {
    await ApiService.put(
      'Categorias/$idCategoria/desactivar',
      {},
    );
  }

  // ============================================================
  // ACTIVAR CATEGORÍA
  // ============================================================

  static Future<void> activarCategoria(
    int idCategoria,
  ) async {
    await ApiService.put(
      'Categorias/$idCategoria/activar',
      {},
    );
  }
}