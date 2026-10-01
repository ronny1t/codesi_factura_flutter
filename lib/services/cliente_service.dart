import '../models/cliente.dart';
import 'api_service.dart';

class ClienteService {
  // ============================================================
  // OBTENER CLIENTES
  // ============================================================

  static Future<List<Cliente>> obtenerClientes() async {
    final data = await ApiService.get('Clientes');

    return data.map<Cliente>((json) {
      return Cliente.fromJson(
        Map<String, dynamic>.from(json),
      );
    }).toList();
  }

  // ============================================================
  // CREAR CLIENTE
  // ============================================================

  static Future<void> crearCliente(
    Cliente cliente,
  ) async {
    await ApiService.post(
      'Clientes',
      cliente.toJson(),
    );
  }

  // ============================================================
  // ACTUALIZAR CLIENTE
  // ============================================================

  static Future<void> actualizarCliente(
    Cliente cliente,
  ) async {
    await ApiService.put(
      'Clientes/${cliente.idCliente}',
      cliente.toJson(),
    );
  }
}