class Cliente {
  final int idCliente;
  final String tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
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
      idCliente: json['id_cliente'] ?? 0,
      tipoIdentificacion:
          json['tipo_identificacion'] ?? '',
      identificacion:
          json['identificacion'] ?? '',
      razonSocial:
          json['razon_social'] ?? '',
      direccion:
          json['direccion'],
      telefono:
          json['telefono'],
      email:
          json['email'],
      activo:
          json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'tipo_identificacion':
          tipoIdentificacion,
      'identificacion':
          identificacion,
      'razon_social':
          razonSocial,
      'direccion':
          direccion,
      'telefono':
          telefono,
      'email':
          email,
      'activo':
          activo,
    };
  }
}