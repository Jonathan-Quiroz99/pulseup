import 'package:flutter/material.dart';

import '../../../widgets/custom_card.dart';

class ChallengeCard extends StatelessWidget {

  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {

    return CustomCard(

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text("Reto activo 🔥"),

          SizedBox(height: 8),

          Text("10,000 pasos diarios"),

          SizedBox(height: 8),

          LinearProgressIndicator(
            value: 0.6,
          ),
        ],
      ),
    );
  }
}