import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() =>
      _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> clientes = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  // ============================================================
  // CARGAR CLIENTES
  // ============================================================

  Future<void> cargarClientes() async {
    try {
      setState(() {
        cargando = true;
      });

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No se pudieron cargar los clientes',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // FORMULARIO NUEVO CLIENTE
  // ============================================================

  void mostrarFormularioCliente() {
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

    String tipoIdentificacion = 'CEDULA';

    bool guardando = false;

    final formKey =
        GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Color(0xFF1565C0),
                  ),

                  SizedBox(width: 10),

                  Text(
                    'Nuevo cliente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              content: SizedBox(
                width: 450,

                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        // =================================================
                        // TIPO IDENTIFICACIÓN
                        // =================================================

                        DropdownButtonFormField<String>(
                          value: tipoIdentificacion,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Tipo de identificación',
                            prefixIcon:
                                Icon(Icons.badge),
                            border:
                                OutlineInputBorder(),
                          ),

                          items: const [
                            DropdownMenuItem(
                              value: 'CEDULA',
                              child:
                                  Text('Cédula'),
                            ),

                            DropdownMenuItem(
                              value: 'RUC',
                              child:
                                  Text('RUC'),
                            ),

                            DropdownMenuItem(
                              value: 'PASAPORTE',
                              child:
                                  Text('Pasaporte'),
                            ),
                          ],

                          onChanged:
                              guardando
                                  ? null
                                  : (value) {
                                      if (value ==
                                          null) {
                                        return;
                                      }

                                      setDialogState(() {
                                        tipoIdentificacion =
                                            value;
                                      });
                                    },
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // IDENTIFICACIÓN
                        // =================================================

                        TextFormField(
                          controller:
                              identificacionController,

                          keyboardType:
                              TextInputType.number,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Identificación',
                            hintText:
                                'Ej: 0102030405',
                            prefixIcon:
                                Icon(
                              Icons.credit_card,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese la identificación';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // RAZÓN SOCIAL
                        // =================================================

                        TextFormField(
                          controller:
                              razonSocialController,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Razón social / Nombre',
                            hintText:
                                'Ej: Juan Pérez',
                            prefixIcon:
                                Icon(
                              Icons.person,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingrese el nombre';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // DIRECCIÓN
                        // =================================================

                        TextFormField(
                          controller:
                              direccionController,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Dirección',
                            hintText:
                                'Ej: Av. Principal 123',
                            prefixIcon:
                                Icon(
                              Icons.location_on,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // TELÉFONO
                        // =================================================

                        TextFormField(
                          controller:
                              telefonoController,

                          keyboardType:
                              TextInputType.phone,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Teléfono',
                            hintText:
                                'Ej: 0991234567',
                            prefixIcon:
                                Icon(
                              Icons.phone,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // EMAIL
                        // =================================================

                        TextFormField(
                          controller:
                              emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          textInputAction:
                              TextInputAction.done,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Correo electrónico',
                            hintText:
                                'Ej: cliente@gmail.com',
                            prefixIcon:
                                Icon(
                              Icons.email,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return null;
                            }

                            if (!value.contains('@')) {
                              return 'Ingrese un correo válido';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // BOTONES
              // ==========================================================

              actions: [

                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },

                  child: const Text(
                    'Cancelar',
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          // ==============================================
                          // VALIDAR
                          // ==============================================

                          if (!formKey
                              .currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                          });

                          try {
                            // ============================================
                            // CREAR CLIENTE
                            // ============================================

                            final cliente =
                                Cliente(
                              idCliente: 0,

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

                              activo: true,
                            );

                            // ============================================
                            // ENVIAR AL BACKEND
                            // ============================================

                            await ClienteService
                                .crearCliente(
                              cliente,
                            );

                            if (!mounted) return;

                            // ============================================
                            // CERRAR
                            // ============================================

                            Navigator.pop(
                              dialogContext,
                            );

                            // ============================================
                            // RECARGAR
                            // ============================================

                            await cargarClientes();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cliente registrado correctamente',
                                ),
                                backgroundColor:
                                    Colors.green,
                                behavior:
                                    SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              guardando = false;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al registrar cliente: $e',
                                ),
                                backgroundColor:
                                    Colors.red,
                              ),
                            );
                          }
                        },

                  icon: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),

                  label: Text(
                    guardando
                        ? 'Guardando...'
                        : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TARJETA DEL CLIENTE
  // ============================================================

  Widget construirCliente(
    Cliente cliente,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==========================================================
            // CABECERA CLIENTE
            // ==========================================================

            Row(
              children: [

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B)
                        .withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF00897B),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        cliente.razonSocial,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${cliente.tipoIdentificacion}: '
                        '${cliente.identificacion}',

                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // EMAIL
            // ==========================================================

            if (cliente.email != null &&
                cliente.email!.isNotEmpty)
              _DatoCliente(
                icono: Icons.email_outlined,
                texto: cliente.email!,
              ),

            // ==========================================================
            // TELÉFONO
            // ==========================================================

            if (cliente.telefono != null &&
                cliente.telefono!.isNotEmpty)
              _DatoCliente(
                icono: Icons.phone_outlined,
                texto: cliente.telefono!,
              ),

            // ==========================================================
            // DIRECCIÓN
            // ==========================================================

            if (cliente.direccion != null &&
                cliente.direccion!.isNotEmpty)
              _DatoCliente(
                icono:
                    Icons.location_on_outlined,
                texto: cliente.direccion!,
              ),
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
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
            const Color(0xFF1565C0),

        foregroundColor: Colors.white,

        title: const Text(
          'Clientes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargarClientes,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: cargando

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : clientes.isEmpty

              ? _EstadoVacio(
                  onNuevoCliente:
                      mostrarFormularioCliente,
                )

              : RefreshIndicator(
                  onRefresh:
                      cargarClientes,

                  child: ListView(
                    padding:
                        const EdgeInsets.all(20),

                    children: [

                      // ==================================================
                      // ENCABEZADO
                      // ==================================================

                      Container(
                        padding:
                            const EdgeInsets.all(20),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF1565C0,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Row(
                          children: [

                            Container(
                              width: 55,
                              height: 55,

                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                  0.15,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),

                              child: const Icon(
                                Icons.people,
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
                                    'Clientes registrados',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
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
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      const Text(
                        'Lista de clientes',

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ...clientes.map(
                        construirCliente,
                      ),
                    ],
                  ),
                ),

      // ==========================================================
      // NUEVO CLIENTE
      // ==========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFF1565C0),

        foregroundColor: Colors.white,

        onPressed:
            mostrarFormularioCliente,

        icon: const Icon(
          Icons.person_add,
        ),

        label: const Text(
          'Nuevo cliente',
        ),
      ),
    );
  }
}


// ============================================================
// DATO DEL CLIENTE
// ============================================================

class _DatoCliente extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _DatoCliente({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icono,
            size: 18,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF546E7A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// ESTADO VACÍO
// ============================================================

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onNuevoCliente;

  const _EstadoVacio({
    required this.onNuevoCliente,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: [

        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.22,
        ),

        const Icon(
          Icons.people_outline,
          size: 75,
          color: Colors.grey,
        ),

        const SizedBox(height: 20),

        const Center(
          child: Text(
            'No hay clientes disponibles',

            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF263238),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal: 40,
          ),

          child: Text(
            'Los clientes registrados aparecerán aquí.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton.icon(
            onPressed:
                onNuevoCliente,

            icon: const Icon(
              Icons.person_add,
            ),

            label: const Text(
              'Registrar cliente',
            ),
          ),
        ),
      ],
    );
  }
}