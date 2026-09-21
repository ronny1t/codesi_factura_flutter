class FacturaDetalle {
  int? idDetalle;
  int idFactura;
  int idProducto;
  int cantidad;
  double precioUnitario;
  double descuento;
  double subtotal;
  double valorIva;
  double total;

  FacturaDetalle({
    this.idDetalle,
    required this.idFactura,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    required this.valorIva,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_detalle': idDetalle,
      'id_factura': idFactura,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento': descuento,
      'subtotal': subtotal,
      'valor_iva': valorIva,
      'total': total,
    };
  }

  factory FacturaDetalle.fromJson(Map<String, dynamic> json) {
    return FacturaDetalle(
      idDetalle: json['id_detalle'],
      idFactura: json['id_factura'],
      idProducto: json['id_producto'],
      cantidad: json['cantidad'],
      precioUnitario:
          (json['precio_unitario'] ?? 0).toDouble(),
      descuento:
          (json['descuento'] ?? 0).toDouble(),
      subtotal:
          (json['subtotal'] ?? 0).toDouble(),
      valorIva:
          (json['valor_iva'] ?? 0).toDouble(),
      total:
          (json['total'] ?? 0).toDouble(),
    );
  }
}