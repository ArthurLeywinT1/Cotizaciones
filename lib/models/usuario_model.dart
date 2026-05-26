class Usuario {
  final String id;
  final String usuario;
  final String correo;
  final String tipoUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;

  Usuario({
    required this.id,
    required this.usuario,
    required this.correo,
    required this.tipoUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    this.apellidoMaterno,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'].toString(),
      usuario: map['usuario'].toString(),
      correo: map['correo'].toString(),
      tipoUsuario: map['tipo_usuario'].toString(),
      nombre: map['nombre'].toString(),
      apellidoPaterno: map['apellido_paterno'].toString(),
      apellidoMaterno: map['apellido_materno']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'correo': correo,
      'tipo_usuario': tipoUsuario,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
    };
  }
}
