import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_chip.dart';
import '../auth/user_session.dart';
import '../nutrition/models/nutrition_enums.dart';
import '../tracking/services/tracking_service.dart';

/// Bienvenida con un mini tutorial de la app. Sale sola la primera vez que
/// cada socio entra (se recuerda por socio en el teléfono) y se puede volver
/// a ver desde el menú. La última página pide altura y sexo una sola vez:
/// Progreso y Nutrición los toman de ahí.
class WelcomeTour extends StatefulWidget {
  const WelcomeTour({super.key});

  static String get _seenKey =>
      'welcome_seen_${UserSession.memberId ?? UserSession.phone ?? ''}';

  /// Termina cuando la bienvenida de la primera vez ya se cerró (o no tocaba
  /// mostrarla). Los tutoriales de cada sección esperan esto para no salir
  /// encima de la bienvenida.
  static Future<void> get ready => _ready ?? Future<void>.value();
  static Future<void>? _ready;

  static Future<void> showIfFirstTime(BuildContext context) =>
      _ready = _showIfFirstTime(context);

  static Future<void> _showIfFirstTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey) == true || !context.mounted) return;
    // Se marca antes de abrir: si lo cierran con "atrás" tampoco vuelve a salir.
    await prefs.setBool(_seenKey, true);
    if (context.mounted) await show(context);
  }

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const WelcomeTour(),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  State<WelcomeTour> createState() => _WelcomeTourState();
}

class _TourStep {
  final IconData icon;
  final Color color;
  final String eyebrow;
  final String title;
  final String body;
  final List<String> tips;

  const _TourStep({
    required this.icon,
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.tips = const [],
  });
}

const _steps = [
  _TourStep(
    icon: Icons.qr_code_2_rounded,
    color: AppColors.accent,
    eyebrow: 'CHECK-IN',
    title: 'Entra con tu QR',
    body: 'En Check-In está tu código personal. Muéstralo en recepción y '
        'listo: sin tarjetas ni filas.',
    tips: ['Tu historial de visitas', 'Estado de tu membresía'],
  ),
  _TourStep(
    icon: Icons.fitness_center_rounded,
    color: AppColors.tintBlue,
    eyebrow: 'RUTINAS',
    title: 'Tu entrenamiento del día',
    body: 'Tu entrenador te asigna rutinas. Ábrelas para ver cada ejercicio '
        'con su imagen, series y repeticiones.',
    tips: ['Rutina de hoy en Inicio', 'Ejercicios con imagen'],
  ),
  _TourStep(
    icon: Icons.show_chart_rounded,
    color: AppColors.success,
    eyebrow: 'PROGRESO',
    title: 'Mira cómo avanzas',
    body: 'Registra tu peso y medidas: calculamos tu IMC y grasa corporal '
        'y te mostramos la gráfica. Ponte una meta de peso.',
    tips: ['Fotos de progreso', 'Meta de peso'],
  ),
  _TourStep(
    icon: Icons.restaurant_rounded,
    color: AppColors.warning,
    eyebrow: 'NUTRICIÓN',
    title: 'Toma foto a tu comida',
    body: 'La IA estima calorías, proteína, carbos y grasa. Define tu '
        'objetivo una vez y te dice cuánto te falta hoy.',
    tips: ['Análisis con IA', 'Objetivo diario'],
  ),
];

class _WelcomeTourState extends State<WelcomeTour> {
  final _pages = PageController();
  final _height = TextEditingController();
  final _service = TrackingService();
  int _page = 0;
  Sex? _sex;
  bool _saving = false;
  String? _error;

  // Bienvenida + pasos + "tus datos".
  int get _total => _steps.length + 2;
  bool get _onDataPage => _page == _total - 1;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _pages.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    final token = UserSession.token;
    if (token == null) return;
    final body = await _service.getUserBody(token);
    if (!mounted || body == null) return;
    setState(() {
      if (body.heightCm != null && _height.text.isEmpty) {
        _height.text = body.heightCm!.round().toString();
      }
      if (body.sex != null) _sex ??= Sex.fromId(body.sex);
    });
  }

  String get _firstName {
    final raw = (UserSession.firstName ?? '').trim();
    if (raw.isEmpty) return '';
    final first = raw.split(' ').first;
    return first[0].toUpperCase() + first.substring(1).toLowerCase();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(WelcomeTour._seenKey, true);
    if (mounted) Navigator.of(context).pop();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    _pages.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _saveData() async {
    final text = _height.text.trim();
    final height = double.tryParse(text.replaceAll(',', '.'));
    if (text.isNotEmpty && (height == null || height < 120 || height > 230)) {
      setState(() => _error = 'La altura debe estar entre 120 y 230 cm');
      return;
    }
    final token = UserSession.token;
    if (token != null && (height != null || _sex != null)) {
      setState(() {
        _saving = true;
        _error = null;
      });
      try {
        await _service.saveUserBody(token, heightCm: height, sex: _sex?.id);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = 'No se pudo guardar. Revisa tu conexión o hazlo después.';
        });
        return;
      }
    }
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final color = _page == 0 || _onDataPage
        ? AppColors.accent
        : _steps[_page - 1].color;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Brillo de color detrás del contenido; cambia con cada página.
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.55),
                radius: 0.9,
                colors: [color.withValues(alpha: 0.22), AppColors.bg],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _onDataPage
                        ? null
                        : TextButton(
                            onPressed: _finish,
                            child: const Text('Saltar'),
                          ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() {
                      _page = i;
                      _error = null;
                    }),
                    children: [
                      _welcomePage(),
                      for (final step in _steps) _stepPage(step),
                      _dataPage(),
                    ],
                  ),
                ),
                _dots(color),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenX,
                    AppSpacing.lg,
                    AppSpacing.screenX,
                    AppSpacing.lg,
                  ),
                  child: _onDataPage
                      ? Column(
                          children: [
                            AppButton(
                              label: 'Guardar y empezar',
                              icon: Icons.check_rounded,
                              loading: _saving,
                              onPressed: _saveData,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Lo hago después',
                              variant: AppButtonVariant.ghost,
                              onPressed: _saving ? null : _finish,
                            ),
                          ],
                        )
                      : AppButton(
                          label: _page == 0 ? 'Comenzar' : 'Siguiente',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _next,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dots(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            width: i == _page ? 24 : 8,
            decoration: BoxDecoration(
              color: i == _page ? color : AppColors.hairlineStrong,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
      ],
    );
  }

  Widget _pageBody(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _welcomePage() {
    final name = _firstName;
    return _pageBody([
      const SizedBox(height: AppSpacing.xl),
      Center(
        child: _Pop(
          child: Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      Text('PULSEUP',
          style: AppTextStyles.label
              .copyWith(color: AppColors.accent, letterSpacing: 2)),
      const SizedBox(height: AppSpacing.sm),
      Text(
        name.isEmpty ? '¡Bienvenido!' : '¡Bienvenido, $name!',
        style: AppTextStyles.displayLg,
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Tu gimnasio ahora cabe en tu bolsillo. Te mostramos lo básico en '
        'menos de un minuto.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.xl),
      for (final s in _steps)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(s.icon, size: 18, color: s.color),
              const SizedBox(width: AppSpacing.md),
              Text(s.title, style: AppTextStyles.bodySm),
            ],
          ),
        ),
    ]);
  }

  Widget _stepPage(_TourStep step) {
    return _pageBody([
      const SizedBox(height: AppSpacing.xl),
      Center(
        child: _Pop(
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [step.color, step.color.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Icon(step.icon, size: 60, color: AppColors.onAccent),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      Text(step.eyebrow,
          style: AppTextStyles.label
              .copyWith(color: step.color, letterSpacing: 2)),
      const SizedBox(height: AppSpacing.sm),
      Text(step.title, style: AppTextStyles.displayMd),
      const SizedBox(height: AppSpacing.md),
      Text(
        step.body,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.xl),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final tip in step.tips)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: step.color),
                  const SizedBox(width: 6),
                  Text(tip, style: AppTextStyles.label),
                ],
              ),
            ),
        ],
      ),
    ]);
  }

  Widget _dataPage() {
    return _pageBody([
      const SizedBox(height: AppSpacing.lg),
      Text('ÚLTIMO PASO',
          style: AppTextStyles.label
              .copyWith(color: AppColors.accent, letterSpacing: 2)),
      const SizedBox(height: AppSpacing.sm),
      Text('Tus datos, una sola vez', style: AppTextStyles.displayMd),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Los usamos en Progreso y en Nutrición para calcular tu IMC y tus '
        'calorías. Así no te los volvemos a pedir.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text('Sexo', style: AppTextStyles.titleMd),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          for (final s in Sex.values) ...[
            AppChip(
              label: s.label,
              selected: _sex == s,
              onTap: () => setState(() => _sex = s),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      Text('Altura', style: AppTextStyles.titleMd),
      const SizedBox(height: AppSpacing.sm),
      TextField(
        controller: _height,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        decoration: const InputDecoration(
          labelText: 'Altura (cm)',
          hintText: 'Ej: 170',
          prefixIcon: Icon(Icons.height_rounded),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpacing.md),
        Text(_error!,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
      ],
      const SizedBox(height: AppSpacing.lg),
      Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Puedes cambiarlos cuando quieras en Progreso.',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    ]);
  }
}

/// Entrada con un pequeño rebote cada vez que la página se construye.
class _Pop extends StatelessWidget {
  final Widget child;
  const _Pop({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
