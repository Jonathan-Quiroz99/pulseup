import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {

  final TextEditingController weightController =
      TextEditingController();

  List<double> weights = [];

  void addWeight() {

    if (weightController.text.isEmpty) return;

    setState(() {

      weights.add(
        double.parse(weightController.text),
      );

      weightController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      padding: EdgeInsets.all(16),

      child: Column(
        children: [

          // 📝 Input peso
          CustomCard(
            child: Column(
              children: [

                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(
                    hintText: "Ingresa tu peso",
                    border: InputBorder.none,
                  ),
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: addWeight,
                  child: Text("Guardar"),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // 📊 Lista de pesos
          ListView.builder(

            shrinkWrap: true,

            physics:
                NeverScrollableScrollPhysics(),

            itemCount: weights.length,

            itemBuilder: (_, i) {

              return CustomCard(
                child: Text(
                  "Peso: ${weights[i]} kg",
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}