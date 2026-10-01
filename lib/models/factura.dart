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
    idFactura: json['idFactura'],
    establecimiento: json['establecimiento']?.toString() ?? '',
    puntoEmision: json['puntoEmision']?.toString() ?? '',
    secuencial: json['secuencial']?.toString() ?? '',
    claveAcceso: json['claveAcceso']?.toString() ?? '',
    fechaEmision: DateTime.parse(
      json['fechaEmision'].toString(),
    ),
    idCliente: json['idCliente'] ?? 0,
    subtotalSinImpuestos:
        (json['subtotalSinImpuestos'] ?? 0).toDouble(),
    totalDescuento:
        (json['totalDescuento'] ?? 0).toDouble(),
    subtotalIva:
        (json['subtotalIva'] ?? 0).toDouble(),
    propina:
        (json['propina'] ?? 0).toDouble(),
    importeTotal:
        (json['importeTotal'] ?? 0).toDouble(),
    estadoSri:
        json['estadoSri']?.toString() ?? '',
  );
}
}