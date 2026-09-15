class Cliente {
  final int idCliente;
  final String tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String email;

  Cliente({
    required this.idCliente,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    required this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      tipoIdentificacion: json['tipo_identificacion'],
      identificacion: json['identificacion'],
      razonSocial: json['razon_social'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }
}