import 'package:flutter/material.dart';
import 'package:spotter/features/auth/presentation/widgets/options_card.dart';

class OptionList<T> extends StatelessWidget {
  const OptionList({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(T, String, String?, IconData?)> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OptionCard(
            title: option.$2,
            subtitle: option.$3,
            icon: option.$4,
            isSelected: selected == option.$1,
            onTap: () => onSelected(option.$1),
          ),
        );
      }).toList(),
    );
  }
}
