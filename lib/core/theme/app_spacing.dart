class AppSpacing {
  AppSpacing._();

  // Spacing scale (4pt grid)
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 40.0;

  // Screen + card padding
  static const screenX = 20.0;
  static const cardPadding = 16.0;

  // Radius — contained, not bubbly
  static const radiusSm = 12.0; // controls, chips, buttons
  static const radiusMd = 16.0; // cards
  static const radiusLg = 20.0; // bottom sheets, large containers
  static const radiusXl = 24.0; // hero cards (QR)
  static const radiusPill = 999.0; // avatars, active nav indicator

  // Heights
  static const buttonHeight = 52.0;
  static const inputHeight = 54.0;

  /// Espacio inferior que debe dejar el contenido con scroll dentro de
  /// `HomeScreen` para no quedar tapado por la barra de navegación flotante.
  /// Cubre: safe-area inferior del sistema (~48) + margen del pill (12) +
  /// alto del pill (64) + aire (16). Es un valor fijo a propósito: en varios
  /// dispositivos `MediaQuery` reporta 0 aquí por el `extendBody: true`.
  static const navBarClearance = 140.0;
}
