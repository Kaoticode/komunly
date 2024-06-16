import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';

class Moneda extends StatelessWidget {
  final int number;

  const Moneda({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
        color: primary,
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 2, spreadRadius: 1)
        ],
      ),
      child: Center(
        child: Text(
          number > 100 ? "All In" : number.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
