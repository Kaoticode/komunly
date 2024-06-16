import 'package:flutter/material.dart';
import 'package:komunly/functions/functions.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    Key? key,
    required this.transaction,
    required this.myUserId,
    this.additionalText = "",
  }) : super(key: key);

  final transaction;
  final String myUserId;
  final String additionalText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            checkUsername(
              transaction["transactionType"],
              transaction["sender"]?["username"] ?? "Komunly",
              transaction["sender"]?["_id"] ?? "0",
              transaction["receiver"]?["username"] ?? "No disponible",
              myUserId,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (transaction["concept"].isNotEmpty)
            Text(
              transaction["concept"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
        ],
      ),
      subtitle: Text(
        formatRelativeTime(transaction["createdAt"]),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${transaction["amount"]} €",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checkTransference(transaction["transactionType"],
                      transaction["sender"]["_id"], myUserId)
                  ? Colors.green[100]
                  : Colors.red[100],
            ),
            child: Center(
              child: Transform.rotate(
                angle: checkTransference(transaction["transactionType"],
                        transaction["sender"]["_id"], myUserId)
                    ? 135 * 3.1415926535 / 180
                    : 0,
                child: Icon(
                  checkTransference(transaction["transactionType"],
                          transaction["sender"]["_id"], myUserId)
                      ? Icons.arrow_forward
                      : Icons.arrow_outward,
                  color: checkTransference(transaction["transactionType"],
                          transaction["sender"]["_id"], myUserId)
                      ? Colors.green
                      : Colors.red,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
