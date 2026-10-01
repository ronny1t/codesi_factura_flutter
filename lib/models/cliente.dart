class Cliente {
  final int idCliente;
  final String tipoIdentificacion;
  final String identificacion;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String razonSocial;
  final bool activo;

  Cliente({
    required this.idCliente,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    required this.activo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: (json['idCliente'] as num?)?.toInt() ?? 0,
      tipoIdentificacion:
          json['tipoIdentificacion']?.toString() ?? '',
      identificacion:
          json['identificacion']?.toString() ?? '',
      razonSocial:
          json['razonSocial']?.toString() ?? '',
      direccion:
          json['direccion']?.toString(),
      telefono:
          json['telefono']?.toString(),
      email:
          json['email']?.toString(),
      activo:
          json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TipoIdentificacion': tipoIdentificacion,
      'Identificacion': identificacion,
      'RazonSocial': razonSocial,
      'Direccion': direccion,
      'Telefono': telefono,
      'Email': email,
      'Activo': activo,
    };
  }
}