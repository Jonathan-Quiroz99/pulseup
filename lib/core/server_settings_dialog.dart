import 'package:flutter/material.dart';

import 'api_config.dart';
import 'backend_resolver.dart';

/// Texto corto para mostrar a qué servidor está conectada la app.
String describeServer(String baseUrl) {
  if (baseUrl == ApiConfig.defaultBaseUrl) return 'nube';
  final host = Uri.tryParse(baseUrl)?.host ?? baseUrl;
  if (host == '127.0.0.1' || host == 'localhost') return 'PC por cable USB';
  return 'PC ($host)';
}

/// Chip discreto "Servidor: …" que abre [showServerSettingsDialog].
class ServerStatusButton extends StatefulWidget {
  const ServerStatusButton({super.key});

  @override
  State<ServerStatusButton> createState() => _ServerStatusButtonState();
}

class _ServerStatusButtonState extends State<ServerStatusButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        await showServerSettingsDialog(context);
        if (mounted) setState(() {});
      },
      icon: const Icon(Icons.dns_outlined, size: 16),
      label: Text('Servidor: ${describeServer(ApiConfig.baseUrl)}'),
    );
  }
}

/// Deja volver a buscar el servidor automáticamente o fijar la IP de la PC a
/// mano (por si el escaneo automático no la encuentra).
Future<void> showServerSettingsDialog(BuildContext context) async {
  final manual = await BackendResolver.manualOverride();
  if (!context.mounted) return;
  final controller = TextEditingController(
    text: manual == null ? '' : Uri.tryParse(manual)?.authority ?? manual,
  );

  var busy = false;
  var current = ApiConfig.baseUrl;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> run(Future<String> Function() action) async {
            setDialogState(() {
              busy = true;
              error = null;
            });
            try {
              final url = await action();
              if (!dialogContext.mounted) return;
              setDialogState(() => current = url);
            } on FormatException catch (e) {
              if (!dialogContext.mounted) return;
              setDialogState(() => error = e.message);
            } finally {
              if (dialogContext.mounted) setDialogState(() => busy = false);
            }
          }

          return AlertDialog(
            title: const Text('Servidor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conectado a: ${describeServer(current)}'),
                const SizedBox(height: 4),
                Text(current, style: Theme.of(dialogContext).textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  enabled: !busy,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'IP de la PC (opcional)',
                    hintText: '192.168.137.1',
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error),
                  ),
                ],
                if (busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        controller.clear();
                        run(() => BackendResolver.setManualOverride(null));
                      },
                child: const Text('Buscar automático'),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => run(() =>
                        BackendResolver.setManualOverride(controller.text)),
                child: const Text('Usar esta IP'),
              ),
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    },
  );
  controller.dispose();
}
