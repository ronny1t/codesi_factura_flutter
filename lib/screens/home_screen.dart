import 'package:flutter/material.dart';

import '../services/api_service.dart';

import 'categorias_screen.dart';
import 'clientes_screen.dart';
import 'facturas_screen.dart';
import 'productos_screen.dart' as productos;

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomeScreen({
    super.key,
    required this.usuario,
  });

  // ============================================================
  // INFORMACIÓN DEL USUARIO
  // ============================================================

  List<String> get roles {
    final lista = usuario['roles'];

    if (lista is List) {
      return lista.map((e) => e.toString()).toList();
    }

    return [];
  }

  String get nombreUsuario {
    return usuario['nombre']?.toString() ?? 'Usuario';
  }

  String get tipoPersona {
    return usuario['tipoPersona']?.toString() ?? '';
  }

  bool tieneRol(String rol) {
    return roles.any(
      (r) => r.toLowerCase() == rol.toLowerCase(),
    );
  }

  bool get esAdministrador {
    return tieneRol('Administrador');
  }

  bool get esFacturacion {
    return tieneRol('Facturacion');
  }

  bool get esConsulta {
    return tieneRol('Consulta');
  }

  bool get esBodega {
    return tieneRol('Bodega');
  }

  String get nombreRol {
    if (esAdministrador) {
      return 'Administrador';
    }

    if (esFacturacion) {
      return 'Facturación';
    }

    if (esBodega) {
      return 'Bodega';
    }

    if (esConsulta) {
      return 'Consulta';
    }

    return roles.isNotEmpty ? roles.first : 'Usuario';
  }

  String get inicialUsuario {
    final nombre = nombreUsuario.trim();

    if (nombre.isEmpty) {
      return 'U';
    }

    return nombre.substring(0, 1).toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final modulos = _obtenerModulos(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: _buildAppBar(context),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // BIENVENIDA
              // ------------------------------------------------

              _buildHeader(),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // RESUMEN
              // ------------------------------------------------

              _buildResumen(),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // MÓDULOS
              // ------------------------------------------------

              const Text(
                'Módulos principales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _descripcionRol(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modulos.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.90,
                ),
                itemBuilder: (context, index) {
                  final modulo = modulos[index];

                  return _ModuloCard(
                    icon: modulo.icon,
                    title: modulo.title,
                    description: modulo.description,
                    color: modulo.color,
                    onTap: modulo.onTap,
                  );
                },
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // INFORMACIÓN DEL PERFIL
              // ------------------------------------------------

              _buildInfoCard(),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // PIE
              // ------------------------------------------------

              Center(
                child: Column(
                  children: [
                    Text(
                      'Codesi Factura',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema de Facturación Universitaria',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 20,

      title: Row(
        children: [
          // ----------------------------------------------------
          // ICONO
          // ----------------------------------------------------

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF1565C0),
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          // ----------------------------------------------------
          // NOMBRE
          // ----------------------------------------------------

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Codesi Factura',
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Sistema universitario',
                  style: TextStyle(
                    color: Color(0xFF7A8496),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // MENÚ
          // ----------------------------------------------------

          PopupMenuButton<String>(
            tooltip: 'Opciones',
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF526071),
            ),
            onSelected: (value) {
              if (value == 'perfil') {
                _mostrarPerfil(context);
              }

              if (value == 'cerrar') {
                _cerrarSesion(context);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Mi perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cerrar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER PRINCIPAL
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // AVATAR
          // ----------------------------------------------------

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
              ),
            ),
            child: Center(
              child: Text(
                inicialUsuario,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ----------------------------------------------------
          // INFORMACIÓN
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  nombreUsuario,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            nombreRol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (tipoPersona.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          tipoPersona,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _buildResumen() {
    return Row(
      children: [
        Expanded(
          child: _ResumenItem(
            icon: Icons.dashboard_outlined,
            title: 'Panel',
            value: 'Principal',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ResumenItem(
            icon: Icons.security_outlined,
            title: 'Rol',
            value: nombreRol,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ResumenItem(
            icon: Icons.apps_outlined,
            title: 'Módulos',
            value: '4',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPCIÓN DEL ROL
  // ============================================================

  String _descripcionRol() {
    if (esAdministrador) {
      return 'Administra los módulos principales del sistema.';
    }

    if (esFacturacion) {
      return 'Gestiona clientes y procesos relacionados con facturación.';
    }

    if (esBodega) {
      return 'Gestiona los productos y consulta la información necesaria para bodega.';
    }

    if (esConsulta) {
      return 'Consulta la información disponible del sistema.';
    }

    return 'Módulos disponibles para tu usuario.';
  }

  // ============================================================
  // MÓDULOS
  // ============================================================

  List<_Modulo> _obtenerModulos(
    BuildContext context,
  ) {
    return [
      // ========================================================
      // FACTURAS
      // ========================================================

      _Modulo(
        icon: Icons.receipt_long_rounded,
        title: 'Facturas',
        description: esConsulta
            ? 'Consultar facturas'
            : 'Gestionar facturas',
        color: const Color(0xFF1565C0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FacturasScreen(),
            ),
          );
        },
      ),

      // ========================================================
      // CLIENTES
      // ========================================================

      _Modulo(
        icon: Icons.people_alt_rounded,
        title: 'Clientes',
        description: esConsulta
            ? 'Consultar clientes'
            : 'Gestionar clientes',
        color: const Color(0xFF3949AB),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClientesScreen(),
            ),
          );
        },
      ),

      // ========================================================
      // PRODUCTOS
      // ========================================================

      _Modulo(
        icon: Icons.inventory_2_rounded,
        title: 'Productos',
        description: esAdministrador || esBodega
            ? 'Gestionar productos'
            : 'Consultar productos',
        color: const Color(0xFFEF6C00),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const productos.ProductosScreen(),
            ),
          );
        },
      ),

      // ========================================================
      // CATEGORÍAS
      // ========================================================

      _Modulo(
        icon: Icons.category_rounded,
        title: 'Categorías',
        description: esAdministrador
            ? 'Gestionar categorías'
            : 'Consultar categorías',
        color: const Color(0xFF2E7D32),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoriasScreen(),
            ),
          );
        },
      ),
    ];
  }

  // ============================================================
  // INFORMACIÓN
  // ============================================================

  Widget _buildInfoCard() {
    String titulo;
    String descripcion;
    IconData icono;

    if (esAdministrador) {
      titulo = 'Panel de administración';
      descripcion =
          'Tienes acceso a los módulos principales del sistema y puedes administrar la información disponible.';
      icono = Icons.admin_panel_settings_outlined;
    } else if (esFacturacion) {
      titulo = 'Panel de facturación';
      descripcion =
          'Desde este panel puedes registrar y consultar facturas, clientes, productos y categorías.';
      icono = Icons.point_of_sale_outlined;
    } else if (esBodega) {
      titulo = 'Panel de bodega';
      descripcion =
          'Puedes gestionar los productos disponibles y consultar la información relacionada.';
      icono = Icons.inventory_2_outlined;
    } else {
      titulo = 'Panel de consulta';
      descripcion =
          'Tu perfil permite consultar la información disponible sin modificar los datos.';
      icono = Icons.visibility_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icono,
              color: const Color(0xFF1565C0),
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFIL
  // ============================================================

  void _mostrarPerfil(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      // IMPORTANTE:
      // Aquí usamos otro nombre para el contexto del BottomSheet.
      // No debemos confundirlo con el context original del HomeScreen.
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // INDICADOR
                // ------------------------------------------------

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // AVATAR
                // ------------------------------------------------

                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      const Color(0xFF1565C0).withOpacity(0.10),
                  child: Text(
                    inicialUsuario,
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  nombreUsuario,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  nombreRol,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                if (tipoPersona.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    tipoPersona,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ------------------------------------------------
                // ROLES
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security_outlined,
                        color: Color(0xFF1565C0),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Roles: ${roles.isEmpty ? 'Sin roles' : roles.join(', ')}',
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // BOTÓN CERRAR SESIÓN
                // ------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // ==========================================
                      // CERRAR BOTTOM SHEET
                      // ==========================================

                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      // ==========================================
                      // ABRIR CONFIRMACIÓN CON EL CONTEXTO
                      // ORIGINAL DEL HOMESCREEN
                      // ==========================================

                      Future.microtask(() {
                        if (context.mounted) {
                          _cerrarSesion(context);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                    ),
                    label: const Text(
                      'Cerrar sesión',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFFC62828),
                      side: BorderSide(
                        color: Colors.red.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  void _cerrarSesion(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      // IMPORTANTE:
      // El diálogo utiliza el Navigator principal.
      useRootNavigator: true,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFF1565C0),
              ),
              SizedBox(width: 10),
              Text('Cerrar sesión'),
            ],
          ),

          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
          ),

          actions: [
            // ==================================================
            // CANCELAR
            // ==================================================

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                ).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            // ==================================================
            // CONFIRMAR CIERRE
            // ==================================================

            ElevatedButton(
              onPressed: () {
                // ==============================================
                // 1. BORRAR TOKEN
                // ==============================================

                ApiService.clearToken();

                // ==============================================
                // 2. IR AL LOGIN
                // ==============================================

                Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// MODELO INTERNO DEL MÓDULO
// ================================================================

class _Modulo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _Modulo({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}

// ================================================================
// TARJETA DE MÓDULO
// ================================================================

class _ModuloCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModuloCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // ICONO + FLECHA
              // ------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 25,
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 15,
                  ),
                ],
              ),

              const Spacer(),

              // ------------------------------------------------
              // TÍTULO
              // ------------------------------------------------

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 5),

              // ------------------------------------------------
              // DESCRIPCIÓN
              // ------------------------------------------------

              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TARJETA DE RESUMEN
// ================================================================

class _ResumenItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ResumenItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF1565C0),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
        ],
      ),
    );
  }
}