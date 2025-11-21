class Usuario {
  final String id;
  final String usuario;
  final String tipoUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;

  Usuario({
    required this.id,
    required this.usuario,
    required this.tipoUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    this.apellidoMaterno,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      usuario: map['usuario'],
      tipoUsuario: map['tipo_usuario'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'tipo_usuario': tipoUsuario,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
    };
  }
}
