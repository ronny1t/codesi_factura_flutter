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
      idDetalle: (json['idDetalle'] as num?)?.toInt(),

      idFactura:
          (json['idFactura'] as num?)?.toInt() ?? 0,

      idProducto:
          (json['idProducto'] as num?)?.toInt() ?? 0,

      cantidad:
          (json['cantidad'] as num?)?.toInt() ?? 0,

      precioUnitario:
          (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,

      descuento:
          (json['descuento'] as num?)?.toDouble() ?? 0.0,

      subtotal:
          (json['subtotal'] as num?)?.toDouble() ?? 0.0,

      valorIva:
          (json['valorIva'] as num?)?.toDouble() ?? 0.0,

      total:
          (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}