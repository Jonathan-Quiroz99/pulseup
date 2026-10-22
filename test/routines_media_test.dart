import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/routines/exercise_media.dart';
import 'package:pulseup/features/routines/services/routine_schedule.dart';

void main() {
  // Todos los ejercicios de las rutinas predefinidas (backend/workout_templates.py).
  const templateExercises = [
    'Abducción en máquina',
    'Bicicleta abdominal',
    'Bicicleta estatica',
    'Caminadora inclinada',
    'Caminadora o elíptica (calentamiento)',
    'Crunch en polea',
    'Curl con barra',
    'Curl femoral',
    'Curl femoral en máquina',
    'Curl martillo',
    'Dominadas',
    'Dominadas o jalón agarre neutro',
    'Elevaciones de piernas colgado',
    'Elevaciones laterales',
    'Elevación de talones',
    'Elevación de talones sentado',
    'Elíptica',
    'Extensión de cuádriceps',
    'Extensión de tríceps en polea',
    'Face pull',
    'Fondos o press en máquina',
    'Hip thrust',
    'Jalón al pecho',
    'Kettlebell swing',
    'Lagartijas',
    'Lagartijas (rodillas si hace falta)',
    'Mountain climbers',
    'Patada de glúteo en polea',
    'Peso muerto convencional',
    'Peso muerto rumano',
    'Peso muerto rumano con mancuernas',
    'Plancha',
    'Plancha con peso',
    'Prensa',
    'Prensa de piernas',
    'Press de banca',
    'Press de hombro en máquina',
    'Press de pecho con mancuernas',
    'Press de pecho en máquina',
    'Press inclinado con mancuernas',
    'Press militar con barra',
    'Press militar con mancuernas',
    'Remadora',
    'Remo con barra',
    'Remo con mancuerna',
    'Remo en TRX o máquina',
    'Remo en polea baja',
    'Rueda abdominal',
    'Sentadilla búlgara',
    'Sentadilla con barra',
    'Sentadilla con salto suave',
    'Sentadilla goblet',
    'Sentadilla sumo con mancuerna',
    'Step-up al cajon',
    'Superserie: curl + extensión de tríceps',
    'Zancada inversa',
    'Zancadas caminando',
  ];

  test('cada ejercicio de las rutinas tiene imagen y el archivo existe', () {
    for (final name in templateExercises) {
      final asset = ExerciseMedia.assetFor(name);
      expect(asset, isNotNull, reason: name);
      expect(File(asset!).existsSync(), isTrue, reason: '$name -> $asset');
    }
  });

  test('nombres con otros acentos/mayusculas o nuevos usan palabra clave', () {
    expect(ExerciseMedia.assetFor('SENTADILLA GOBLET'), 'assets/exercises/sentadilla-goblet.webp');
    expect(ExerciseMedia.assetFor('Sentadilla frontal'), 'assets/exercises/sentadilla-barra.webp');
    expect(ExerciseMedia.assetFor('Curl de biceps alterno'), 'assets/exercises/curl-barra.webp');
    expect(ExerciseMedia.assetFor('Estiramiento general'), isNull);
  });

  test('dia que toca rota y separa el nombre', () {
    expect(RoutineSchedule.todayIndex(0, 3), 0);
    expect(RoutineSchedule.todayIndex(4, 3), 1);
    expect(RoutineSchedule.todayIndex(5, 0), 0);
    expect(RoutineSchedule.splitDayName('Día 1 — Torso'), ('Día 1', 'Torso'));
    expect(RoutineSchedule.splitDayName('Día A'), ('Día A', ''));
  });
}
