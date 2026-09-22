import '../models/cliente.dart';
import 'api_service.dart';

class ClienteService {
  // ============================================================
  // OBTENER CLIENTES
  // ============================================================

  static Future<List<Cliente>> obtenerClientes() async {
    final data = await ApiService.get('Clientes');

    return (data as List)
        .map<Cliente>(
          (json) => Cliente.fromJson(json),
        )
        .toList();
  }

  // ============================================================
  // CREAR CLIENTE
  // ============================================================

  static Future<void> crearCliente(
    Cliente cliente,
  ) async {
    await ApiService.post(
      '/Clientes',
      cliente.toJson(),
    );
  }
}