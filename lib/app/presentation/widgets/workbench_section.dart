import 'package:flutter/material.dart';

class WorkbenchSection extends StatelessWidget {
  const WorkbenchSection({
    super.key,
    required this.title,
    this.trailing,
    this.expandChild = false,
    required this.child,
  });

  final String title;
  final Widget? trailing;
  final bool expandChild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (trailing != null) ...<Widget>[trailing!],
            ],
          ),
          const SizedBox(height: 10),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
