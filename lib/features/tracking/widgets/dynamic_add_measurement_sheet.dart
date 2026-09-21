import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/body_calculations_service.dart';

class DynamicAddMeasurementSheet extends StatefulWidget {
  final TextEditingController weightController;
  final TextEditingController waistController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController notesController;
  final Future<void> Function() onSave;
  final double? existingHeight; // Altura existente del usuario
  final int? existingAge; // Edad calculada del perfil (si se conoce)
  final String initialGender;
  final Future<void> Function(double)? onSaveHeight; // Guarda la altura (se espera antes de guardar la medición)
  final Function(String)? onGenderChanged; // Reporta el género elegido al padre
  final Function(int)? onAgeChanged; // Reporta la edad escrita manualmente al padre
  final ValueChanged<bool>? onAutoCalcChanged; // Reporta el switch "Auto calcular"

  const DynamicAddMeasurementSheet({
    super.key,
    required this.weightController,
    required this.waistController,
    required this.chestController,
    required this.armController,
    required this.notesController,
    required this.onSave,
    this.existingHeight,
    this.existingAge,
    this.initialGender = 'male',
    this.onSaveHeight,
    this.onGenderChanged,
    this.onAgeChanged,
    this.onAutoCalcChanged,
  });

  @override
  State<DynamicAddMeasurementSheet> createState() => _DynamicAddMeasurementSheetState();
}

class _DynamicAddMeasurementSheetState extends State<DynamicAddMeasurementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  late String _selectedGender; // 'male' o 'female'
  bool _autoCalculate = true;
  bool _saving = false;

  // Resultados calculados
  double? _calculatedBodyFat;
  double? _calculatedMuscle;
  double? _calculatedBMI;
  String _bmiCategory = '';
  Color _bmiColor = AppColors.success;
  // Qué fórmula se usó para el último cálculo de grasa/músculo, para
  // mostrar el pie de nota correcto.
  String? _bodyFatMethod;

  @override
  void initState() {
    super.initState();

    _selectedGender = widget.initialGender;

    // Si ya existe altura, pre-llenar
    if (widget.existingHeight != null) {
      _heightController.text = widget.existingHeight!.toString();
    }

    if (widget.existingAge != null) {
      _ageController.text = widget.existingAge!.toString();
    }

    // Agregar listeners para cálculos automáticos
    widget.weightController.addListener(_calculateMetrics);
    widget.waistController.addListener(_calculateMetrics);
    _heightController.addListener(_calculateMetrics);
    _ageController.addListener(_calculateMetrics);
  }

  @override
  void dispose() {
    // These controllers are owned by the parent screen and outlive this
    // sheet — the listeners must come off or _calculateMetrics fires
    // setState() on a disposed State when the parent clears the fields
    // after a successful save.
    widget.weightController.removeListener(_calculateMetrics);
    widget.waistController.removeListener(_calculateMetrics);
    _heightController.removeListener(_calculateMetrics);
    _ageController.removeListener(_calculateMetrics);

    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateMetrics() {
    if (!mounted) return;
    if (!_autoCalculate) return;

    // Rangos de cordura: fuera de esto lo tratamos como "todavía no válido"
    // para no mostrar un IMC o una grasa disparatados mientras se teclea.
    double? sane(String s, double lo, double hi) {
      final n = double.tryParse(s.replaceAll(',', '.'));
      return (n != null && n >= lo && n <= hi) ? n : null;
    }

    final weight = sane(widget.weightController.text, 20, 400);
    final waist = sane(widget.waistController.text, 40, 200);
    final height = sane(_heightController.text, 120, 230);
    final age = int.tryParse(_ageController.text);

    // Report a manually-typed age back to the parent immediately — not
    // just at save time — so it's not lost if the user never touches
    // this field again before tapping "Guardar".
    if (widget.existingAge == null && age != null && age > 0) {
      widget.onAgeChanged?.call(age);
    }

    if (weight == null || height == null || height <= 0) {
      setState(() {
        _calculatedBodyFat = null;
        _calculatedMuscle = null;
        _calculatedBMI = null;
        _bodyFatMethod = null;
      });
      return;
    }

    setState(() {
      if (waist != null) {
        // Más preciso: usa la cintura real.
        _calculatedBodyFat = BodyCalculationsService.calculateBodyFat(
          waistCm: waist,
          heightCm: height,
          gender: _selectedGender,
        );
        _bodyFatMethod = 'cintura';
      } else if (age != null && age > 0) {
        // Sin cintura: estimar con peso, altura, edad y sexo.
        _calculatedBodyFat = BodyCalculationsService.calculateBodyFatFromBMI(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: _selectedGender,
        );
        _bodyFatMethod = 'imc';
      } else {
        _calculatedBodyFat = null;
        _bodyFatMethod = null;
      }

      if (_calculatedBodyFat != null) {
        _calculatedMuscle = BodyCalculationsService.calculateMusclePercentage(
          weightKg: weight,
          bodyFatPercentage: _calculatedBodyFat!,
        );
      } else {
        _calculatedMuscle = null;
      }

      // El IMC solo necesita peso y altura, siempre se puede calcular.
      _calculatedBMI = BodyCalculationsService.calculateBMI(
        weightKg: weight,
        heightCm: height,
      );
      _bmiCategory = BodyCalculationsService.getBMICategory(_calculatedBMI!);
      _bmiColor = BodyCalculationsService.getBMIColor(_calculatedBMI!);
    });
  }
  
  Future<void> _save() async {
    if (_saving) return; // Evita doble envío si tocan el botón dos veces.

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      // Si hay altura nueva y no existía antes, guardarla PRIMERO y esperar:
      // así el padre ya tiene _userHeight cuando corre onSave() y la primera
      // medición sí calcula grasa/músculo/IMC.
      if (widget.existingHeight == null && _heightController.text.isNotEmpty) {
        final newHeight = double.tryParse(_heightController.text);
        if (newHeight != null && newHeight > 0 && widget.onSaveHeight != null) {
          await widget.onSaveHeight!(newHeight);
        }
      }

      // Si hay edad nueva y no existía antes, reportarla también.
      if (widget.existingAge == null && _ageController.text.isNotEmpty) {
        final newAge = int.tryParse(_ageController.text);
        if (newAge != null && newAge > 0) {
          widget.onAgeChanged?.call(newAge);
        }
      }

      await widget.onSave();
    } finally {
      // onSave normally pops this sheet on success, so `mounted` guards
      // against setState after that (or after an error) disposes it.
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.hairline)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nueva medición', style: AppTextStyles.titleLg),
                      Row(
                        children: [
                          Text('Auto calcular', style: AppTextStyles.label),
                          Switch(
                            value: _autoCalculate,
                            onChanged: (value) {
                              setState(() {
                                _autoCalculate = value;
                                if (value) _calculateMetrics();
                              });
                              widget.onAutoCalcChanged?.call(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Formulario
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Género
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Información Personal',
                                  style: AppTextStyles.titleMd,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGenderOption('male', 'Hombre', Icons.male),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildGenderOption('female', 'Mujer', Icons.female),
                                    ),
                                  ],
                                ),
                                if (_autoCalculate && _selectedGender.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'El género se usa para cálculos más precisos',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Medidas básicas
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _buildTextField(
                                  'Peso (kg)',
                                  widget.weightController,
                                  Icons.monitor_weight,
                                  true,
                                  'Ej: 75.5',
                                  min: 30,
                                  max: 300,
                                ),
                                const SizedBox(height: 12),
                                if (widget.existingHeight == null)
                                  _buildTextField(
                                    'Altura (cm)',
                                    _heightController,
                                    Icons.height,
                                    true,
                                    'Ej: 175',
                                    min: 120,
                                    max: 230,
                                  ),
                                if (widget.existingHeight == null)
                                  const SizedBox(height: 12),
                                if (widget.existingAge == null)
                                  _buildTextField(
                                    'Edad',
                                    _ageController,
                                    Icons.cake,
                                    false,
                                    'Opcional — para estimar sin cintura',
                                    min: 10,
                                    max: 100,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Medidas opcionales — si no se llenan, la grasa
                        // corporal se estima solo con peso, altura, edad
                        // y sexo en vez de la cintura.
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Medidas opcionales',
                                  style: AppTextStyles.titleMd,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '¿No te quieres medir con cinta? Déjalas vacías — '
                                  'igual calculamos tu grasa corporal con peso, altura, edad y sexo.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Circunferencia de Cintura (cm)',
                                  widget.waistController,
                                  Icons.straighten,
                                  false,
                                  'Opcional — medir a la altura del ombligo',
                                  min: 40,
                                  max: 200,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Pecho (cm)',
                                  widget.chestController,
                                  Icons.fitness_center,
                                  false,
                                  'Opcional — medir a la altura del pecho',
                                  min: 40,
                                  max: 200,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Brazo (cm)',
                                  widget.armController,
                                  Icons.accessibility,
                                  false,
                                  'Opcional — medir el bíceps flexionado',
                                  min: 10,
                                  max: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Resultados
                        if (_autoCalculate && _calculatedBodyFat != null && _calculatedMuscle != null) ...[
                          Card(
                            elevation: 2,
                            color: AppColors.accentSoft,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Resultados Calculados',
                                    style: AppTextStyles.titleMd,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildResultCard(
                                          'Grasa Corporal',
                                          '${_calculatedBodyFat!.toStringAsFixed(1)}%',
                                          Icons.local_fire_department,
                                          _getBodyFatColor(),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildResultCard(
                                          'Masa Muscular',
                                          '${_calculatedMuscle!.toStringAsFixed(1)}%',
                                          Icons.fitness_center,
                                          AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_calculatedBMI != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _bmiColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _bmiColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'IMC: ${_calculatedBMI!.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _bmiColor,
                                                ),
                                              ),
                                              Text(
                                                _bmiCategory,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _bmiColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(Icons.monitor_heart, color: _bmiColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    _bodyFatMethod == 'cintura'
                                        ? '* Basado en peso, altura y cintura'
                                        : '* Estimado con peso, altura, edad y sexo (sin cintura) — agrégala para mayor precisión',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Notas
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextFormField(
                              controller: widget.notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Notas (opcional)',
                                hintText: 'Ej: Progreso, cambios en rutina, etc.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _saving ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _saving ? null : _save,
                                child: _saving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onAccent,
                                        ),
                                      )
                                    : const Text('Guardar medición'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
          _calculateMetrics();
        });
        widget.onGenderChanged?.call(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSoft : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.hairline,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.accent : AppColors.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color:
                    isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool required,
    String hint, {
    // Antes era un solo tope de cordura (500) igual para peso, altura,
    // cintura, pecho y brazo — un valor tecnicamente "menor a 500" pero sin
    // sentido para ese campo (ej. altura en metros: "1.75") pasaba la
    // validacion sin aviso y producia un IMC/grasa corporal disparatado
    // (BodyCalculationsService.calculateBMI no acota el resultado). Ahora
    // cada campo tiene su propio rango realista.
    double min = 0.01,
    double max = 500,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Este campo es requerido';
        }
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value.replaceAll(',', '.'));
          if (number == null) {
            return 'Ingrese un valor válido';
          }
          if (number < min || number > max) {
            return 'Debe estar entre ${min.toInt()} y ${max.toInt()}';
          }
        }
        return null;
      },
    );
  }
  
  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.statSm.copyWith(color: color),
          ),
          Text(title, style: AppTextStyles.label),
        ],
      ),
    );
  }
  
  Color _getBodyFatColor() {
    if (_calculatedBodyFat == null) return Colors.orange;
    if (_selectedGender == 'male') {
      if (_calculatedBodyFat! < 10) return Colors.blue;
      if (_calculatedBodyFat! < 20) return Colors.green;
      if (_calculatedBodyFat! < 25) return Colors.orange;
      return Colors.red;
    } else {
      if (_calculatedBodyFat! < 18) return Colors.blue;
      if (_calculatedBodyFat! < 28) return Colors.green;
      if (_calculatedBodyFat! < 32) return Colors.orange;
      return Colors.red;
    }
  }
}