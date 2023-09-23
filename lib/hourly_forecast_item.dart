import 'package:flutter/material.dart';

class HourlyForeCastItem extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;
  const HourlyForeCastItem(
      {super.key,
      required this.time,
      required this.temperature,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Icon(
            icon,
            size: 32,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            temperature,
          ),
        ]),
      ),
    );
  }
}
