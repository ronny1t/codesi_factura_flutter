class Producto {
  final int idProducto;
  final String? codigoPrincipal;
  final String nombre;
  final double precioUnitario;
  final int stock;
  final double tarifaIva;
  final int? idCategoria;
  final bool activo;

  Producto({
    required this.idProducto,
    this.codigoPrincipal,
    required this.nombre,
    required this.precioUnitario,
    required this.stock,
    required this.tarifaIva,
    this.idCategoria,
    required this.activo,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: (json['idProducto'] as num?)?.toInt() ?? 0,

      codigoPrincipal:
          json['codigoPrincipal']?.toString(),

      nombre:
          json['nombre']?.toString() ?? '',

      precioUnitario:
          (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,

      stock:
          (json['stock'] as num?)?.toInt() ?? 0,

      tarifaIva:
          (json['tarifaIva'] as num?)?.toDouble() ?? 0.0,

      idCategoria:
          (json['idCategoria'] as num?)?.toInt(),

      activo:
          json['activo'] as bool? ?? true,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'CodigoPrincipal': codigoPrincipal,
      'Nombre': nombre,
      'PrecioUnitario': precioUnitario,
      'Stock': stock,
      'TarifaIva': tarifaIva,
      'IdCategoria': idCategoria,
      'Activo': activo,
    };
  }
}