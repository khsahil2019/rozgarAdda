import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../floating_navbar.dart';
import '../../../../localization/app_localizations.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
}

class SellProductReviewScreen extends StatelessWidget {
  const SellProductReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const _TopBar(),
              const SizedBox(height: 24),
              const _StepIndicator(currentStep: 4),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.borderColor),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: _C.primaryBlue,
                      size: 56,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.text('sell_review_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _C.darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.text('sell_review_desc'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _C.greyText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Get.offAll(() => const FloatingNavbarScreen());
                  },
                  child: Text(
                    context.l10n.text('sell_go_dashboard'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.offAll(() => const FloatingNavbarScreen());
            },
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Text(
              context.l10n.text('sell_post_ad'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.offAll(() => const FloatingNavbarScreen());
            },
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isReviewStep = currentStep >= 4;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          _StepCircle(number: 1, label: context.l10n.text('sell_category'), state: _StepState.done),
          const _StepLine(active: true),
          _StepCircle(number: 2, label: 'Sub-Cat', state: _StepState.done),
          const _StepLine(active: true),
          _StepCircle(
            number: 3,
            label: context.l10n.text('sell_details'),
            state: isReviewStep ? _StepState.done : _StepState.active,
          ),
          _StepLine(active: isReviewStep),
          _StepCircle(
            number: 4,
            label: context.l10n.text('sell_review'),
            state: isReviewStep ? _StepState.active : _StepState.inactive,
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, inactive }

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final _StepState state;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = state == _StepState.done;
    final bool isActive = state == _StepState.active;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive) ? _C.primaryBlue : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.greyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDone || isActive) ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: (isDone || isActive) ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? _C.primaryBlue : const Color(0xFFDDDDEE),
      ),
    );
  }
}
