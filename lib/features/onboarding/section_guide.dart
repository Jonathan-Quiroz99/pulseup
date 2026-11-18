import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../auth/user_session.dart';
import 'welcome_tour.dart';

/// Un paso del mini tutorial de una sección: ilumina [target] (el botón o
/// tarjeta de la pantalla) y explica qué hacer con él. Sin [target], o si
/// ese widget no está en pantalla, sale como tarjeta centrada.
class GuideStep {
  final GlobalKey? target;
  final IconData icon;
  final String title;
  final String body;

  const GuideStep({
    this.target,
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// Mini tutorial por sección ("presiona aquí para..."). Sale solo la primera
/// vez que cada socio abre esa sección en este teléfono, y se puede repetir
/// con el botón "?" de la barra superior.
class SectionGuide {
  SectionGuide._();

  /// Repetir el tutorial de la pantalla visible. La pantalla lo registra con
  /// [attach]; la barra superior muestra el "?" solo cuando hay uno.
  static final ValueNotifier<VoidCallback?> replay = ValueNotifier(null);

  static bool _showing = false;

  /// La barra de navegación de abajo, para que el tutorial de Inicio la
  /// señale. Cada HomeScreen pone la suya (una sola GlobalKey compartida
  /// truena si dos HomeScreen coexisten, p. ej. al volver a iniciar sesión).
  static GlobalKey? navBarKey;

  static String _seenKey(String id) =>
      'guide_${id}_${UserSession.memberId ?? UserSession.phone ?? ''}';

  /// La pantalla avisa que tiene tutorial; [replay] lo vuelve a mostrar.
  /// Se llama desde initState.
  static void attach(Object owner, VoidCallback onReplay) {
    _owner = owner;
    _callback = onReplay;
    _publish();
  }

  /// Solo lo quita si nadie más lo reemplazó (al cambiar de pestaña, la
  /// pantalla nueva hace attach antes de que la vieja haga dispose).
  static void detach(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
      _callback = null;
      _publish();
    }
  }

  static Object? _owner;
  static VoidCallback? _callback;
  static bool _publishScheduled = false;

  /// attach/detach corren en initState/dispose, en pleno build: avisar ahí
  /// a la barra superior truena ("setState during build"). Se avisa al
  /// terminar el frame, con el valor que quede.
  static void _publish() {
    if (_publishScheduled) return;
    _publishScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _publishScheduled = false;
      replay.value = _callback;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Muestra la guía [id] si este socio nunca la vio. [steps] se arma justo
  /// antes de mostrarla, para que refleje lo que hay en pantalla.
  static Future<void> showIfFirstTime(
    BuildContext context,
    String id,
    List<GuideStep> Function() steps,
  ) async {
    // Si es la primera vez en la app, primero va la bienvenida.
    await WelcomeTour.ready;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey(id)) == true) return;
    // Esperar a que la pantalla termine de pintarse con sus datos.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!context.mounted || _showing) return;
    // Hay un diálogo u otra pantalla encima: se intenta la próxima vez.
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final list = _visible(steps());
    // Nada que señalar todavía (p. ej. sin rutina asignada): se queda
    // pendiente para cuando sí haya.
    if (list.isEmpty) return;
    await prefs.setBool(_seenKey(id), true);
    if (context.mounted) await show(context, list);
  }

  /// Para pruebas o "volver a ver todos los tutoriales".
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = '_${UserSession.memberId ?? UserSession.phone ?? ''}';
    for (final key in prefs.getKeys()) {
      if (key.startsWith('guide_') && key.endsWith(suffix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Quita los pasos cuyo widget no existe en esta pantalla (p. ej. el
  /// selector de días en una rutina de un solo día). Los pasos sin target
  /// (solo texto) siempre se quedan.
  static List<GuideStep> _visible(List<GuideStep> steps) => steps
      .where((s) => s.target == null || s.target!.currentContext != null)
      .toList();

  static Future<void> show(BuildContext context, List<GuideStep> all) async {
    final steps = _visible(all);
    if (_showing || steps.isEmpty) return;
    _showing = true;
    try {
      await Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (_, _, _) => _GuideOverlay(steps: steps),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } finally {
      _showing = false;
    }
  }
}

class _GuideOverlay extends StatefulWidget {
  final List<GuideStep> steps;
  const _GuideOverlay({required this.steps});

  @override
  State<_GuideOverlay> createState() => _GuideOverlayState();
}

class _GuideOverlayState extends State<_GuideOverlay> {
  int _index = 0;
  Rect? _hole;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
  }

  // Si la capa se quita sin "Entendido" (p. ej. al cerrar sesión se
  // reemplaza toda la navegación), igual se libera para la próxima guía.
  @override
  void dispose() {
    SectionGuide._showing = false;
    super.dispose();
  }

  GuideStep get _step => widget.steps[_index];

  /// Lleva el widget del paso a la vista (si está dentro de una lista) y
  /// mide dónde quedó para iluminarlo.
  Future<void> _focus() async {
    final targetContext = _step.target?.currentContext;
    if (targetContext != null && targetContext.mounted) {
      try {
        await Scrollable.ensureVisible(
          targetContext,
          alignment: 0.35,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } catch (_) {
        // No está en una lista con scroll: se ilumina donde está.
      }
    }
    if (!mounted) return;
    setState(() {
      _hole = _measure();
      _ready = true;
    });
  }

  Rect? _measure() {
    final ctx = _step.target?.currentContext;
    final box = ctx?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    // Solo el área de la app: sin la barra de estado ni los botones de
    // Android (la barra de abajo de la app incluye ese margen).
    final screen = Rect.fromLTRB(0, pad.top, size.width, size.height - pad.bottom);
    // Fuera de la pantalla (p. ej. tapado por la barra): mejor sin hueco.
    if (!screen.overlaps(rect)) return null;
    return rect.inflate(6).intersect(screen.deflate(4));
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _ready = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final hole = _hole;
    final last = _index == widget.steps.length - 1;
    final card = _card(last);

    return PopScope(
      canPop: true,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // bloquea toques a la pantalla de abajo
                child: TweenAnimationBuilder<Rect?>(
                  tween: RectTween(end: hole ?? Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0)),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  builder: (_, rect, _) => CustomPaint(
                    painter: _ScrimPainter(hole: hole == null ? null : rect),
                  ),
                ),
              ),
            ),
            if (_ready)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  delegate: _CardLayout(hole: hole, safe: padding),
                  child: card,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card(bool last) {
    final step = _step;
    return TweenAnimationBuilder<double>(
      key: ValueKey(_index),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
          boxShadow: const [BoxShadow(color: AppColors.ambientShadow, blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(step.title, style: AppTextStyles.titleMd)),
                if (widget.steps.length > 1)
                  Text('${_index + 1}/${widget.steps.length}',
                      style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(step.body,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (!last)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Saltar'),
                  ),
                const Spacer(),
                AppButton(
                  label: last ? 'Entendido' : 'Siguiente',
                  icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  expanded: false,
                  onPressed: _next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Coloca la tarjeta ya medida: debajo del hueco si cabe completa, si no
/// encima, y si no cabe en ningún lado, del lado con más espacio pero sin
/// salirse de la pantalla (antes podía quedar tapada por la barra de
/// Android). Sin hueco, centrada.
class _CardLayout extends SingleChildLayoutDelegate {
  final Rect? hole;
  final EdgeInsets safe;
  const _CardLayout({required this.hole, required this.safe});

  static const _gap = AppSpacing.md;
  static const _side = AppSpacing.lg;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: constraints.maxWidth - _side * 2,
        minWidth: constraints.maxWidth - _side * 2,
        maxHeight: constraints.maxHeight - safe.vertical - _gap * 2,
      );

  @override
  Offset getPositionForChild(Size size, Size child) {
    final top = safe.top + _gap;
    final bottom = size.height - safe.bottom - _gap;
    final h = hole;
    double y;
    if (h == null) {
      y = (size.height - child.height) / 2;
    } else if (h.bottom + _gap + child.height <= bottom) {
      y = h.bottom + _gap; // cabe abajo
    } else if (h.top - _gap - child.height >= top) {
      y = h.top - _gap - child.height; // cabe arriba
    } else if (bottom - h.bottom >= h.top - top) {
      y = bottom - child.height; // más espacio abajo: pegada al borde
    } else {
      y = top;
    }
    final maxY = bottom - child.height;
    y = y.clamp(top, maxY < top ? top : maxY);
    return Offset(_side, y);
  }

  @override
  bool shouldRelayout(_CardLayout old) => old.hole != hole || old.safe != safe;
}

/// Fondo oscuro con un hueco redondeado (y borde de color) sobre el widget
/// que se está explicando.
class _ScrimPainter extends CustomPainter {
  final Rect? hole;
  const _ScrimPainter({this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final scrim = Paint()..color = const Color(0xC7000000);
    final h = hole;
    if (h == null || h.isEmpty) {
      canvas.drawPath(full, scrim);
      return;
    }
    final rrect = RRect.fromRectAndRadius(h, const Radius.circular(AppSpacing.radiusMd));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, Path()..addRRect(rrect)),
      scrim,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole;
}
