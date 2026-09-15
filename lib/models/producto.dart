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

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'],
      codigoPrincipal: json['codigo_principal'],
      nombre: json['nombre'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      stock: json['stock'],
      tarifaIva: (json['tarifa_iva'] as num).toDouble(),
      idCategoria: json['id_categoria'],
      activo: json['activo'] ?? true,
    );
  }
}