# PulseUp — Rediseño UI/UX "Dark Premium"

**Fecha:** 2026-09-02
**Alcance:** Rediseño visual completo de la app Flutter (sistema de diseño + las ~15 pantallas).
**Fuera de alcance:** Cualquier cambio de lógica, navegación, endpoints o comportamiento.
Es puramente presentación. Los arreglos de bugs de la sesión previa se conservan.

## Dirección

Estética de referencia: Whoop / Gymshark app / Nike Training Club — gimnasio boutique
nocturno. Confiado, atlético, preciso. Tema **solo oscuro** (sin tema claro).

## Tokens

### Color (`lib/core/theme/app_colors.dart` — reescrito)

Contrastes verificados con la fórmula WCAG (revisión Codex). Los pares marcados ✓ pasan
AA (≥4.5:1 texto normal / ≥3:1 texto grande y UI).

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `bg` | `#0C0D10` | Fondo base de toda pantalla | — |
| `surface` | `#15171B` | Tarjetas, inputs | — |
| `surfaceHigh` | `#1D2025` | Tarjeta elevada, bottom sheets, menús | — |
| `hairline` | `#2A2D34` | Divisores decorativos, borde de tarjeta | 1.3:1 (decorativo) |
| `hairlineStrong` | `#363A43` | Borde funcional de input, contorno enabled | 1.9:1 |
| `textPrimary` | `#F3F4F6` | Títulos, valores | 16.5:1 ✓ |
| `textSecondary` | `#9CA0AA` | Labels, cuerpo secundario | 7.4:1 ✓ |
| `textMuted` | `#7E828C` | Metadatos, timestamps (subido de `#63676F`) | 4.7:1 ✓ |
| `accent` | `#FF6A2B` | Fondo de CTA, ítem activo, dato clave, progreso | 6.8:1 s/ `bg` ✓ |
| `accentPressed` | `#E05A1E` | Estado pressed del CTA | — |
| `accentSoft` | `#2A1B12` | Relleno tenue detrás de iconos/badges de acento | — |
| `onAccent` | `#0B0B0D` | **Texto/icono sobre `accent` (casi negro, NO blanco)** | 6.3:1 ✓ |
| `success` / `onSuccess` | `#3FD07E` / `#0B0B0D` | Estado "Activo" | 9.8:1 ✓ |
| `warning` / `onWarning` | `#F5B841` / `#0B0B0D` | Estado "Pendiente" | 10.9:1 ✓ |
| `error` / `onError` | `#FF5C5C` / `#0B0B0D` | Errores, estado "Vencido" | 6.4:1 ✓ |
| `successSoft` / `warningSoft` / `errorSoft` | `#12241A` / `#2A2312` / `#2A1516` | Fondo de badge/alerta semántica | — |
| `onLight` | `#111317` | Texto sobre la tarjeta clara del QR | — |

Regla dura: **blanco puro nunca va sobre `accent` ni sobre colores semánticos** (reprueba
WCAG); siempre `onAccent` / `onSuccess` / etc. El acento como *texto* sí puede ir sobre
`bg`/`surface` (6.8:1).

Elevación = subir el color de superficie + hairline superior. **Se eliminan casi todas las
`BoxShadow`**; se permite una sombra ambiental suave solo en nav flotante, FAB y sheets.

### Tipografía (`lib/core/theme/app_text_styles.dart` — ampliado)

Se conservan las familias: **Plus Jakarta Sans** (display/títulos) + **Inter** (cuerpo/datos).

| Estilo | Familia / tamaño / peso | Uso |
|---|---|---|
| `displayLg` | Jakarta 30 / w800 / -0.5 | Saludo dashboard, marca |
| `displayMd` | Jakarta 24 / w800 / -0.3 | Títulos de pantalla |
| `titleLg` | Jakarta 19 / w700 | Títulos de tarjeta |
| `titleMd` | Jakarta 16 / w700 | Subtítulos, botones |
| `body` | Inter 15 / w400 / 1.45 lh | Cuerpo |
| `bodySm` | Inter 13 / w400 | Cuerpo secundario |
| `label` | Inter 12 / w600 / +0.2 | Labels de campos, chips, captions |
| `stat` | Jakarta 26 / w800 / -0.5 / tabular | Valores numéricos grandes (kg, %, conteos) |
| `statSm` | Jakarta 17 / w700 / tabular | Valores numéricos en línea |

### Espaciado y forma (`lib/core/theme/app_spacing.dart` — ajustado)

- Espaciado: `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 40`.
- Padding de pantalla: `20` horizontal. Padding de tarjeta: `16`.
- Radios: `radiusSm 12` (controles/chips) · `radiusMd 16` (tarjetas) · `radiusLg 20`
  (sheets) · pill (`999`) solo para avatares y selector activo del nav.
- Alturas: botón `52`, input `54`.

## Componentes base (nuevos, en `lib/widgets/ui/`)

Cada uno con una sola responsabilidad, sin estado de negocio. Estados obligatorios en
cada control interactivo: `enabled`, `disabled`, `pressed`, `focused`, `loading`.

1. **`AppButton`** — **envuelve** `FilledButton` / `OutlinedButton` / `TextButton` de
   Material (una sola fuente de verdad, hereda de `ThemeData`), no reimplementa estados.
   Variantes `primary` (fondo `accent`, texto `onAccent`), `secondary` (`surface` +
   `hairlineStrong`), `ghost` (texto `accent`). Props: `loading` (spinner + deshabilita),
   `expanded`, `icon` opcional. Altura 52, radio `sm`.
2. **`AppCard`** — `surface`, borde `hairline` 1px, radio `md`, padding configurable
   (default `16`). Prop `elevated` (usa `surfaceHigh`). `onTap` opcional implementado con
   `Material(type: transparency)` + `InkWell(borderRadius:)` + `clipBehavior` para que el
   splash respete el radio.
3. **`AppTextField`** — envuelve `TextFormField`. API: `controller`, `label`, `hint`,
   `keyboardType`, `obscureText` (+ toggle de visibilidad integrado), `readOnly`,
   `enabled`, `maxLines`, `prefixIcon`, `suffixIcon`, `helperText`, `validator`, `onTap`,
   `autofillHints`. Relleno `surface`, borde `hairlineStrong` → `accent` en foco →
   `error` en error. Label en estilo `label`.
4. **`AppChip`** — **solo selección interactiva** (filtros, selectores tipo tab). Inactivo
   `surface`+`hairline`; activo `accent` con texto/icono `onAccent`.
5. **`StatusBadge`** — **no interactivo**. Pill con punto + texto para estados de
   membresía/pago/check-in. Mapea `Activo→success`, `Pendiente→warning`,
   `Vencido/Suspendido→error`, otro→neutro (`surfaceHigh`+`textSecondary`). Fondo
   `*Soft`, texto del color pleno.
6. **`StatTile`** — icono opcional + valor (`stat`) + label (`label`). Un widget para
   dashboard, tracking, check-in. Prop `accentValue` para resaltar. Maneja valor nulo → `--`.
7. **`SectionHeader`** — título (`titleMd`) + acción opcional a la derecha (botón `ghost`).
8. **`AppScaffold`** — **shell de contenido, no un `Scaffold` real**: las pantallas de
   `HomeScreen` se inyectan en su `Scaffold`. Da fondo `bg`, `SafeArea` (configurable
   `top`/`bottom` — las de HomeScreen ya tienen AppBar y nav, así que `top:false`), padding
   de pantalla y slot de título opcional. Login/Registro sí usan `Scaffold` propio + este
   shell dentro. Contrato: el consumidor decide `resizeToAvoidBottomInset`; el shell no
   scrollea (lo hace la pantalla).
9. **`EmptyState`** — icono en círculo `accentSoft` + título + texto + acción opcional.
   Cada pantalla pasa su copy propio (tienda/ historial / tracking / rutinas / cuenta).
10. **`AppBottomSheet`** — `surfaceHigh`, handle, radio `lg` arriba. Para el sheet de
    medición y diálogos deslizables.
11. **`AppDialog`** — wrapper de `AlertDialog` con tema oscuro (usado hoy en borrar
    medición, editar altura, "ya pagué"). Título `titleMd`, acciones con `AppButton`.
12. **`WeightSparkline`** — `CustomPainter`, sin dependencia. Estados: 0 puntos → oculto;
    1 punto → punto solo + valor; ≥2 → línea. Etiqueta textual accesible (`Semantics`).

`lib/widgets/app_nav_bar.dart` se refina (no se reescribe): fondo `#111317`, hairline,
píldora de `accent` (texto `onAccent`) detrás del icono activo, tamaños ajustados.

## Theme (`lib/core/theme/app_theme.dart` — reescrito)

`ThemeData(useMaterial3: true, brightness: Brightness.dark)` con **`ColorScheme.dark`
mapeado por completo** (no solo primary/surface): `primary`=accent, `onPrimary`=onAccent,
`secondary`/`onSecondary`, `surface`, `onSurface`, `surfaceContainerLow/Highest`,
`outline`=hairlineStrong, `outlineVariant`=hairline, `error`/`onError`. Sin esto los
widgets M3 heredan morado por defecto.

**Fijar `surfaceTintColor: Colors.transparent`** explícitamente en `cardTheme`,
`bottomSheetTheme`, `dialogTheme`, `appBarTheme`, `navigationBarTheme`, `menuTheme` — M3
tinta las superficies por elevación y corrompería los tokens.

Temas de componente alineados a los tokens: `filledButtonTheme`, `outlinedButtonTheme`,
`textButtonTheme`, `cardTheme`, `inputDecorationTheme`, `appBarTheme`, `chipTheme`,
`snackBarTheme`, `bottomSheetTheme`, `dialogTheme`, `dividerTheme`,
`progressIndicatorTheme`, `radioTheme`, `switchTheme`. Se quita `screenGradient`.

## Trabajo por pantalla

Se re-maqueta cada pantalla para jerarquía y consistencia usando los componentes base.
Sin tocar lógica.

| Pantalla | Cambios clave |
|---|---|
| **Login** | Lockup de marca grande y centrado; inputs `AppTextField`; solo el CTA "Iniciar sesión" lleva acento; botón Google `secondary`; más aire. |
| **Registro (paso 1 y 2)** | Indicador de paso (1/2); campos `AppTextField`; planes como tarjetas seleccionables (`AppChip`/radio con estilo); método de pago claro. |
| **Dashboard** | Header: saludo (`displayLg`) + chip de estado de membresía. Tarjeta "Entreno de hoy" como protagonista, borde/realce de acento. Fila de 3 `StatTile`. Acciones rápidas en fila de 4 iconos limpia. "Últimos 7 días" con mini-barras. |
| **Rutinas** | `AppCard` por plan; ejercicios con series/reps/descanso en pills de dato (`label` sobre `surfaceHigh`). |
| **Tracking** | Grid 2×2 de `StatTile` (peso, grasa, músculo, cintura) + fila de IMC. Sparkline simple de peso (CustomPainter, sin dependencia). Lista de historial con `AppCard`. Sheet de medición re-estilizado oscuro (`AppBottomSheet`, `AppTextField`, `AppButton`). |
| **Tienda** | Filtros con `AppChip`; filas de producto refinadas (ya tienen tinte por categoría); `CartBar` sobre `surfaceHigh` con hairline; checkout con `AppButton`. |
| **Check-in** | El QR es el héroe: tarjeta **clara** (`#FFFFFF`, el QR necesita fondo claro) centrada y enmarcada dentro de la pantalla oscura, con el nombre y el id debajo. Estado de membresía con color semántico. Historial con `AppCard`. Estado de error de credencial ya existente, re-estilizado. |
| **Estado de cuenta** | Tarjeta de membresía con realce de acento; badge de estado semántico (`success`/`warning`/`error`); historial de pagos en filas `AppCard`; CTA "Pagar en línea" `primary`. |
| **Drawer** | `surfaceHigh`, header de perfil con avatar, ítems agrupados con divisores hairline, "Cerrar sesión" en `error`. |
| **Loading states** | `dashboard_loading` y spinners centrados usan `progressIndicatorTheme` (acento). |

## Motion

Transiciones de 160–200ms `easeOut` en: cambio de tab del nav, press de botones, selección
de chip. Sin animación gratuita.

## Plan de ejecución (reordenado según revisión Codex)

Migrar todas las pantallas después de *todos* los componentes esconde requisitos. En vez
de eso, una pantalla piloto valida las APIs antes de producir el resto.

1. **Fase 1 — Fundación:** `app_colors.dart` + `app_text_styles.dart` + `app_spacing.dart`
   + `app_theme.dart` (ColorScheme completo, `surfaceTintColor` transparente). La app
   compila y se ve oscura heredando del theme.
2. **Fase 2 — Componentes núcleo:** `AppButton`, `AppTextField`, `AppCard`, `StatusBadge`,
   `SectionHeader`, `AppScaffold`.
3. **Fase 3 — Pantalla piloto:** **Dashboard** de acabado final. Aquí se ajustan las APIs
   de los componentes con casos reales antes de seguir.
4. **Fase 4 — Resto de componentes:** `AppChip`, `StatTile`, `EmptyState`, `AppBottomSheet`,
   `AppDialog`, `WeightSparkline`, refinar `app_nav_bar`.
5. **Fase 5 — Resto de pantallas:** Login/Registro → Tracking → Rutinas → Tienda →
   Check-in → Estado de cuenta → Drawer → loading states.

**Verificación tras cada fase:** `flutter analyze` limpio + smoke test verde. Al cerrar
Fase 3 y Fase 5: revisión visual manual (capturas) en pantalla chica, con
`MediaQuery.textScaler` a 1.3, y de los estados loading/error/empty de cada flujo.
Revisión de Gemma + Codex sobre el diff de cada fase de pantallas.

## Riesgos

- **Contraste del acento:** blanco sobre `#FF6A2B` reprueba WCAG (2.86:1). Mitigado con
  `onAccent` casi negro (6.3:1). Regla dura en el código.
- **QR sobre fondo oscuro:** los lectores necesitan alto contraste → la tarjeta del QR se
  mantiene clara a propósito; texto dentro de ella usa `onLight`.
- **`surfaceTintColor` de M3:** corrompe tokens si no se fija en transparente. Cubierto en Theme.
- **`AppScaffold` vs `Scaffold` real:** contrato explícito (punto 8) para no duplicar
  SafeArea/padding — las pantallas de HomeScreen no tienen Scaffold propio.
- **`google_fonts` en runtime:** ya en uso; sin cambio de riesgo.
- **Working tree con cambios sin commitear de otra sesión:** no se hará commit sin permiso.
- **Volumen:** ~45 archivos. Por fases con verificación entre cada una.
