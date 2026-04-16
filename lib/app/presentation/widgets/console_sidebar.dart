import 'package:flutter/material.dart';
import 'package:waternode/app/presentation/widgets/console_navigation_catalog.dart';

class ConsoleSidebar extends StatelessWidget {
  const ConsoleSidebar({
    super.key,
    required this.activeRoute,
    required this.isExpanded,
    required this.onSelectRoute,
  });

  final String activeRoute;
  final bool isExpanded;
  final ValueChanged<String> onSelectRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isExpanded ? 248 : 76,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.16)),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(isExpanded ? 14 : 10, 12, 10, 12),
        children: [
          _SidebarBrand(isExpanded: isExpanded),
          const SizedBox(height: 18),
          for (final group in ConsoleNavigationCatalog.groups) ...[
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: Text(
                  group.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            for (final item in group.items)
              _SidebarItem(
                item: item,
                isExpanded: isExpanded,
                isActive: item.route == activeRoute,
                onTap: () => onSelectRoute(item.route),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              'W',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.isExpanded,
    required this.isActive,
    required this.onTap,
  });

  final ConsoleNavigationItem item;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final content = Material(
      color: isActive
          ? selectedColor.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 10 : 0,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isActive
                    ? selectedColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isActive ? selectedColor : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        label: item.title,
        button: true,
        selected: isActive,
        child: isExpanded
            ? content
            : Tooltip(message: item.title, child: content),
      ),
    );
  }
}
