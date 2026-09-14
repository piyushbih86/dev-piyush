import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/diet_filter.dart';

class DietFilterChips extends StatelessWidget {
  const DietFilterChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DietFilter value;
  final ValueChanged<DietFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _chip(DietFilter.all, StringConstants.filterAll, Icons.restaurant),
          const SizedBox(width: 8),
          _chip(DietFilter.veg, StringConstants.veg, Icons.eco_outlined),
          const SizedBox(width: 8),
          _chip(
            DietFilter.nonVeg,
            StringConstants.nonVeg,
            Icons.kebab_dining_outlined,
          ),
        ],
      ),
    );
  }

  Widget _chip(DietFilter filter, String label, IconData icon) {
    final selected = value == filter;
    final accent = filter == DietFilter.veg
        ? ColorConstants.veg
        : filter == DietFilter.nonVeg
            ? ColorConstants.nonVeg
            : ColorConstants.accent;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.16) : ColorConstants.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accent : ColorConstants.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? accent : ColorConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? accent : ColorConstants.textSecondary,
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
