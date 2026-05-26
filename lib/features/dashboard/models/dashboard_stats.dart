class DashboardStats {
  final double weight;
  final double? bodyFat;  // Cambiado a opcional
  final double? muscle;   // Cambiado a opcional

  DashboardStats({
    required this.weight,
    this.bodyFat,
    this.muscle,
  });
}