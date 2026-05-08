import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {

  const StatsRow({super.key});

  Widget stat(
    String title,
    String value,
  ) {

    return Column(
      children: [

        Text(
          value,

          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        SizedBox(height: 4),

        Text(
          title,
          style:
              TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        stat("Peso", "78kg"),

        stat("Grasa", "18%"),

        stat("Días", "12"),
      ],
    );
  }
}