/// Imagen ilustrativa de cada ejercicio (`assets/exercises/<slug>.webp`,
/// generadas con Magnific para las rutinas del gimnasio). Se busca por nombre
/// normalizado; si el gimnasio crea un ejercicio con otro nombre, se intenta
/// por palabra clave y si no hay coincidencia se muestra un icono.
class ExerciseMedia {
  ExerciseMedia._();

  static const _byName = <String, String>{
    'abduccion en maquina': 'abduccion-maquina',
    'bicicleta abdominal': 'bicicleta-abdominal',
    'bicicleta estatica': 'bicicleta-estatica',
    'caminadora inclinada': 'caminadora',
    'caminadora o eliptica (calentamiento)': 'caminadora',
    'crunch en polea': 'crunch-polea',
    'curl con barra': 'curl-barra',
    'curl femoral': 'curl-femoral',
    'curl femoral en maquina': 'curl-femoral',
    'curl martillo': 'curl-martillo',
    'dominadas': 'dominadas',
    'dominadas o jalon agarre neutro': 'jalon-pecho',
    'elevacion de talones': 'elevacion-talones',
    'elevacion de talones sentado': 'elevacion-talones',
    'elevaciones de piernas colgado': 'elevaciones-piernas',
    'elevaciones laterales': 'elevaciones-laterales',
    'eliptica': 'eliptica',
    'extension de cuadriceps': 'extension-cuadriceps',
    'extension de triceps en polea': 'extension-triceps-polea',
    'face pull': 'face-pull',
    'fondos o press en maquina': 'press-pecho-maquina',
    'hip thrust': 'hip-thrust',
    'jalon al pecho': 'jalon-pecho',
    'kettlebell swing': 'kettlebell-swing',
    'lagartijas': 'lagartijas',
    'lagartijas (rodillas si hace falta)': 'lagartijas',
    'mountain climbers': 'mountain-climbers',
    'patada de gluteo en polea': 'patada-gluteo-polea',
    'peso muerto convencional': 'peso-muerto',
    'peso muerto rumano': 'peso-muerto-rumano',
    'peso muerto rumano con mancuernas': 'peso-muerto-rumano',
    'plancha': 'plancha',
    'plancha con peso': 'plancha',
    'prensa': 'prensa',
    'prensa de piernas': 'prensa',
    'press de banca': 'press-banca',
    'press de hombro en maquina': 'press-militar-mancuernas',
    'press de pecho con mancuernas': 'press-pecho-mancuernas',
    'press de pecho en maquina': 'press-pecho-maquina',
    'press inclinado con mancuernas': 'press-inclinado-mancuernas',
    'press militar con barra': 'press-militar-barra',
    'press militar con mancuernas': 'press-militar-mancuernas',
    'remadora': 'remadora',
    'remo con barra': 'remo-barra',
    'remo con mancuerna': 'remo-mancuerna',
    'remo en polea baja': 'remo-polea-baja',
    'remo en trx o maquina': 'remo-trx',
    'rueda abdominal': 'rueda-abdominal',
    'sentadilla bulgara': 'sentadilla-bulgara',
    'sentadilla con barra': 'sentadilla-barra',
    'sentadilla con salto suave': 'sentadilla-goblet',
    'sentadilla goblet': 'sentadilla-goblet',
    'sentadilla sumo con mancuerna': 'sentadilla-sumo',
    'step-up al cajon': 'step-up',
    'superserie: curl + extension de triceps': 'curl-barra',
    'zancada inversa': 'zancadas',
    'zancadas caminando': 'zancadas',
  };

  // Orden importa: lo mas especifico primero.
  static const _byKeyword = <(String, String)>[
    ('sentadilla bulgara', 'sentadilla-bulgara'),
    ('sentadilla sumo', 'sentadilla-sumo'),
    ('goblet', 'sentadilla-goblet'),
    ('sentadilla', 'sentadilla-barra'),
    ('peso muerto rumano', 'peso-muerto-rumano'),
    ('peso muerto', 'peso-muerto'),
    ('hip thrust', 'hip-thrust'),
    ('puente', 'hip-thrust'),
    ('zancada', 'zancadas'),
    ('step', 'step-up'),
    ('prensa', 'prensa'),
    ('extension de cuadriceps', 'extension-cuadriceps'),
    ('curl femoral', 'curl-femoral'),
    ('femoral', 'curl-femoral'),
    ('talones', 'elevacion-talones'),
    ('pantorrilla', 'elevacion-talones'),
    ('abduccion', 'abduccion-maquina'),
    ('patada', 'patada-gluteo-polea'),
    ('press inclinado', 'press-inclinado-mancuernas'),
    ('press de banca', 'press-banca'),
    ('press banca', 'press-banca'),
    ('press de pecho con mancuernas', 'press-pecho-mancuernas'),
    ('press de pecho', 'press-pecho-maquina'),
    ('aperturas', 'press-pecho-mancuernas'),
    ('lagartija', 'lagartijas'),
    ('fondos', 'press-pecho-maquina'),
    ('press militar con barra', 'press-militar-barra'),
    ('press militar', 'press-militar-mancuernas'),
    ('press de hombro', 'press-militar-mancuernas'),
    ('elevaciones laterales', 'elevaciones-laterales'),
    ('face pull', 'face-pull'),
    ('dominada', 'dominadas'),
    ('jalon', 'jalon-pecho'),
    ('remo con barra', 'remo-barra'),
    ('remo con mancuerna', 'remo-mancuerna'),
    ('remo en polea', 'remo-polea-baja'),
    ('trx', 'remo-trx'),
    ('remadora', 'remadora'),
    ('remo', 'remo-polea-baja'),
    ('martillo', 'curl-martillo'),
    ('curl', 'curl-barra'),
    ('triceps', 'extension-triceps-polea'),
    ('crunch', 'crunch-polea'),
    ('bicicleta abdominal', 'bicicleta-abdominal'),
    ('rueda', 'rueda-abdominal'),
    ('elevaciones de piernas', 'elevaciones-piernas'),
    ('plancha', 'plancha'),
    ('mountain', 'mountain-climbers'),
    ('escaladores', 'mountain-climbers'),
    ('kettlebell', 'kettlebell-swing'),
    ('caminadora', 'caminadora'),
    ('eliptica', 'eliptica'),
    ('bicicleta', 'bicicleta-estatica'),
    ('spinning', 'bicicleta-estatica'),
  ];

  static String normalize(String s) {
    const from = 'áéíóúüñàèìòù';
    const to = 'aeiouunaeiou';
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().trim().split('')) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString();
  }

  /// Ruta del asset para [exerciseName], o null si no hay imagen.
  static String? assetFor(String exerciseName) {
    final n = normalize(exerciseName);
    final slug = _byName[n] ??
        _byKeyword.where((k) => n.contains(k.$1)).map((k) => k.$2).firstOrNull;
    return slug == null ? null : 'assets/exercises/$slug.webp';
  }
}
