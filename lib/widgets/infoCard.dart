import 'package:flutter/material.dart';
import 'package:komunly/functions/functions.dart';

class InfoCard extends StatelessWidget {
  final String username;
  final String createdAt;
  final String description;
  final String bankNumber;
  const InfoCard({super.key, required this.username, required this.createdAt, required this.description, required this.bankNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile(Icons.person, 'Username', username),
            _buildInfoTile(Icons.person, 'Biography', description),
            _buildInfoTile(Icons.account_balance, 'Bank Number', bankNumber),
            _buildInfoTile(Icons.calendar_today, 'Registration Date', formatRelativeTime(createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              icon,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
