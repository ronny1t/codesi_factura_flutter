import '../models/cliente.dart';
import 'api_service.dart';

class ClienteService {
  static Future<List<Cliente>> obtenerClientes() async {
    final data = await ApiService.get('Clientes');

    return data
        .map<Cliente>(
          (json) => Cliente.fromJson(json),
        )
        .toList();
  }
}