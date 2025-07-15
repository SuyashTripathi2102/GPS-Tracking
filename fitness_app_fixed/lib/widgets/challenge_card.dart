import 'package:flutter/material.dart';

enum ChallengeStatus { ready, done, locked }

class ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String reward;
  final ChallengeStatus status;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.status,
    required this.color,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusBg;
    switch (status) {
      case ChallengeStatus.ready:
        statusText = "READY!";
        statusBg = const Color(0xFFFFA726); // Orange
        break;
      case ChallengeStatus.done:
        statusText = "✓ DONE!";
        statusBg = const Color(0xFF66BB6A); // Green
        break;
      case ChallengeStatus.locked:
        statusText = "LOCKED";
        statusBg = const Color(0xFFBDBDBD); // Gray
        break;
    }
    final bool isEnabled = status == ChallengeStatus.ready;
    final Color buttonColor = isEnabled
        ? const Color(0xFF8F5CF7)
        : const Color(0xFFE0E0E0);
    final Color buttonTextColor = isEnabled
        ? Colors.white
        : const Color(0xFF757575);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(icon, color: statusBg, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Reward: 🏆 $reward",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 70,
                child: ElevatedButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    "Start!",
                    style: TextStyle(
                      color: buttonTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
