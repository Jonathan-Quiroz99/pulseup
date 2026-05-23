import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

import '../../widgets/custom_card.dart';

class BillingScreen
    extends StatefulWidget {

  const BillingScreen({
    super.key,
  });

  @override
  State<BillingScreen>
      createState() =>
          _BillingScreenState();
}

class _BillingScreenState
    extends State<BillingScreen> {

  bool _autoPay = true;

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return SingleChildScrollView(

      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          CustomCard(

            gradient:
                const LinearGradient(

              colors: [
                Color(0xFF00FF88),
                Color(0xFF00C853),
              ],
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  'Membresía Premium',

                  style: textTheme
                      .titleLarge
                      ?.copyWith(
                    color: Colors.black,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  'Estado: Activa',
                  style: textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Colors.black,
                  ),
                ),

                Text(
                  'Próximo pago: 15 Mayo',
                  style: textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Colors.black,
                  ),
                ),

                Text(
                  'Saldo pendiente: \$250 MXN',
                  style: textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          CustomCard(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Método de pago',
                  style:
                      textTheme.titleMedium,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                const ListTile(

                  contentPadding:
                      EdgeInsets.zero,

                  leading: Icon(
                    Icons.credit_card,
                  ),

                  title: Text(
                    'VISA **** 4582',
                  ),

                  subtitle: Text(
                    'Expira 12/27',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          CustomCard(

            child: SwitchListTile(

              contentPadding:
                  EdgeInsets.zero,

              value: _autoPay,

              title: const Text(
                'Pago automático',
              ),

              subtitle: const Text(
                'Renovar membresía automáticamente',
              ),

              onChanged: (value) {

                setState(() {
                  _autoPay = value;
                });
              },
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              onPressed: () {},

              child: const Text(
                'Pagar ahora',
              ),
            ),
          ),
        ],
      ),
    );
  }
}