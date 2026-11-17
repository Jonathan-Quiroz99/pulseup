enum AppScreen {
  dashboard,
  routines,
  tracking,
  nutrition,
  store,
  checkin,
  billing;

  /// Secciones incluidas en la membresía: con la solicitud Pendiente (o
  /// vencida) se ven bloqueadas hasta que el pago aparezca como pagado. El
  /// backend también las rechaza (403), esto solo evita pantallas de error.
  bool get requiresActivePlan =>
      this == routines || this == tracking || this == nutrition;
}