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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[trailing!],
            ],
          ),
          const SizedBox(height: 20),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
