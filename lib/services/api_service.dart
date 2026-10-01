import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ApiService {
  /*static const String baseUrl =
      'http://10.0.2.2:5043/api';*/
     static const String baseUrl =
    'https://comparison-brisbane-chevy-deferred.trycloudflare.com/api';
  static String? _token;

  // ============================================================
  // TOKEN
  // ============================================================

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static bool get estaAutenticado {
    return _token != null && _token!.isNotEmpty;
  }

  // ============================================================
  // ROLES DEL USUARIO
  // ============================================================

  static Map<String, dynamic>? _obtenerPayloadToken() {
    try {
      if (_token == null || _token!.isEmpty) {
        return null;
      }

      final partes = _token!.split('.');

      if (partes.length != 3) {
        return null;
      }

      final payload = partes[1];

      // JWT utiliza Base64URL.
      var normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(
        base64Url.decode(normalized),
      );

      final data = jsonDecode(decoded);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return null;
    } catch (e) {
      print(
        'ERROR LEYENDO PAYLOAD DEL TOKEN: $e',
      );

      return null;
    }
  }

  static List<String> get rolesUsuario {
    final payload = _obtenerPayloadToken();

    if (payload == null) {
      return [];
    }

    final roles = <String>[];

    // ----------------------------------------------------------
    // Claim estándar / común:
    // role
    // ----------------------------------------------------------

    final role = payload['role'];

    if (role is String &&
        role.trim().isNotEmpty) {
      roles.add(role.trim());
    }

    // ----------------------------------------------------------
    // Claim:
    // roles
    // ----------------------------------------------------------

    final rolesClaim = payload['roles'];

    if (rolesClaim is String &&
        rolesClaim.trim().isNotEmpty) {
      roles.add(rolesClaim.trim());
    }

    if (rolesClaim is List) {
      for (final item in rolesClaim) {
        if (item is String &&
            item.trim().isNotEmpty) {
          roles.add(item.trim());
        }
      }
    }

    // ----------------------------------------------------------
    // Claim de Microsoft / ASP.NET:
    // http://schemas.microsoft.com/ws/2008/06/identity/claims/role
    // ----------------------------------------------------------

    const roleClaimUri =
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

    final roleUri = payload[roleClaimUri];

    if (roleUri is String &&
        roleUri.trim().isNotEmpty) {
      roles.add(roleUri.trim());
    }

    if (roleUri is List) {
      for (final item in roleUri) {
        if (item is String &&
            item.trim().isNotEmpty) {
          roles.add(item.trim());
        }
      }
    }

    return roles.toSet().toList();
  }

  static bool tieneRol(String rol) {
    return rolesUsuario.any(
      (r) => r.toLowerCase() == rol.toLowerCase(),
    );
  }

  static bool get esAdministrador {
    return tieneRol('Administrador');
  }

  static bool get esFacturacion {
    return tieneRol('Facturacion');
  }

  static bool get esBodega {
    return tieneRol('Bodega');
  }

  // ============================================================
  // PERMISOS DE FACTURAS
  // ============================================================

  static bool get puedeGestionarFacturas {
    return esAdministrador || esFacturacion;
  }

  static bool get puedeCrearFactura {
    return esAdministrador || esFacturacion;
  }

  static bool get puedeEditarFactura {
    return esAdministrador || esFacturacion;
  }

  static bool get puedeCambiarEstadoFactura {
    return esAdministrador || esFacturacion;
  }

  static bool get puedeEnviarFacturaCorreo {
    return esAdministrador || esFacturacion;
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] =
          'Bearer $_token';
    }

    return headers;
  }

  // ============================================================
  // GET
  // ============================================================

  static Future<List<dynamic>> get(
    String endpoint,
  ) async {
    try {
      final url = '$baseUrl/$endpoint';

      print('====================================');
      print('GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(),
      );

      print(
        'STATUS: ${response.statusCode}',
      );

      print(
        'RESPUESTA: ${response.body}',
      );

      print('====================================');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }

        final data = jsonDecode(
          response.body,
        );

        if (data is List) {
          return data;
        }

        return [data];
      }

      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      print('ERROR GET: $e');
      rethrow;
    }
  }

  // ============================================================
  // POST
  // ============================================================

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = '$baseUrl/$endpoint';

      print('====================================');
      print('POST: $url');
      print(
        'BODY: ${jsonEncode(body)}',
      );

      final response = await http.post(
        Uri.parse(url),
        headers: _headers(),
        body: jsonEncode(body),
      );

      print(
        'STATUS: ${response.statusCode}',
      );

      print(
        'RESPUESTA: ${response.body}',
      );

      print('====================================');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }

        return jsonDecode(
          response.body,
        );
      }

      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      print('ERROR POST: $e');
      rethrow;
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = '$baseUrl/$endpoint';

      print('====================================');
      print('PUT: $url');

      print(
        'BODY: ${jsonEncode(body)}',
      );

      final response = await http.put(
        Uri.parse(url),
        headers: _headers(),
        body: jsonEncode(body),
      );

      print(
        'STATUS: ${response.statusCode}',
      );

      print(
        'RESPUESTA: ${response.body}',
      );

      print('====================================');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }

        return jsonDecode(
          response.body,
        );
      }

      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      print('ERROR PUT: $e');
      rethrow;
    }
  }

  // ============================================================
  // POST MULTIPART
  // ============================================================

  static Future<dynamic> postMultipart(
    String endpoint, {
    required Uint8List fileBytes,
    required String fileName,
    String fieldName = 'pdf',
  }) async {
    try {
      final url = '$baseUrl/$endpoint';

      print('====================================');
      print('POST MULTIPART: $url');
      print('ARCHIVO: $fileName');
      print(
        'TAMAÑO: ${fileBytes.length} bytes',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // --------------------------------------------------------
      // Authorization
      // --------------------------------------------------------

      if (_token != null &&
          _token!.isNotEmpty) {
        request.headers['Authorization'] =
            'Bearer $_token';
      }

      // --------------------------------------------------------
      // Accept
      // --------------------------------------------------------

      request.headers['Accept'] =
          'application/json';

      // --------------------------------------------------------
      // Archivo PDF
      // --------------------------------------------------------

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ),
      );

      print(
        'ENVIANDO MULTIPART...',
      );

      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      print(
        'STATUS MULTIPART: '
        '${response.statusCode}',
      );

      print(
        'RESPUESTA MULTIPART: '
        '${response.body}',
      );

      print('====================================');

      // --------------------------------------------------------
      // Respuesta exitosa
      // --------------------------------------------------------

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }

        return jsonDecode(
          response.body,
        );
      }

      // --------------------------------------------------------
      // Error
      // --------------------------------------------------------

      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      print(
        'ERROR POST MULTIPART: $e',
      );

      rethrow;
    }
  }
}