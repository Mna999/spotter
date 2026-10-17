import 'package:flutter/material.dart';

class StepContainer extends StatelessWidget {
  bool isActive;
  StepContainer({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isActive ? cs.primary : cs.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
