import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/auth/user_session.dart';
import 'package:pulseup/features/routines/models/workout_exercise.dart';
import 'package:pulseup/features/routines/models/workout_plan.dart';
import 'package:pulseup/features/routines/models/workout_session.dart';
import 'package:pulseup/features/routines/services/routines_service.dart';
import 'package:pulseup/features/routines/widgets/routine_view.dart';
import 'package:pulseup/features/tracking/widgets/workout_history_card.dart';

/// Servidor falso: cuenta los días como lo hace el backend.
class _FakeService extends RoutinesService {
  final int dayCount;
  int done;
  final undone = <String>[];

  _FakeService({required this.dayCount, this.done = 0});

  @override
  Future<WorkoutSession> finishDay(String token, String planId, String day) async {
    final before = done++;
    return WorkoutSession(
      id: 'ws-$done',
      planId: planId,
      planName: 'Full Body',
      day: day,
      dayIndex: before % dayCount,
      dayCount: dayCount,
      exercises: 1,
      round: before ~/ dayCount + 1,
      closesRound: done % dayCount == 0,
      date: '2026-11-18',
    );
  }

  @override
  Future<void> undoDay(String token, String sessionId) async {
    undone.add(sessionId);
    done--;
  }
}

WorkoutPlan _plan({int completed = 0}) {
  WorkoutExercise ex(String id, String day) =>
      WorkoutExercise(id: id, name: 'Ejercicio $id', muscleGroup: '', sets: 3, reps: '10', rest: 60, day: day);
  return WorkoutPlan(
    id: 'wp-1',
    memberId: 'mem-1',
    name: 'Full Body',
    description: '',
    trainer: '',
    exercises: [ex('1', 'Día 1 — Torso'), ex('2', 'Día 2 — Pierna'), ex('3', 'Día 3 — Brazo')],
    completedSessions: completed,
  );
}

Future<void> _pump(WidgetTester tester, WorkoutPlan plan, _FakeService service, {VoidCallback? onOpenProgress}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: RoutineView(routine: plan, service: service, onOpenProgress: onOpenProgress),
      ),
    ),
  ));
}

void main() {
  setUp(() => UserSession.token = 'token');
  tearDown(() => UserSession.token = null);

  testWidgets('el "Hoy toca" sale de lo que dice el servidor', (tester) async {
    await _pump(tester, _plan(completed: 4), _FakeService(dayCount: 3, done: 4));
    // 4 hechos de 3 días → vuelta 2, toca el Día 2.
    expect(find.text('Día 2 — Pierna'), findsWidgets);
    expect(find.textContaining('Vuelta 2: 1 de 3 días hechos'), findsOneWidget);
    expect(find.text('Terminé el Día 2'), findsOneWidget);
  });

  testWidgets('al terminar el último día se completa la rutina y se puede ir a Progreso', (tester) async {
    final service = _FakeService(dayCount: 3, done: 2);
    var opened = false;
    await _pump(tester, _plan(completed: 2), service, onOpenProgress: () => opened = true);

    await tester.tap(find.text('Terminé el Día 3 y la rutina'));
    await tester.pumpAndSettle();

    expect(find.text('¡Completaste tu rutina!'), findsOneWidget);
    expect(find.text('Día 1 — Torso'), findsWidgets);
    await tester.tap(find.text('Ver mi progreso'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    // Siguiente vuelta, otra vez en el Día 1.
    expect(find.text('Terminé el Día 1'), findsOneWidget);
    expect(find.textContaining('Vuelta 2: 0 de 3'), findsOneWidget);
  });

  testWidgets('"Lo marqué por error" deshace el último día', (tester) async {
    final service = _FakeService(dayCount: 3, done: 2);
    await _pump(tester, _plan(completed: 2), service);

    await tester.tap(find.text('Terminé el Día 3 y la rutina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lo marqué por error'));
    await tester.pumpAndSettle();

    expect(service.undone, ['ws-3']);
    expect(find.text('Terminé el Día 3 y la rutina'), findsOneWidget);
  });

  testWidgets('un día normal avisa que quedó en el progreso', (tester) async {
    await _pump(tester, _plan(), _FakeService(dayCount: 3));
    await tester.tap(find.text('Terminé el Día 1'));
    await tester.pump();
    expect(find.textContaining('Quedó en tu progreso'), findsOneWidget);
    expect(find.text('Terminé el Día 2'), findsOneWidget);
  });

  testWidgets('la tarjeta de Progreso resume y lista los entrenamientos', (tester) async {
    WorkoutSession s(int n, {bool closes = false}) => WorkoutSession(
          id: 'ws-$n', planId: 'wp-1', planName: 'Full Body', day: 'Día $n — X',
          dayIndex: n - 1, dayCount: 3, exercises: 5, round: 1, closesRound: closes,
          date: DateTime.now().toIso8601String().substring(0, 10));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: WorkoutHistoryCard(sessions: [s(3, closes: true), s(2), s(1)]),
        ),
      ),
    ));
    expect(find.text('TUS ENTRENAMIENTOS'), findsOneWidget);
    expect(find.text('días hechos'), findsOneWidget);
    expect(find.text('rutina completa'), findsOneWidget);
    expect(find.text('Rutina completa · vuelta 1'), findsOneWidget);
    expect(find.text('Día 1 — X'), findsOneWidget);
  });

  test('estadísticas: semana de lunes a hoy', () {
    WorkoutSession s(String date, {bool closes = false}) => WorkoutSession(
          id: date, planId: 'wp', planName: '', day: '', dayIndex: 0, dayCount: 1,
          exercises: 4, round: 1, closesRound: closes, date: date);
    // Miércoles 18 nov 2026: la semana empieza el lunes 16.
    final stats = WorkoutStats.from(
      [s('2026-11-18', closes: true), s('2026-11-16'), s('2026-11-15')],
      now: DateTime(2026, 11, 18, 20),
    );
    expect(stats.total, 3);
    expect(stats.thisWeek, 2);
    expect(stats.roundsCompleted, 1);
    expect(stats.exercises, 12);
  });
}
