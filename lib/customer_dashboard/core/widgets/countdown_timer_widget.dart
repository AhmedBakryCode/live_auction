import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatter.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? style;
  const CountdownTimerWidget({super.key, required this.endTime, this.style});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late String _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = DateFormatter.timeRemaining(widget.endTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = DateFormatter.timeRemaining(widget.endTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.timerOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.timerOrange),
          const SizedBox(width: 4),
          Text(
            _timeLeft,
            style: widget.style ?? AppTextStyles.caption.copyWith(
              color: AppColors.timerOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
