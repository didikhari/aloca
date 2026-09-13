import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status; // 'Under Budget', 'On Budget', 'Over Budget'

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = status;

    if (status == 'Under Budget') {
      bg = const Color(0xFFE6F4EA);
      fg = const Color(0xFF137333);
    } else if (status == 'On Budget') {
      bg = const Color(0xFFE8F0FE);
      fg = const Color(0xFF1A73E8);
    } else if (status == 'Over Budget') {
      bg = const Color(0xFFFCE8E6);
      fg = const Color(0xFFC5221F);
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
