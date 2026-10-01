class Categoria {
  final int idCategoria;
  final String nombre;
  final bool activo;

  Categoria({
    required this.idCategoria,
    required this.nombre,
    required this.activo,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria:
          (json['idCategoria'] as num?)?.toInt() ?? 0,
      nombre:
          json['nombre']?.toString() ?? '',
      activo:
          json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Nombre': nombre,
      'Activo': activo,
    };
  }
}