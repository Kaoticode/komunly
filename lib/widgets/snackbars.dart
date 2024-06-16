import 'package:flutter/material.dart';

void showSnackMessage(BuildContext context, String text, String type) {
  IconData iconData;
  Color background;

  if (type == "SUCCESS") {
    iconData = Icons.check_circle;
    background = Colors.green;
  } else if (type == "ERROR") {
    iconData = Icons.error_outline;
    background = Colors.red;
  } else {
    iconData = Icons.warning;
    background = Colors.orange;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type, // Aquí mostramos el tipo (SUCCESS, ERROR, WARNING)
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: background,
      elevation: 3,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
