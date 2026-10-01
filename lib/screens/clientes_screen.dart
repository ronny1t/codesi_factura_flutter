import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../services/api_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  // ============================================================
  // COLORES
  // ============================================================

  static const Color azul = Color(0xFF1565C0);
  static const Color azulOscuro = Color(0xFF0D47A1);
  static const Color fondo = Color(0xFFF4F7FB);
  static const Color borde = Color(0xFFD9E0E8);
  static const Color texto = Color(0xFF172B4D);
  static const Color textoSecundario = Color(0xFF6B778C);

  // ============================================================
  // VARIABLES
  // ============================================================

  List<Cliente> clientes = [];

  bool cargando = true;
  String textoBusqueda = '';

  final TextEditingController busquedaController =
      TextEditingController();

  // ============================================================
  // PERMISOS SEGÚN ROL
  // ============================================================

  bool get puedeGestionarClientes {
    return ApiService.esAdministrador ||
        ApiService.esFacturacion;
  }

  bool get esAdministrador {
    return ApiService.esAdministrador;
  }

  bool get esFacturacion {
    return ApiService.esFacturacion;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR CLIENTES
  // ============================================================

  Future<void> cargarClientes() async {
    if (mounted) {
      setState(() {
        cargando = true;
      });
    }

    try {
      final resultado =
          await ClienteService.obtenerClientes();

      if (!mounted) return;

      setState(() {
        clientes = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      mostrarError(
        'No se pudieron cargar los clientes.\n$e',
      );
    }
  }

  // ============================================================
  // CLIENTES FILTRADOS
  // ============================================================

  List<Cliente> get clientesFiltrados {
    final texto =
        textoBusqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return clientes;
    }

    return clientes.where((cliente) {
      final identificacion =
          cliente.identificacion.toLowerCase();

      final razonSocial =
          cliente.razonSocial.toLowerCase();

      final tipo =
          cliente.tipoIdentificacion.toLowerCase();

      final direccion =
          (cliente.direccion ?? '').toLowerCase();

      final telefono =
          (cliente.telefono ?? '').toLowerCase();

      final email =
          (cliente.email ?? '').toLowerCase();

      return identificacion.contains(texto) ||
          razonSocial.contains(texto) ||
          tipo.contains(texto) ||
          direccion.contains(texto) ||
          telefono.contains(texto) ||
          email.contains(texto);
    }).toList();
  }

  // ============================================================
  // NUEVO CLIENTE
  // ============================================================

  Future<void> nuevoCliente() async {
    if (!puedeGestionarClientes) {
      return;
    }

    final resultado =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ClientesCrean(),
      ),
    );

    if (resultado == true) {
      await cargarClientes();
    }
  }

  // ============================================================
  // EDITAR CLIENTE
  // ============================================================

  Future<void> editarCliente(
    Cliente cliente,
  ) async {
    if (!puedeGestionarClientes) {
      return;
    }

    final resultado =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientesCrean(
          cliente: cliente,
        ),
      ),
    );

    if (resultado == true) {
      await cargarClientes();
    }
  }

  // ============================================================
  // MENSAJE ERROR
  // ============================================================

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mensaje),
            ),
          ],
        ),
        backgroundColor:
            Colors.red.shade700,
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        duration:
            const Duration(seconds: 5),
      ),
    );
  }

  // ============================================================
  // TARJETA CLIENTE
  // ============================================================

  Widget tarjetaCliente(
    Cliente cliente,
  ) {
    final activo = cliente.activo;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
        side:
            const BorderSide(
          color: borde,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: puedeGestionarClientes
            ? () => editarCliente(cliente)
            : null,
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: activo
                      ? azul.withOpacity(0.10)
                      : Colors.grey
                          .withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  cliente.tipoIdentificacion ==
                          'CONSUMIDOR_FINAL'
                      ? Icons
                          .receipt_long_outlined
                      : Icons.person_outline,
                  color: activo
                      ? azul
                      : Colors.grey.shade600,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cliente.razonSocial,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color: texto,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        _estadoChip(
                          activo,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color:
                              textoSecundario,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            '${cliente.tipoIdentificacion}: ${cliente.identificacion}',
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if ((cliente.telefono ??
                            '')
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .phone_outlined,
                            size: 16,
                            color:
                                textoSecundario,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              cliente
                                  .telefono!,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if ((cliente.email ??
                            '')
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .email_outlined,
                            size: 16,
                            color:
                                textoSecundario,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              cliente.email!,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if ((cliente.direccion ??
                            '')
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 16,
                            color:
                                textoSecundario,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              cliente
                                  .direccion!,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ==================================================
              // BOTÓN EDITAR
              // Solo Administrador / Facturación
              // ==================================================

              if (puedeGestionarClientes) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip:
                      'Editar cliente',
                  onPressed: () =>
                      editarCliente(
                    cliente,
                  ),
                  icon:
                      const Icon(
                    Icons
                        .edit_outlined,
                    color: azul,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHIP ESTADO
  // ============================================================

  Widget _estadoChip(bool activo) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: activo
            ? Colors.green
                .withOpacity(0.10)
            : Colors.grey
                .withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            activo
                ? Icons.check_circle
                : Icons.pause_circle_outline,
            size: 13,
            color: activo
                ? Colors.green.shade700
                : Colors.grey.shade700,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            activo
                ? 'Activo'
                : 'Inactivo',
            style:
                TextStyle(
              color: activo
                  ? Colors.green.shade700
                  : Colors.grey.shade700,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget encabezado() {
    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            azul,
            azulOscuro,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                azul.withOpacity(0.20),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(
                      17),
              border:
                  Border.all(
                color:
                    Colors.white
                        .withOpacity(0.15),
              ),
            ),
            child:
                const Icon(
              Icons
                  .people_alt_outlined,
              color:
                  Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Clientes',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${clientes.length} cliente${clientes.length == 1 ? '' : 's'} registrado${clientes.length == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 13,
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
  // BUSCADOR
  // ============================================================

  Widget buscador() {
    return TextField(
      controller:
          busquedaController,
      onChanged: (valor) {
        setState(() {
          textoBusqueda =
              valor;
        });
      },
      decoration:
          InputDecoration(
        hintText:
            'Buscar por nombre, identificación, teléfono...',
        prefixIcon:
            const Icon(
          Icons
              .search_rounded,
          color: azul,
        ),
        suffixIcon:
            textoBusqueda
                    .isNotEmpty
                ? IconButton(
                    tooltip:
                        'Limpiar búsqueda',
                    onPressed: () {
                      busquedaController
                          .clear();

                      setState(() {
                        textoBusqueda =
                            '';
                      });
                    },
                    icon:
                        const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
        filled: true,
        fillColor:
            Colors.white,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  15),
          borderSide:
              const BorderSide(
            color: borde,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  15),
          borderSide:
              const BorderSide(
            color: borde,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  15),
          borderSide:
              const BorderSide(
            color: azul,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTA VACÍA
  // ============================================================

  Widget estadoVacio() {
    final hayBusqueda =
        textoBusqueda
            .trim()
            .isNotEmpty;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
                30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration:
                  BoxDecoration(
                color:
                    azul.withOpacity(
                        0.08),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                hayBusqueda
                    ? Icons
                        .search_off_rounded
                    : Icons
                        .people_outline_rounded,
                size: 45,
                color: azul,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              hayBusqueda
                  ? 'No se encontraron clientes'
                  : 'No hay clientes registrados',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: texto,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              hayBusqueda
                  ? 'Prueba con otro nombre o identificación.'
                  : puedeGestionarClientes
                      ? 'Puedes registrar el primer cliente usando el botón de abajo.'
                      : 'No hay clientes registrados.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    textoSecundario,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            if (!hayBusqueda &&
                puedeGestionarClientes) ...[
              const SizedBox(
                height: 22,
              ),
              ElevatedButton.icon(
                onPressed:
                    nuevoCliente,
                icon:
                    const Icon(
                  Icons
                      .person_add_alt_1,
                ),
                label:
                    const Text(
                  'Nuevo cliente',
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final lista =
        clientesFiltrados;

    return Scaffold(
      backgroundColor:
          fondo,

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            texto,
        elevation: 0,
        surfaceTintColor:
            Colors.white,
        title:
            const Row(
          children: [
            Icon(
              Icons
                  .people_alt_outlined,
              color: azul,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Gestión de clientes',
              style:
                  TextStyle(
                color: texto,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip:
                'Actualizar',
            onPressed:
                cargando
                    ? null
                    : cargarClientes,
            icon:
                const Icon(
              Icons
                  .refresh_rounded,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 900,
            ),
            child:
                Column(
              children: [
                Expanded(
                  child:
                      RefreshIndicator(
                    onRefresh:
                        cargarClientes,
                    color: azul,
                    child:
                        ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(
                        parent:
                            BouncingScrollPhysics(),
                      ),
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        16,
                        14,
                        16,
                        100,
                      ),
                      children: [
                        encabezado(),

                        const SizedBox(
                          height: 18,
                        ),

                        buscador(),

                        const SizedBox(
                          height: 18,
                        ),

                        if (cargando)
                          const SizedBox(
                            height: 300,
                            child:
                                Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    azul,
                              ),
                            ),
                          )
                        else if (lista
                            .isEmpty)
                          SizedBox(
                            height: 400,
                            child:
                                estadoVacio(),
                          )
                        else ...[
                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .list_alt_rounded,
                                size: 20,
                                color:
                                    azul,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                textoBusqueda
                                        .trim()
                                        .isEmpty
                                    ? 'Todos los clientes'
                                    : '${lista.length} resultado${lista.length == 1 ? '' : 's'}',
                                style:
                                    const TextStyle(
                                  color:
                                      texto,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          ...lista.map(
                            tarjetaCliente,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ==========================================================
      // BOTÓN NUEVO CLIENTE
      // Solo Administrador / Facturación
      // ==========================================================

      floatingActionButton:
          puedeGestionarClientes
              ? FloatingActionButton
                  .extended(
                  onPressed:
                      nuevoCliente,
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  icon:
                      const Icon(
                    Icons
                        .person_add_alt_1_rounded,
                  ),
                  label:
                      const Text(
                    'Nuevo cliente',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                )
              : null,
    );
  }
}

// ============================================================================
// FORMULARIO CREAR / EDITAR CLIENTE
// ============================================================================

class ClientesCrean
    extends StatefulWidget {
  final Cliente? cliente;

  const ClientesCrean({
    super.key,
    this.cliente,
  });

  @override
  State<ClientesCrean>
      createState() =>
          _ClientesCreanState();
}

class _ClientesCreanState
    extends State<ClientesCrean> {
  // ============================================================
  // COLORES
  // ============================================================

  static const Color azul =
      Color(0xFF1565C0);
  static const Color azulOscuro =
      Color(0xFF0D47A1);
  static const Color fondo =
      Color(0xFFF4F7FB);
  static const Color borde =
      Color(0xFFD9E0E8);
  static const Color texto =
      Color(0xFF172B4D);
  static const Color textoSecundario =
      Color(0xFF6B778C);

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final formKey =
      GlobalKey<FormState>();

  final identificacionController =
      TextEditingController();

  final razonSocialController =
      TextEditingController();

  final direccionController =
      TextEditingController();

  final telefonoController =
      TextEditingController();

  final emailController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  String tipoIdentificacion =
      'CEDULA';

  bool activo = true;
  bool guardando = false;

  bool get esEdicion =>
      widget.cliente != null;

  bool get puedeGestionarClientes {
    return ApiService.esAdministrador ||
        ApiService.esFacturacion;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.cliente != null) {
      final cliente =
          widget.cliente!;

      tipoIdentificacion =
          cliente.tipoIdentificacion;

      identificacionController.text =
          cliente.identificacion;

      razonSocialController.text =
          cliente.razonSocial;

      direccionController.text =
          cliente.direccion ?? '';

      telefonoController.text =
          cliente.telefono ?? '';

      emailController.text =
          cliente.email ?? '';

      activo =
          cliente.activo;
    }
  }

  @override
  void dispose() {
    identificacionController
        .dispose();

    razonSocialController
        .dispose();

    direccionController
        .dispose();

    telefonoController
        .dispose();

    emailController
        .dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDAR SOLO NÚMEROS
  // ============================================================

  String? validarIdentificacion(
      String? value) {
    final valor =
        value?.trim() ?? '';

    if (valor.isEmpty) {
      return 'Ingresa la identificación';
    }

    if (!RegExp(
            r'^\d+$')
        .hasMatch(valor)) {
      return 'La identificación debe contener solo números';
    }

    if (tipoIdentificacion ==
            'CEDULA' &&
        valor.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }

    if (tipoIdentificacion ==
            'RUC' &&
        valor.length != 13) {
      return 'El RUC debe tener 13 dígitos';
    }

    if (tipoIdentificacion ==
            'CONSUMIDOR_FINAL' &&
        valor !=
            '9999999999999') {
      return 'El consumidor final debe usar 9999999999999';
    }

    return null;
  }

  // ============================================================
  // VALIDAR TELÉFONO
  // ============================================================

  String? validarTelefono(
      String? value) {
    final valor =
        value?.trim() ?? '';

    if (valor.isEmpty) {
      return null;
    }

    if (!RegExp(
            r'^\d+$')
        .hasMatch(valor)) {
      return 'El teléfono debe contener solo números';
    }

    if (valor.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }

    return null;
  }

  // ============================================================
  // VALIDAR CORREO
  // ============================================================

  String? validarEmail(
      String? value) {
    final valor =
        value?.trim() ?? '';

    if (valor.isEmpty) {
      return null;
    }

    if (valor.length > 254) {
      return 'El correo electrónico es demasiado largo';
    }

    final regex =
        RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(valor)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  // ============================================================
  // CAMBIAR TIPO IDENTIFICACIÓN
  // ============================================================

  void cambiarTipoIdentificacion(
      String? valor) {
    if (valor == null) return;

    setState(() {
      tipoIdentificacion =
          valor;

      if (valor ==
          'CONSUMIDOR_FINAL') {
        identificacionController
                .text =
            '9999999999999';
      } else if (identificacionController
              .text ==
          '9999999999999') {
        identificacionController
            .clear();
      }
    });
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void>
      guardarCliente() async {
    if (!puedeGestionarClientes) {
      return;
    }

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      guardando = true;
    });

    final cliente =
        Cliente(
      idCliente:
          widget.cliente?.idCliente ??
              0,
      tipoIdentificacion:
          tipoIdentificacion,
      identificacion:
          identificacionController
              .text
              .trim(),
      razonSocial:
          razonSocialController
              .text
              .trim(),
      direccion:
          direccionController
                  .text
                  .trim()
                  .isEmpty
              ? null
              : direccionController
                  .text
                  .trim(),
      telefono:
          telefonoController
                  .text
                  .trim()
                  .isEmpty
              ? null
              : telefonoController
                  .text
                  .trim(),
      email:
          emailController
                  .text
                  .trim()
                  .isEmpty
              ? null
              : emailController
                  .text
                  .trim(),
      activo: activo,
    );

    try {
      if (esEdicion) {
        await ClienteService
            .actualizarCliente(
          cliente,
        );
      } else {
        await ClienteService
            .crearCliente(
          cliente,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            esEdicion
                ? 'Cliente actualizado correctamente'
                : 'Cliente creado correctamente',
          ),
          backgroundColor:
              Colors.green.shade700,
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );

      Navigator.of(context)
          .pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el cliente.\n$e',
          ),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
    }
  }

  // ============================================================
  // CAMPO
  // ============================================================

  InputDecoration
      decoracionCampo({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          Icon(
        icon,
        color: azul,
      ),
      filled: true,
      fillColor:
          Colors.white,
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
                14),
        borderSide:
            const BorderSide(
          color: borde,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
                14),
        borderSide:
            const BorderSide(
          color: borde,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
                14),
        borderSide:
            const BorderSide(
          color: azul,
          width: 2,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
                14),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
                14),
        borderSide:
            const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // SECCIÓN
  // ============================================================

  Widget seccion({
    required String titulo,
    required IconData icono,
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
                18),
        border:
            Border.all(
          color: borde,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color: azul
                      .withOpacity(
                          0.08),
                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),
                child:
                    Icon(
                  icono,
                  color: azul,
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                titulo,
                style:
                    const TextStyle(
                  color:
                      texto,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          fondo,

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            texto,
        elevation: 0,
        surfaceTintColor:
            Colors.white,
        title: Text(
          esEdicion
              ? 'Editar cliente'
              : 'Nuevo cliente',
          style:
              const TextStyle(
            color: texto,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child:
            Form(
          key: formKey,
          child:
              ListView(
            padding:
                const EdgeInsets
                    .fromLTRB(
              16,
              16,
              16,
              120,
            ),
            children: [
              // ==================================================
              // ENCABEZADO
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets
                        .all(22),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      azul,
                      azulOscuro,
                    ],
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                              22),
                ),
                child:
                    Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white
                            .withOpacity(
                                0.15),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    17),
                      ),
                      child:
                          Icon(
                        esEdicion
                            ? Icons
                                .edit_outlined
                            : Icons
                                .person_add_alt_1,
                        color:
                            Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            esEdicion
                                ? 'Editar cliente'
                                : 'Registrar cliente',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  21,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            esEdicion
                                ? 'Actualiza la información del cliente.'
                                : 'Ingresa la información del nuevo cliente.',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize:
                                  13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // IDENTIFICACIÓN
              // ==================================================

              seccion(
                titulo:
                    'Identificación',
                icono:
                    Icons
                        .badge_outlined,
                child:
                    Column(
                  children: [
                    DropdownButtonFormField<
                        String>(
                      value:
                          tipoIdentificacion,
                      decoration:
                          decoracionCampo(
                        label:
                            'Tipo de identificación',
                        icon:
                            Icons
                                .assignment_ind_outlined,
                      ),
                      items:
                          const [
                        DropdownMenuItem(
                          value:
                              'CEDULA',
                          child:
                              Text(
                            'Cédula',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'RUC',
                          child:
                              Text(
                            'RUC',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'CONSUMIDOR_FINAL',
                          child:
                              Text(
                            'Consumidor final',
                          ),
                        ),
                      ],
                      onChanged:
                          cambiarTipoIdentificacion,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextFormField(
                      controller:
                          identificacionController,
                      keyboardType:
                          TextInputType
                              .number,
                      readOnly:
                          tipoIdentificacion ==
                              'CONSUMIDOR_FINAL',
                      decoration:
                          decoracionCampo(
                        label:
                            'Identificación',
                        icon:
                            Icons
                                .numbers,
                        hint:
                            tipoIdentificacion ==
                                    'CEDULA'
                                ? '10 dígitos'
                                : tipoIdentificacion ==
                                        'RUC'
                                    ? '13 dígitos'
                                    : '9999999999999',
                      ),
                      validator:
                          validarIdentificacion,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // INFORMACIÓN PERSONAL
              // ==================================================

              seccion(
                titulo:
                    'Información del cliente',
                icono:
                    Icons
                        .person_outline,
                child:
                    TextFormField(
                  controller:
                      razonSocialController,
                  textCapitalization:
                      TextCapitalization
                          .words,
                  decoration:
                      decoracionCampo(
                    label:
                        'Razón social / Nombre',
                    icon:
                        Icons
                            .person_outline,
                    hint:
                        'Nombre completo o razón social',
                  ),
                  validator:
                      (value) {
                    final valor =
                        value?.trim() ??
                            '';

                    if (valor
                        .isEmpty) {
                      return 'Ingresa el nombre o razón social';
                    }

                    return null;
                  },
                ),
              ),

              // ==================================================
              // CONTACTO
              // ==================================================

              seccion(
                titulo:
                    'Información de contacto',
                icono:
                    Icons
                        .contact_phone_outlined,
                child:
                    Column(
                  children: [
                    TextFormField(
                      controller:
                          direccionController,
                      textCapitalization:
                          TextCapitalization
                              .sentences,
                      maxLines: 2,
                      decoration:
                          decoracionCampo(
                        label:
                            'Dirección',
                        icon:
                            Icons
                                .location_on_outlined,
                        hint:
                            'Dirección del cliente',
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextFormField(
                      controller:
                          telefonoController,
                      keyboardType:
                          TextInputType
                              .phone,
                      decoration:
                          decoracionCampo(
                        label:
                            'Teléfono',
                        icon:
                            Icons
                                .phone_outlined,
                        hint:
                            '10 dígitos',
                      ),
                      validator:
                          validarTelefono,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextFormField(
                      controller:
                          emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          decoracionCampo(
                        label:
                            'Correo electrónico',
                        icon:
                            Icons
                                .email_outlined,
                        hint:
                            'correo@ejemplo.com',
                      ),
                      validator:
                          validarEmail,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ESTADO
              // ==================================================

              seccion(
                titulo:
                    'Estado del cliente',
                icono:
                    Icons
                        .toggle_on_outlined,
                child:
                    Row(
                  children: [
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            activo
                                ? 'Cliente activo'
                                : 'Cliente inactivo',
                            style:
                                const TextStyle(
                              color:
                                  texto,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            activo
                                ? 'El cliente estará disponible para facturación.'
                                : 'El cliente no estará disponible para nuevas operaciones.',
                            style:
                                const TextStyle(
                              color:
                                  textoSecundario,
                              fontSize:
                                  13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value:
                          activo,
                      activeColor:
                          azul,
                      onChanged:
                          (valor) {
                        setState(
                          () {
                            activo =
                                valor;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BOTONES
      // ============================================================

      bottomNavigationBar:
          SafeArea(
        minimum:
            const EdgeInsets
                .fromLTRB(
          16,
          8,
          16,
          16,
        ),
        child:
            Row(
          children: [
            Expanded(
              child:
                  OutlinedButton(
                onPressed:
                    guardando
                        ? null
                        : () {
                            Navigator
                                .of(
                                    context)
                                .pop(
                                    false);
                          },
                style:
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      texto,
                  side:
                      const BorderSide(
                    color:
                        borde,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical:
                        15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                13),
                  ),
                ),
                child:
                    const Text(
                  'Cancelar',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              flex: 2,
              child:
                  ElevatedButton
                      .icon(
                onPressed:
                    guardando ||
                            !puedeGestionarClientes
                        ? null
                        : guardarCliente,
                icon: guardando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .save_outlined,
                      ),
                label:
                    Text(
                  guardando
                      ? 'Guardando...'
                      : esEdicion
                          ? 'Actualizar cliente'
                          : 'Guardar cliente',
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      azul.withOpacity(
                          0.55),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical:
                        15,
                  ),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}