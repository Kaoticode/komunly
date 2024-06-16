import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> options;

  const CustomBottomSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[700],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(32),
              ),
              height: 40,
              width: 40,
              child: Icon(
                option['icon'],
                color: Colors.white,
              ),
            ),
            title: Text(
              option['title'],
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              option['onPressed'](context);
            },
          );
        }).toList(),
      ),
    );
  }
}
