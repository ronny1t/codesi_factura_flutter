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
      idCategoria: json['id_categoria'],
      nombre: json['nombre'],
      activo: json['activo'] ?? true,
    );
  }
}