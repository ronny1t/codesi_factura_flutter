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
          content: Text(
            'Error al cargar clientes: $e',
          ),
          backgroundColor: Colors.red,
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
              title: const Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 10),
                  Text('Nuevo cliente'),
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
                        // TIPO DE IDENTIFICACIÓN
                        // =================================================

                        DropdownButtonFormField<String>(
                          value:
                              tipoIdentificacion,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Tipo de identificación',
                            prefixIcon:
                                Icon(
                              Icons.badge,
                            ),
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

                        const SizedBox(
                          height: 15,
                        ),

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

                        const SizedBox(
                          height: 15,
                        ),

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

                        const SizedBox(
                          height: 15,
                        ),

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

                        const SizedBox(
                          height: 15,
                        ),

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

                        const SizedBox(
                          height: 15,
                        ),

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

                            if (!value
                                .contains('@')) {
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

                            if (!mounted) {
                              return;
                            }

                            // ============================================
                            // CERRAR FORMULARIO
                            // ============================================

                            Navigator.pop(
                              dialogContext,
                            );

                            // ============================================
                            // RECARGAR LISTA
                            // ============================================

                            await cargarClientes();

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cliente registrado correctamente',
                                ),
                                backgroundColor:
                                    Colors.green,
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.person,
          ),
        ),

        title: Text(
          cliente.razonSocial,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(
              height: 5,
            ),

            Text(
              '${cliente.tipoIdentificacion}: '
              '${cliente.identificacion}',
            ),

            if (cliente.email != null &&
                cliente.email!.isNotEmpty)
              Text(
                'Email: ${cliente.email}',
              ),

            if (cliente.telefono != null &&
                cliente.telefono!.isNotEmpty)
              Text(
                'Teléfono: ${cliente.telefono}',
              ),

            if (cliente.direccion != null &&
                cliente.direccion!.isNotEmpty)
              Text(
                'Dirección: ${cliente.direccion}',
              ),
          ],
        ),

        isThreeLine: true,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
        ),

        actions: [
          IconButton(
            tooltip: 'Actualizar',

            onPressed:
                cargarClientes,

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
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 70,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        'No hay clientes disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      ElevatedButton.icon(
                        onPressed:
                            mostrarFormularioCliente,

                        icon: const Icon(
                          Icons.person_add,
                        ),

                        label: const Text(
                          'Registrar cliente',
                        ),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh:
                      cargarClientes,

                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      top: 8,
                      bottom: 90,
                    ),

                    itemCount:
                        clientes.length,

                    itemBuilder:
                        (context, index) {
                      final cliente =
                          clientes[index];

                      return construirCliente(
                        cliente,
                      );
                    },
                  ),
                ),

      // ==========================================================
      // BOTÓN NUEVO CLIENTE
      // ==========================================================

      floatingActionButton:
          FloatingActionButton.extended(
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