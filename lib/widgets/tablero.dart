import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';

class Tablero extends StatelessWidget {
  final int number;
  final String color;
  final bool isSelected;
  final int betAmount;

  const Tablero({
    super.key,
    required this.number,
    required this.color,
    this.isSelected = false,
    required this.betAmount,
  });

  Color getColorFromString(String colorString) {
    switch (colorString) {
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      case 'red':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width / 7,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : getColorFromString(color),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              number.toString(),
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "$betAmount €",
              style: const TextStyle(
                  fontSize: 14,
                  color: primary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
