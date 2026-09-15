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

  Future<void> cargarClientes() async {
    try {
      final resultado =
          await ClienteService.obtenerClientes();

      setState(() {
        clientes = resultado;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : clientes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay clientes disponibles',
                  ),
                )
              : ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),

                        title: Text(
                          cliente.razonSocial,
                        ),

                        subtitle: Text(
                          '${cliente.tipoIdentificacion}: '
                          '${cliente.identificacion}\n'
                          'Email: ${cliente.email}',
                        ),

                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}