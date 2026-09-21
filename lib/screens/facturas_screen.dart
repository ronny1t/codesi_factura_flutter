import 'package:flutter/material.dart';
import '../models/factura.dart';
import '../services/factura_service.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  late Future<List<Factura>> facturas;

  @override
  void initState() {
    super.initState();
    cargarFacturas();
  }

  void cargarFacturas() {
    facturas = FacturaService.obtenerFacturas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
      ),
      body: FutureBuilder<List<Factura>>(
        future: facturas,
        builder: (context, snapshot) {
          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Sin facturas
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No existen facturas registradas',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Lista de facturas
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                cargarFacturas();
              });

              await facturas;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final factura = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long),
                    ),

                    title: Text(
                      'Factura #${factura.idFactura ?? ''}',
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente: ${factura.idCliente}',
                        ),
                        Text(
                          'Fecha: ${factura.fechaEmision}',
                        ),
                        Text(
                          'Estado: ${factura.estadoSri}',
                        ),
                      ],
                    ),

                    trailing: Text(
                      '\$${factura.importeTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}