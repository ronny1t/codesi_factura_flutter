class FacturaPago {
  int? idPago;
  int idFactura;
  String formaPago;
  double total;

  FacturaPago({
    this.idPago,
    required this.idFactura,
    required this.formaPago,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_pago': idPago,
      'id_factura': idFactura,
      'forma_pago': formaPago,
      'total': total,
    };
  }

  factory FacturaPago.fromJson(Map<String, dynamic> json) {
    return FacturaPago(
      idPago: json['id_pago'],
      idFactura: json['id_factura'],
      formaPago: json['forma_pago'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}