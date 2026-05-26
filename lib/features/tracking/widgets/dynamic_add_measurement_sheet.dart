import 'package:flutter/material.dart';
import '../services/body_calculations_service.dart';

class DynamicAddMeasurementSheet extends StatefulWidget {
  final TextEditingController weightController;
  final TextEditingController waistController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController notesController;
  final VoidCallback onSave;
  final double? existingHeight; // Altura existente del usuario
  final Function(double)? onSaveHeight; // Callback para guardar altura si se ingresa

  const DynamicAddMeasurementSheet({
    super.key,
    required this.weightController,
    required this.waistController,
    required this.chestController,
    required this.armController,
    required this.notesController,
    required this.onSave,
    this.existingHeight,
    this.onSaveHeight,
  });

  @override
  State<DynamicAddMeasurementSheet> createState() => _DynamicAddMeasurementSheetState();
}

class _DynamicAddMeasurementSheetState extends State<DynamicAddMeasurementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  String _selectedGender = 'male'; // 'male' o 'female'
  bool _autoCalculate = true;
  
  // Resultados calculados
  double? _calculatedBodyFat;
  double? _calculatedMuscle;
  double? _calculatedBMI;
  String _bmiCategory = '';
  Color _bmiColor = Colors.green;
  
  @override
  void initState() {
    super.initState();
    
    // Si ya existe altura, pre-llenar
    if (widget.existingHeight != null) {
      _heightController.text = widget.existingHeight!.toString();
    }
    
    // Agregar listeners para cálculos automáticos
    widget.weightController.addListener(_calculateMetrics);
    widget.waistController.addListener(_calculateMetrics);
    _heightController.addListener(_calculateMetrics);
  }
  
  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }
  
  void _calculateMetrics() {
    if (!_autoCalculate) return;
    
    final weight = double.tryParse(widget.weightController.text);
    final waist = double.tryParse(widget.waistController.text);
    final height = double.tryParse(_heightController.text);
    
    if (weight != null && waist != null && height != null && height > 0) {
      setState(() {
        // Calcular grasa corporal
        _calculatedBodyFat = BodyCalculationsService.calculateBodyFat(
          weightKg: weight,
          waistCm: waist,
          heightCm: height,
          gender: _selectedGender,
        );
        
        // Calcular masa muscular
        if (_calculatedBodyFat != null) {
          _calculatedMuscle = BodyCalculationsService.calculateMusclePercentage(
            weightKg: weight,
            bodyFatPercentage: _calculatedBodyFat!,
          );
        }
        
        // Calcular IMC
        _calculatedBMI = BodyCalculationsService.calculateBMI(
          weightKg: weight,
          heightCm: height,
        );
        
        if (_calculatedBMI != null) {
          _bmiCategory = BodyCalculationsService.getBMICategory(_calculatedBMI!);
          _bmiColor = BodyCalculationsService.getBMIColor(_calculatedBMI!);
        }
      });
    } else {
      setState(() {
        _calculatedBodyFat = null;
        _calculatedMuscle = null;
        _calculatedBMI = null;
      });
    }
  }
  
  void _save() {
    if (_formKey.currentState!.validate()) {
      // Si hay altura nueva y no existía antes, guardarla
      if (widget.existingHeight == null && _heightController.text.isNotEmpty) {
        final newHeight = double.parse(_heightController.text);
        if (widget.onSaveHeight != null) {
          widget.onSaveHeight!(newHeight);
        }
      }
      widget.onSave();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nueva Medición',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Text('Auto calcular', style: TextStyle(fontSize: 12)),
                          Switch(
                            value: _autoCalculate,
                            onChanged: (value) {
                              setState(() {
                                _autoCalculate = value;
                                if (value) _calculateMetrics();
                              });
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
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Circunferencia de Cintura (cm)',
                                  widget.waistController,
                                  Icons.straighten,
                                  true,
                                  'Medir a la altura del ombligo',
                                ),
                                const SizedBox(height: 12),
                                if (widget.existingHeight == null)
                                  _buildTextField(
                                    'Altura (cm)',
                                    _heightController,
                                    Icons.height,
                                    true,
                                    'Ej: 175',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Medidas adicionales
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _buildTextField(
                                  'Pecho (cm)',
                                  widget.chestController,
                                  Icons.fitness_center,
                                  true,
                                  'Medir a la altura del pecho',
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Brazo (cm)',
                                  widget.armController,
                                  Icons.accessibility,
                                  true,
                                  'Medir el bíceps flexionado',
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
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Resultados Calculados',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                          Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_calculatedBMI != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _bmiColor.withOpacity(0.1),
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
                                    '* Basado en peso, altura y cintura',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Guardar Medición',
                                  style: TextStyle(fontSize: 16),
                                ),
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
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
    String hint,
  ) {
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
          final number = double.tryParse(value);
          if (number == null || number <= 0) {
            return 'Ingrese un valor válido';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
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