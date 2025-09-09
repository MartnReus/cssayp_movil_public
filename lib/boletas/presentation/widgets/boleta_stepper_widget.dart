import 'package:flutter/material.dart';

class BoletaStepperWidget extends StatelessWidget {
  final int currentStep;
  final String boletaType;
  final List<String> stepLabels;
  final IconData? icon;
  final Color? iconColor;

  const BoletaStepperWidget({
    super.key,
    required this.currentStep,
    required this.boletaType,
    required this.stepLabels,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon ?? Icons.play_circle_outline, color: iconColor ?? const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                boletaType,
                style: const TextStyle(
                  color: Color(0xFF173664),
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: _buildStepRow()),
        ],
      ),
    );
  }

  List<Widget> _buildStepRow() {
    List<Widget> stepWidgets = [];

    for (int i = 0; i < stepLabels.length; i++) {
      final stepNumber = i + 1;
      final isActive = stepNumber == currentStep;
      final isCompleted = stepNumber < currentStep;

      // Agregar indicador del paso
      stepWidgets.add(_buildStepIndicator(stepNumber, isActive, stepLabels[i]));

      // Agregar conector si no es el último paso
      if (i < stepLabels.length - 1) {
        stepWidgets.add(_buildStepConnector(isCompleted));
      }
    }

    return stepWidgets;
  }

  Widget _buildStepIndicator(int step, bool isActive, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF999999),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFF173664) : const Color(0xFF999999),
              fontSize: 11,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
    );
  }
}
