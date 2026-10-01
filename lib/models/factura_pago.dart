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
      idPago: (json['idPago'] as num?)?.toInt(),

      idFactura:
          (json['idFactura'] as num?)?.toInt() ?? 0,

      formaPago:
          json['formaPago']?.toString() ?? '',

      total:
          (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}