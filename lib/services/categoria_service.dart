import '../models/categoria.dart';
import 'api_service.dart';

class CategoriaService {
  static Future<List<Categoria>> obtenerCategorias() async {
    final data = await ApiService.get('Categorias');

    return data
        .map<Categoria>(
          (json) => Categoria.fromJson(json),
        )
        .toList();
  }
}