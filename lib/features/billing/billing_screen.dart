import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {

  bool autoPay = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 💳 Membresía
            CustomCard(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00FF88),
                  Color(0xFF00C853),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Membresía Premium",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Estado: Activa",
                    style: TextStyle(color: Colors.black),
                  ),

                  Text(
                    "Próximo pago: 15 Mayo",
                    style: TextStyle(color: Colors.black),
                  ),

                  Text(
                    "Saldo pendiente: \$250 MXN",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 💰 Método de pago
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Método de pago",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.credit_card),
                    title: Text("VISA **** 4582"),
                    subtitle: Text("Expira 12/27"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 🔄 Pago automático
            CustomCard(
              child: SwitchListTile(
                value: autoPay,

                activeColor: Colors.greenAccent,

                title: Text("Pago automático"),

                subtitle: Text(
                  "Renovar membresía automáticamente",
                ),

                onChanged: (value) {
                  setState(() {
                    autoPay = value;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            // 💵 Botón pagar
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),

                onPressed: () {},

                child: Text(
                  "Pagar ahora",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
}