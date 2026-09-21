class Factura {
  int? idFactura;
  String establecimiento;
  String puntoEmision;
  String secuencial;
  String claveAcceso;
  DateTime fechaEmision;
  int idCliente;
  double subtotalSinImpuestos;
  double totalDescuento;
  double subtotalIva;
  double propina;
  double importeTotal;
  String estadoSri;

  Factura({
    this.idFactura,
    required this.establecimiento,
    required this.puntoEmision,
    required this.secuencial,
    required this.claveAcceso,
    required this.fechaEmision,
    required this.idCliente,
    required this.subtotalSinImpuestos,
    required this.totalDescuento,
    required this.subtotalIva,
    required this.propina,
    required this.importeTotal,
    required this.estadoSri,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_factura': idFactura,
      'establecimiento': establecimiento,
      'punto_emision': puntoEmision,
      'secuencial': secuencial,
      'clave_acceso': claveAcceso,
      'fecha_emision': fechaEmision.toIso8601String(),
      'id_cliente': idCliente,
      'subtotal_sin_impuestos': subtotalSinImpuestos,
      'total_descuento': totalDescuento,
      'subtotal_iva': subtotalIva,
      'propina': propina,
      'importe_total': importeTotal,
      'estado_sri': estadoSri,
    };
  }

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      idFactura: json['id_factura'],
      establecimiento: json['establecimiento'] ?? '',
      puntoEmision: json['punto_emision'] ?? '',
      secuencial: json['secuencial'] ?? '',
      claveAcceso: json['clave_acceso'] ?? '',
      fechaEmision: DateTime.parse(json['fecha_emision']),
      idCliente: json['id_cliente'],
      subtotalSinImpuestos:
          (json['subtotal_sin_impuestos'] ?? 0).toDouble(),
      totalDescuento:
          (json['total_descuento'] ?? 0).toDouble(),
      subtotalIva:
          (json['subtotal_iva'] ?? 0).toDouble(),
      propina:
          (json['propina'] ?? 0).toDouble(),
      importeTotal:
          (json['importe_total'] ?? 0).toDouble(),
      estadoSri: json['estado_sri'] ?? '',
    );
  }
}