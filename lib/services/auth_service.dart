import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String cedula,
  }) async {
    final response = await ApiService.post(
      'Auth/login',
      {
        'Email': email.trim(),
        'Cedula': cedula.trim(),
      },
    );

    if (response == null) {
      throw Exception('El servidor no devolvió información de sesión.');
    }

    final data = Map<String, dynamic>.from(response);

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('El servidor no devolvió un token JWT.');
    }

    // Guardamos el JWT para las siguientes peticiones.
    ApiService.setToken(token);

    return data;
  }

  static void logout() {
    ApiService.clearToken();
  }
}