import 'package:flutter/material.dart';
import '../../../app/core/theme/app_colors.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final String? status;

  const OrderTrackingTimeline({super.key, this.status});

  int get currentStep {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'in_transit':
      case 'out_for_delivery':
      case 'shipped':
        return 2;
      case 'delivered':
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Placed', 'Processing', 'In Transit', 'Delivered'];
    final active = currentStep;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < active;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? AppColors.primary : Colors.grey.shade300,
            ),
          );
        } else {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= active;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.grey.shade200,
                  border: Border.all(
                    color: isCompleted ? AppColors.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    size: isCompleted ? 12 : 6,
                    color: isCompleted ? Colors.white : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
