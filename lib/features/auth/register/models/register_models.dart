class RegisterData {

  String nombre;
  String apellidos;
  String correo;
  String telefono;
  String fechaNacimiento;

  String? password;

  bool isGoogle;

  String? googleCredential;

  RegisterData({
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fechaNacimiento,
    this.password,
    required this.isGoogle,
    this.googleCredential,
  });
}