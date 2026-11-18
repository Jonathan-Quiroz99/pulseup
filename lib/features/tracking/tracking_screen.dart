import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/section_header.dart';
import '../../core/http_helpers.dart';
import '../../widgets/ui/app_button.dart';
import '../auth/user_session.dart';
import '../nutrition/services/nutrition_service.dart';
import '../onboarding/section_guide.dart';
import 'models/body_composition.dart';
import 'models/body_measurement.dart';
import 'models/progress_photo.dart';
import 'services/tracking_service.dart';
import 'services/body_calculations_service.dart';
import 'services/progress_insights.dart';
import 'widgets/body_composition_sheet.dart';
import 'widgets/dynamic_add_measurement_sheet.dart';
import 'widgets/goal_card.dart';
import 'widgets/measurement_picker_sheet.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/metric_line_chart.dart';
import 'widgets/progress_photos_card.dart';
import 'widgets/progress_summary_card.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  final ApiService _apiService = ApiService();
  bool _loading = false;
  List<BodyMeasurement> _measurements = [];
  double? _userHeight;
  int? _userAge;
  String _userGender = 'male';
  bool _autoCalc = true;
  double? _weightGoal;
  double? _goalStart; // peso con el que se definió la meta actual
  String _metricKey = 'peso';
  List<ProgressPhoto> _photos = [];
  bool _uploadingPhoto = false;
  final _picker = ImagePicker();

  // Para el mini tutorial de la sección (ver _guideSteps).
  final _goalKey = GlobalKey();
  final _chartKey = GlobalKey();
  final _photosKey = GlobalKey();
  final _fabKey = GlobalKey();
  final _startKey = GlobalKey();
  String? _guideShown; // id del tutorial ya revisado en esta pantalla
  // El "+" se esconde mientras el socio baja por la lista (tapaba fotos y
  // tarjetas) y regresa en cuanto sube.
  bool _fabVisible = true;

  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
    _loadUserData();
    _loadGoal();
    _loadPhotos();
    SectionGuide.attach(this, _replayGuide);
  }

  /// "?" de la barra: el tutorial señala el "+", así que primero se muestra
  /// (si estaba escondido por el scroll) y se espera a que termine de entrar.
  Future<void> _replayGuide() async {
    if (!_fabVisible) {
      setState(() => _fabVisible = true);
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }
    if (mounted) SectionGuide.show(context, _guideSteps());
  }

  /// Solo la lista principal (depth 0, vertical): los chips de la gráfica y
  /// la tira de fotos también hacen scroll y no deben mover el "+".
  bool _onScroll(ScrollUpdateNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final delta = n.scrollDelta ?? 0;
    bool? visible;
    if (n.metrics.pixels <= 0) {
      visible = true; // arriba de todo
    } else if (delta > 2) {
      visible = false; // bajando
    } else if (delta < -2) {
      visible = true; // subiendo
    }
    if (visible != null && visible != _fabVisible) {
      setState(() => _fabVisible = visible!);
    }
    return false;
  }

  List<GuideStep> _guideSteps() {
    if (_measurements.isEmpty) {
      return [
        GuideStep(
          target: _startKey,
          icon: Icons.flag_outlined,
          title: 'Empieza aquí',
          body: 'Son 3 pasos: define tu meta, registra tu peso de hoy y tómate '
              'una foto. Toca el botón de cada paso.',
        ),
        GuideStep(
          target: _fabKey,
          icon: Icons.add,
          title: 'Registra tu peso',
          body: 'Con este botón + guardas tu peso y tus medidas. Hazlo una vez '
              'por semana, en la mañana y antes de desayunar.',
        ),
        const GuideStep(
          icon: Icons.auto_awesome,
          title: 'Analiza tu cuerpo con IA',
          body: 'Cuando tengas un registro de peso y una foto, toca la foto y '
              'presiona "Analizar composición con IA": estima tu % de grasa '
              'y de músculo.',
        ),
      ];
    }
    return [
      GuideStep(
        target: _goalKey,
        icon: Icons.flag_outlined,
        title: 'Tu meta de peso',
        body: 'Toca aquí para definir o cambiar el peso al que quieres llegar. '
            'Te decimos cuánto te falta.',
      ),
      GuideStep(
        target: _chartKey,
        icon: Icons.show_chart,
        title: 'Tu gráfica',
        body: 'Elige qué ver: peso, grasa, cintura... Verde = vas hacia tu '
            'objetivo; amarillo = vas en sentido contrario.',
      ),
      GuideStep(
        target: _photosKey,
        icon: Icons.auto_awesome,
        title: 'Fotos y análisis con IA',
        body: 'Presiona "Agregar" para tomarte una foto: se guarda con tu '
            'último registro de peso. Después toca la foto y presiona '
            '"Analizar composición con IA" para estimar tu % de grasa y músculo.',
      ),
      GuideStep(
        target: _fabKey,
        icon: Icons.add,
        title: 'Nuevo registro',
        body: 'Con el botón + registras tu peso y medidas. Mídete una vez por '
            'semana para ver tu avance.',
      ),
    ];
  }

  /// Sin registros se explica cómo empezar; con registros, la gráfica, las
  /// fotos y la IA. Son dos tutoriales distintos: el segundo sale cuando el
  /// socio ya tiene datos, aunque haya visto el primero.
  void _maybeShowGuide() {
    final id = _measurements.isEmpty ? 'progreso_inicio' : 'progreso';
    if (_guideShown == id) return;
    _guideShown = id;
    SectionGuide.showIfFirstTime(context, id, _guideSteps);
  }

  Future<void> _loadPhotos() async {
    final token = UserSession.token;
    if (token == null) return;
    try {
      final photos = await _trackingService.fetchPhotos(token);
      if (mounted) setState(() => _photos = photos);
    } catch (e) {
      debugPrint('Tracking: photos failed: $e');
    }
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final token = UserSession.token;
    if (token == null) return;
    try {
      final x = await _picker.pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() => _uploadingPhoto = true);
      // La foto se liga a TU registro de peso más reciente (lo normal: te
      // pesas y te tomas la foto). Antes se buscaba "el registro más cercano
      // por fecha" al analizar, y con dos registros el mismo día las dos
      // fotos tomaban el mismo peso.
      final linked = _recentMeasurement();
      final photo = await _trackingService.addPhoto(
        token,
        'data:image/jpeg;base64,${base64Encode(bytes)}',
        measurementId: linked?.id,
      );
      if (!mounted) return;
      setState(() {
        // La nueva es de hoy: va al final (la lista va de la más vieja a la
        // más nueva, igual que la manda el servidor).
        _photos = [..._photos, photo];
      });
      _showSnack(linked != null
          ? 'Foto guardada con tu registro de ${MeasurementPickerSheet.label(linked)}.'
          : 'Foto guardada. Registra tu peso (botón +) para poder analizarla.');
    } on PlatformException {
      _showSnack('No pudimos abrir la cámara o la galería. Revisa los permisos de la app.');
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _openPhoto(ProgressPhoto photo) async {
    final measurement = _measurementFor(photo);
    final analyzeKey = GlobalKey();
    final linkKey = GlobalKey();
    BuildContext? dialogContext;
    // Primera vez que abre una foto: le enseñamos el botón de la IA.
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      final c = dialogContext;
      if (c == null || !c.mounted) return;
      SectionGuide.showIfFirstTime(c, 'progreso_foto', () => [
            GuideStep(
              target: analyzeKey,
              icon: Icons.auto_awesome,
              title: 'Analiza tu composición con IA',
              body: 'Presiona aquí: la IA mira tu foto y, con el peso y la '
                  'cintura de su registro, estima tu % de grasa y de músculo. '
                  'Puedes guardar el resultado en ese registro.',
            ),
            GuideStep(
              target: linkKey,
              icon: Icons.monitor_weight_outlined,
              title: 'El registro de esta foto',
              body: 'Es el peso con el que se calcula. Si no es el correcto '
                  '(o la foto no tiene), tócalo aquí para elegir el registro.',
            ),
          ]);
    });
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) {
        dialogContext = ctx;
        return Dialog(
        backgroundColor: AppColors.surfaceHigh,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                child: InteractiveViewer(child: Image.memory(photo.bytes, fit: BoxFit.contain)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: AppButton(
                key: analyzeKey,
                label: 'Analizar composición con IA',
                icon: Icons.auto_awesome,
                expanded: true,
                onPressed: () => Navigator.pop(ctx, 'analyze'),
              ),
            ),
            Padding(
              key: linkKey,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, 0),
              child: Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      measurement != null
                          ? 'Registro: ${MeasurementPickerSheet.label(measurement)}'
                          : 'Sin registro de peso',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  if (_measurements.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'link'),
                      child: Text(measurement != null ? 'Cambiar' : 'Elegir'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(ProgressPhotosCard.dateLabel(photo), style: AppTextStyles.titleMd)),
                  TextButton(onPressed: () => Navigator.pop(ctx, 'delete'), child: const Text('Borrar')),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
    if (action == 'analyze') return _analyzePhoto(photo);
    if (action == 'link') {
      await _chooseMeasurement(photo);
      return;
    }
    if (action != 'delete') return;
    final token = UserSession.token;
    if (token == null) return;
    try {
      await _trackingService.deletePhoto(token, photo.id);
      if (mounted) setState(() => _photos = _photos.where((p) => p.id != photo.id).toList());
    } catch (e) {
      _showSnack('No se pudo borrar la foto. Inténtalo de nuevo.');
    }
  }

  /// El registro más reciente si es de estos días (para ligar una foto nueva).
  BodyMeasurement? _recentMeasurement() {
    for (final m in _measurements) {
      if (m.weightKg <= 0) continue;
      final d = DateTime.tryParse(m.date);
      if (d == null) return null;
      return DateTime.now().difference(d).inDays <= 3 ? m : null;
    }
    return null;
  }

  /// El registro de peso al que está ligada la foto (null si no tiene o si
  /// ese registro se borró).
  BodyMeasurement? _measurementFor(ProgressPhoto photo) {
    final id = photo.measurementId;
    if (id == null) return null;
    for (final m in _measurements) {
      if (m.id == id && m.weightKg > 0) return m;
    }
    return null;
  }

  /// Pide elegir el registro de la foto y lo guarda. Devuelve el elegido.
  Future<BodyMeasurement?> _chooseMeasurement(ProgressPhoto photo) async {
    final picked = await MeasurementPickerSheet.show(
      context,
      measurements: _measurements,
      initialId: photo.measurementId ?? _measurementNear(photo)?.id,
    );
    if (picked == null || !mounted) return null;
    if (picked.id == photo.measurementId) return picked;
    final token = UserSession.token;
    if (token == null) return null;
    try {
      final updated = await _trackingService.linkPhoto(token, photo.id, picked.id);
      if (!mounted) return null;
      setState(() {
        _photos = [for (final p in _photos) p.id == photo.id ? p.withMeasurement(updated.measurementId) : p];
      });
      return picked;
    } catch (e) {
      if (!e.toString().contains('expir')) {
        _showSnack('No se pudo cambiar el registro. Inténtalo de nuevo.');
      }
      return null;
    }
  }

  /// Sugerencia para fotos sin registro: la medición más cercana a la fecha
  /// de la foto (solo preselecciona; el socio confirma).
  BodyMeasurement? _measurementNear(ProgressPhoto photo) {
    final photoDate = photo.dateTime ?? DateTime.now();
    BodyMeasurement? best;
    int? bestDiff;
    for (final m in _measurements) {
      final d = DateTime.tryParse(m.date);
      if (d == null || m.weightKg <= 0) continue;
      final diff = d.difference(photoDate).inDays.abs();
      if (bestDiff == null || diff < bestDiff) {
        best = m;
        bestDiff = diff;
      }
    }
    return best;
  }

  Future<void> _analyzePhoto(ProgressPhoto photo) async {
    if (!_measurements.any((m) => m.weightKg > 0)) {
      _showSnack('Primero registra tu peso en Progreso (botón +).');
      return;
    }
    // Foto vieja o cuyo registro se borró: que el socio diga de cuál es.
    final measurement = _measurementFor(photo) ?? await _chooseMeasurement(photo);
    if (measurement == null || !mounted) return;
    if (_userHeight == null) {
      _showSnack('Primero registra tu altura.');
      _showEditHeightDialog();
      return;
    }
    if (_userAge == null) {
      _showSnack('Agrega tu fecha de nacimiento en tu perfil para calcularlo.');
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
              SizedBox(width: AppSpacing.lg),
              Expanded(child: Text('Analizando tu foto y tus medidas…')),
            ],
          ),
        ),
      ),
    );

    BodyComposition? result;
    String? error;
    try {
      result = await NutritionService().analyzeBodyComposition(
        imageDataUri: 'data:image/jpeg;base64,${base64Encode(photo.bytes)}',
        sex: _userGender,
        age: _userAge!,
        weightKg: measurement.weightKg,
        heightCm: _userHeight!,
        waistCm: measurement.waist,
      );
    } catch (e) {
      error = friendlyError(e);
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // cierra "Analizando…"
    if (result == null) {
      _showSnack(error ?? 'No se pudo analizar la foto.');
      return;
    }

    final save = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (_) => BodyCompositionSheet(
        result: result!,
        measurementLabel: MeasurementPickerSheet.label(measurement),
      ),
    );
    if (save != true) return;

    final token = UserSession.token;
    if (token == null) return;
    try {
      // Se guarda EN el registro de la foto. Antes se creaba otra medición
      // con fecha de hoy y el peso de ese registro: repetía un peso viejo
      // como si fuera el de hoy.
      await _trackingService.saveBodyComposition(
        token,
        measurement.id,
        bodyFat: result.bodyFatPct,
        muscle: result.musclePct,
      );
      _loadMeasurements(silent: true);
      _showSnack('Guardado en tu registro de ${MeasurementPickerSheet.label(measurement)}.');
    } catch (e) {
      if (!e.toString().contains('expir')) {
        _showSnack('No se pudo guardar. Inténtalo de nuevo.');
      }
    }
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cómo uso Progreso?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HelpItem(Icons.monitor_weight_outlined, 'Mídete una vez por semana',
                  'El mismo día, en la mañana y antes de desayunar. El peso cambia mucho durante el día; así comparas parejo.'),
              _HelpItem(Icons.flag_outlined, 'Tu meta',
                  'El peso al que quieres llegar. Te decimos cuánto te falta y, cuando haya suficientes datos, cuándo podrías llegar.'),
              _HelpItem(Icons.show_chart, 'La gráfica',
                  'Elige peso, grasa, cintura... Verde = vas hacia tu objetivo; amarillo = vas en sentido contrario.'),
              _HelpItem(Icons.photo_camera_outlined, 'Las fotos',
                  'Cada 2 a 4 semanas. A veces la báscula no se mueve pero tu cuerpo sí cambia (ganas músculo y bajas grasa).'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ),
    );
  }

  Future<void> _loadGoal() async {
    final token = UserSession.token;
    if (token == null) return;
    try {
      final goal = await _trackingService.getWeightGoal(token);
      if (mounted) {
        setState(() {
          _weightGoal = goal.goal;
          _goalStart = goal.start;
        });
      }
    } catch (e) {
      // Sin meta la pantalla funciona igual (muestra "Define tu meta").
      debugPrint('Tracking: goal failed: $e');
    }
  }

  Future<void> _showEditGoalDialog() async {
    // Meta ya cumplida -> se define una NUEVA (campo vacío): empieza desde
    // el peso actual. Si está en curso, es una corrección y conserva el inicio.
    final reached = ProgressInsights(_measurements)
            .weightGoal(_weightGoal, startKg: _goalStart)
            ?.reached ??
        false;
    final controller = TextEditingController(
      text: reached ? '' : _weightGoal?.toStringAsFixed(1) ?? '',
    );
    final formKey = GlobalKey<FormState>();
    // Devuelve el valor nuevo, NaN para "quitar meta" o null si cancela.
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(reached ? 'Nueva meta de peso' : 'Meta de peso'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Peso meta (kg)',
              hintText: 'Ej: 72',
            ),
            validator: (value) {
              final parsed = _parseNum(value ?? '');
              if (parsed == null) return 'Ingresa un numero valido';
              // Mismo rango que acepta el backend.
              if (parsed < 30 || parsed > 300) return 'Debe estar entre 30 y 300 kg';
              return null;
            },
          ),
        ),
        actions: [
          if (_weightGoal != null)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(double.nan),
              child: const Text('Quitar meta'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(dialogContext).pop(_parseNum(controller.text));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final token = UserSession.token;
    if (token == null) return;
    final newGoal = result.isNaN ? null : result;
    try {
      final saved = await _trackingService.saveWeightGoal(token, newGoal);
      if (mounted) {
        setState(() {
          _weightGoal = saved.goal;
          _goalStart = saved.start;
        });
      }
    } catch (e) {
      _showSnack('No se pudo guardar tu meta. Inténtalo de nuevo.');
    }
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Computes age in whole years from an ISO "YYYY-MM-DD" birthdate string.
  int? _calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return null;
    final birthDate = DateTime.tryParse(birthDateStr);
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }

  Future<void> _loadUserData() async {
    final token = UserSession.token;
    if (token == null) return;

    // Height and profile load independently — the estimate should still
    // work off whichever one succeeds.
    ({double? heightCm, String? sex})? body;
    try {
      body = await _trackingService.getUserBody(token);
    } catch (e) {
      debugPrint('Tracking: height failed: $e');
    }

    String? birthDate = UserSession.birthDate;
    try {
      final profile = await _apiService.getMemberProfile(token);
      await UserSession.mergeProfile(profile);
      birthDate = profile['fechaNacimiento'] as String? ?? birthDate;
    } catch (e) {
      debugPrint('Tracking: profile failed: $e');
    }

    if (!mounted) return;
    setState(() {
      if (body?.heightCm != null) _userHeight = body!.heightCm;
      if (body?.sex != null) _userGender = body!.sex!;
      _userAge = _calculateAge(birthDate);
    });
  }

  /// [silent]: recarga sin la pantalla de carga (no regresa al inicio de
  /// la lista, p. ej. después de guardar un análisis).
  Future<void> _loadMeasurements({bool silent = false}) async {
    final token = UserSession.token;
    if (token == null || token.isEmpty) return;

    if (!silent) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final data = await _trackingService.fetchMeasurements(token);
      if (!mounted) return;
      setState(() {
        _measurements = data;
      });
    } catch (e) {
      debugPrint('Tracking Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _maybeShowGuide();
      }
    }
  }

  /// Acepta coma o punto decimal (algunos teclados ponen coma).
  double? _parseNum(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _saveMeasurement() async {
  try {
    final token = UserSession.token;
    if (token == null) return;

    final weight = _parseNum(_weightController.text);
    if (weight == null || weight <= 0) {
      _showSnack('Ingresa un peso válido.');
      return;
    }
    // Cintura, pecho y brazo son opcionales — no todos van a medirse con
    // cinta métrica.
    final waist = _parseNum(_waistController.text);
    final chest = _parseNum(_chestController.text);
    final arm = _parseNum(_armController.text);

    double? bodyFat;
    double? muscle;

    if (_autoCalc && _userHeight != null) {
      if (waist != null) {
        // Más preciso: usa la cintura real.
        bodyFat = BodyCalculationsService.calculateBodyFat(
          waistCm: waist,
          heightCm: _userHeight!,
          gender: _userGender,
        );
      } else if (_userAge != null) {
        // Sin cintura: estimar solo con peso, altura, edad y sexo
        // (fórmula de Deurenberg). Menos preciso, pero no requiere
        // medirse con cinta.
        bodyFat = BodyCalculationsService.calculateBodyFatFromBMI(
          weightKg: weight,
          heightCm: _userHeight!,
          age: _userAge!,
          gender: _userGender,
        );
      }

      if (bodyFat != null) {
        muscle = BodyCalculationsService.calculateMusclePercentage(
          weightKg: weight,
          bodyFatPercentage: bodyFat,
          gender: _userGender,
        );
      }
    }

    await _trackingService.addMeasurement(
      token: token,
      weightKg: weight,
      bodyFat: bodyFat,
      muscle: muscle,
      waist: waist,
      chest: chest,
      arm: arm,
      heightCm: _userHeight, // Enviar altura para que la BD calcule IMC
      notes: _notesController.text,
    );

    _clearFields();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    _loadMeasurements();

    messenger.showSnackBar(
      const SnackBar(content: Text('Medición guardada exitosamente')),
    );
  } catch (e) {
    debugPrint('Save Measurement Error: $e');
    // Si la sesión expiró, checkAuthResponse ya redirige al login; no
    // molestamos con un error encima.
    if (mounted && !e.toString().contains('expir')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la medición. Inténtalo de nuevo.'),
        ),
      );
    }
  }
}

void _showSnack(String msg) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

Future<void> _saveUserHeight(double height) async {
  final token = UserSession.token;
  if (token == null) return;
  
  try {
    await _trackingService.saveUserBody(token, heightCm: height);
    if (!mounted) return;
    setState(() {
      _userHeight = height;
    });
  } catch (e) {
    debugPrint('Error guardando altura: $e');
  }
}

Future<void> _showEditHeightDialog() async {
  final controller = TextEditingController(
    text: _userHeight?.toStringAsFixed(0) ?? '',
  );
  final formKey = GlobalKey<FormState>();

  // Antes esto era un TextField sin Form ni validator: se podia guardar
  // "5" cm o "9999" cm (o texto, que simplemente no hacia nada, sin
  // ningun mensaje). Esa altura se usa para calcular IMC/grasa corporal
  // (BodyCalculationsService, que no acota el resultado) — una altura
  // absurda produce un IMC absurdo en la tarjeta de Progreso. Rango
  // igual al que ya usa el backend para nutricion (120-230 cm).
  final newHeight = await showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Altura'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              hintText: 'Ej: 175',
            ),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null) return 'Ingresa un numero valido';
              if (parsed < 120 || parsed > 230) {
                return 'Debe estar entre 120 y 230 cm';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final value = double.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );

  if (newHeight == null) return;
  await _saveUserHeight(newHeight);
}

void _openAddMeasurementSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DynamicAddMeasurementSheet(
        weightController: _weightController,
        waistController: _waistController,
        chestController: _chestController,
        armController: _armController,
        notesController: _notesController,
        existingHeight: _userHeight,
        existingAge: _userAge,
        initialGender: _userGender,
        onSaveHeight: _saveUserHeight,
        onGenderChanged: (gender) {
          if (gender == _userGender) return;
          _userGender = gender;
          // Se guarda en el perfil: la próxima vez (y en Nutrición) ya viene elegido.
          final token = UserSession.token;
          if (token != null) {
            _trackingService
                .saveUserBody(token, sex: gender)
                .catchError((e) => debugPrint('Error guardando sexo: $e'));
          }
        },
        onAgeChanged: (age) {
          _userAge = age;
        },
        onAutoCalcChanged: (value) {
          _autoCalc = value;
        },
        onSave: _saveMeasurement,
      );
    },
  );
}

  void _clearFields() {
    _weightController.clear();
    _waistController.clear();
    _chestController.clear();
    _armController.clear();
    _notesController.clear();
  }

  Future<void> _deleteMeasurement(BodyMeasurement measurement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar medición?'),
        content: Text(
          'Se eliminará la medición del ${measurement.date}. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = UserSession.token;
    if (token == null) return;

    try {
      await _trackingService.deleteMeasurement(token, measurement.id);
      await _loadMeasurements();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Widget _buildHeightRow() {
    return Row(
      children: [
        const Icon(Icons.height, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _userHeight != null
              ? 'Altura ${_userHeight!.toStringAsFixed(0)} cm'
              : 'Altura no registrada',
          style: AppTextStyles.label,
        ),
        const Spacer(),
        TextButton(
          onPressed: _showEditHeightDialog,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: AppTextStyles.label,
          ),
          child: Text(_userHeight != null ? 'Editar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget _buildGettingStarted() {
    Widget step(int n, String title, String text, String action, VoidCallback onTap, {bool done = false}) {
      return AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: done ? AppColors.success : AppColors.accentSoft,
              child: done
                  ? const Icon(Icons.check, size: 18, color: AppColors.onSuccess)
                  : Text('$n', style: AppTextStyles.titleMd.copyWith(color: AppColors.accent)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMd),
                  const SizedBox(height: 2),
                  Text(text, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            if (!done) TextButton(onPressed: onTap, child: Text(action)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.navBarClearance + 76),
      children: [
        Text('Empieza a ver tu progreso', style: AppTextStyles.displayMd),
        const SizedBox(height: AppSpacing.xs),
        Text('Son 3 pasos y te toma 2 minutos. Después solo vuelves una vez por semana.',
            style: AppTextStyles.bodySm),
        const SizedBox(height: AppSpacing.lg),
        Column(key: _startKey, children: [
        step(1, 'Define tu meta', 'El peso al que quieres llegar.', 'Definir', _showEditGoalDialog,
            done: _weightGoal != null),
        const SizedBox(height: AppSpacing.sm),
        step(2, 'Registra tu peso de hoy', 'Es tu punto de partida.', 'Registrar', _openAddMeasurementSheet),
        const SizedBox(height: AppSpacing.sm),
        step(3, 'Tómate una foto', 'Para comparar el antes y el ahora.', 'Foto', _addPhoto,
            done: _photos.isNotEmpty),
        ]),
      ],
    );
  }

  Widget _fab() {
    return Positioned(
      right: AppSpacing.screenX,
      bottom: AppSpacing.navBarClearance,
      child: AnimatedSlide(
        offset: _fabVisible ? Offset.zero : const Offset(0, 2.5),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _fabVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: IgnorePointer(
            ignoring: !_fabVisible,
            child: FloatingActionButton(
              key: _fabKey,
              onPressed: _openAddMeasurementSheet,
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_measurements.isEmpty) {
      return AppScaffold(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                AppSpacing.md,
                AppSpacing.screenX,
                0,
              ),
              child: Column(
                children: [
                  _buildHeightRow(),
                  Expanded(child: _buildGettingStarted()),
                ],
              ),
            ),
            _fab(),
          ],
        ),
      );
    }

    final latest = _measurements.first;

    // The backend doesn't compute/store IMC — derive it locally.
    final latestHeight = latest.heightCm ?? _userHeight;
    final latestImc = latestHeight != null
        ? BodyCalculationsService.calculateBMI(
            weightKg: latest.weightKg,
            heightCm: latestHeight,
          )
        : null;

    final insights = ProgressInsights(_measurements);
    final metrics = insights.availableMetrics();
    final metric = metrics.firstWhere((m) => m.key == _metricKey,
        orElse: () => metrics.isNotEmpty ? metrics.first : ProgressMetric.all.first);
    final points = insights.series(metric);
    final changes = insights.changes(metric);
    final weightMetric = ProgressMetric.all.first;
    final goalProgress = insights.weightGoal(_weightGoal, startKg: _goalStart);
    final daysSince = insights.daysSinceLast();
    final summary = insights.summary(_weightGoal, goalStartKg: _goalStart);

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          NotificationListener<ScrollUpdateNotification>(
            onNotification: _onScroll,
            child: ListView(
            // Construye también lo que está fuera de pantalla: el tutorial
            // necesita encontrar (y desplazarse a) la tarjeta de fotos.
            scrollCacheExtent: const ScrollCacheExtent.pixels(4000),
            // Deja hueco para la barra de nav flotante + el FAB de "＋".
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX,
              AppSpacing.md,
              AppSpacing.screenX,
              AppSpacing.navBarClearance + 76,
            ),
            children: [
              _buildHeightRow(),
              const SizedBox(height: AppSpacing.lg),
              if (summary != null) ...[
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TU RESUMEN',
                                style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(summary.title, style: AppTextStyles.titleLg),
                            const SizedBox(height: 4),
                            Text(summary.detail, style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '¿Cómo uso Progreso?',
                        onPressed: _showHelp,
                        icon: const Icon(Icons.help_outline, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (daysSince != null && daysSince >= 7) ...[
                _ReminderBanner(days: daysSince, onAdd: _openAddMeasurementSheet),
                const SizedBox(height: AppSpacing.md),
              ],
              GoalCard(
                key: _goalKey,
                progress: goalProgress,
                goal: _weightGoal,
                weeklyRate: insights.weeklyRate(weightMetric),
                onEdit: _showEditGoalDialog,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                key: _chartKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final m in metrics)
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: ChoiceChip(
                                label: Text(m.label),
                                selected: m.key == metric.key,
                                onSelected: (_) => setState(() => _metricKey = m.key),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (points.length >= 2)
                      MetricLineChart(
                        points: points,
                        unit: metric.unit,
                        goal: metric.key == 'peso' ? _weightGoal : null,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Text(
                          'Registra al menos 2 mediciones de ${metric.label.toLowerCase()} para ver tu gráfica.',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                    if (changes.sinceStart != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _ChangeStat(
                              label: 'Desde el inicio',
                              delta: changes.sinceStart!,
                              unit: metric.unit,
                              good: ProgressInsights.isImprovement(metric, changes.sinceStart!,
                                  weightGoal: _weightGoal, current: points.last.value),
                            ),
                          ),
                          Expanded(
                            child: _ChangeStat(
                              label: 'Desde la anterior',
                              delta: changes.sinceLast!,
                              unit: metric.unit,
                              good: ProgressInsights.isImprovement(metric, changes.sinceLast!,
                                  weightGoal: _weightGoal, current: points.last.value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ProgressPhotosCard(
                key: _photosKey,
                photos: _photos,
                measurements: _measurements,
                uploading: _uploadingPhoto,
                onAdd: _addPhoto,
                onOpen: _openPhoto,
              ),
              const SizedBox(height: AppSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressSummaryCard(
                      title: 'Peso',
                      value: '${latest.weightKg.toStringAsFixed(1)} kg',
                      icon: Icons.monitor_weight_outlined,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ProgressSummaryCard(
                      title: 'Grasa',
                      value: latest.bodyFat != null
                          ? '${latest.bodyFat!.toStringAsFixed(1)}%'
                          : '--',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressSummaryCard(
                      title: 'Músculo',
                      value: latest.muscle != null
                          ? '${latest.muscle!.toStringAsFixed(1)}%'
                          : '--',
                      icon: Icons.fitness_center_outlined,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ProgressSummaryCard(
                      title: 'Cintura',
                      value: latest.waist != null
                          ? '${latest.waist!.toStringAsFixed(1)} cm'
                          : '--',
                      icon: Icons.straighten_outlined,
                    ),
                  ],
                ),
              ),
              if (latestImc != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: BodyCalculationsService.getBMIColor(latestImc)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('IMC', style: AppTextStyles.label),
                      Text(
                        '${latestImc.toStringAsFixed(1)}  ·  ${BodyCalculationsService.getBMICategory(latestImc)}',
                        style: AppTextStyles.titleMd.copyWith(
                          color: BodyCalculationsService.getBMIColor(latestImc),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Historial'),
              for (var i = 0; i < _measurements.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Builder(builder: (_) {
                    final m = _measurements[i];
                    // La lista viene de la más reciente a la más vieja.
                    final prev = i + 1 < _measurements.length ? _measurements[i + 1] : null;
                    final delta = prev == null ? null : m.weightKg - prev.weightKg;
                    return MeasurementTile(
                      measurement: m,
                      onDelete: () => _deleteMeasurement(m),
                      weightDelta: delta,
                      deltaIsGood: delta == null
                          ? null
                          : ProgressInsights.isImprovement(weightMetric, delta,
                              weightGoal: _weightGoal, current: m.weightKg),
                    );
                  }),
                ),
            ],
          ),
          ),
          _fab(),
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  final int days;
  final VoidCallback onAdd;

  const _ReminderBanner({required this.days, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Tu última medición fue hace $days días. Mídete hoy para ver tu avance.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
            ),
          ),
          TextButton(onPressed: onAdd, child: const Text('Medir')),
        ],
      ),
    );
  }
}

class _ChangeStat extends StatelessWidget {
  final String label;
  final double delta;
  final String unit;
  final bool? good;

  const _ChangeStat({required this.label, required this.delta, required this.unit, required this.good});

  @override
  Widget build(BuildContext context) {
    final color = switch (good) {
      true => AppColors.success,
      false => AppColors.warning,
      null => AppColors.textPrimary,
    };
    final sign = delta > 0.04 ? '+' : (delta < -0.04 ? '−' : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text('$sign${delta.abs().toStringAsFixed(1)} $unit',
            style: AppTextStyles.statSm.copyWith(color: color)),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _HelpItem(this.icon, this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(text, style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
