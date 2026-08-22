import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';

class SellProductStepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const SellProductStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildStep(
            number: 1,
            label: l10n.text('sell_category'),
            stepState: currentStep > 1
                ? _StepState.completed
                : (currentStep == 1 ? _StepState.active : _StepState.upcoming),
          ),
          _buildLine(active: currentStep >= 2),
          _buildStep(
            number: 2,
            label: l10n.text('sell_sub_category'),
            stepState: currentStep > 2
                ? _StepState.completed
                : (currentStep == 2 ? _StepState.active : _StepState.upcoming),
          ),
          _buildLine(active: currentStep >= 3),
          _buildStep(
            number: 3,
            label: l10n.text('sell_details'),
            stepState: currentStep >= 3
                ? (currentStep == 3 ? _StepState.active : _StepState.completed)
                : _StepState.upcoming,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String label,
    required _StepState stepState,
  }) {
    Color circleBg;
    Widget innerContent;
    Color textColor;
    FontWeight textWeight;

    switch (stepState) {
      case _StepState.completed:
        circleBg = const Color(0xFF10B981);
        innerContent = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
        textColor = const Color(0xFF0F172A);
        textWeight = FontWeight.w700;
        break;
      case _StepState.active:
        circleBg = const Color(0xFF1400FF);
        innerContent = Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        );
        textColor = const Color(0xFF1400FF);
        textWeight = FontWeight.w900;
        break;
      case _StepState.upcoming:
        circleBg = const Color(0xFFF1F5F9);
        innerContent = Text(
          '$number',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        );
        textColor = const Color(0xFF94A3B8);
        textWeight = FontWeight.w600;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBg,
            boxShadow: stepState == _StepState.active
                ? [
                    BoxShadow(
                      color: const Color(0xFF1400FF).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: innerContent,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: textWeight,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1400FF) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

enum _StepState {
  completed,
  active,
  upcoming,
}
