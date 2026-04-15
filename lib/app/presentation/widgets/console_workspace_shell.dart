import 'package:flutter/material.dart';
import 'package:waternode/app/presentation/widgets/console_navigation_catalog.dart';

class ConsoleWorkspaceShell extends StatelessWidget {
  const ConsoleWorkspaceShell({
    super.key,
    required this.isWideLayout,
    required this.activeItem,
    required this.isSidebarExpanded,
    required this.onToggleSidebar,
    required this.child,
  });

  final bool isWideLayout;
  final ConsoleNavigationItem activeItem;
  final bool isSidebarExpanded;
  final VoidCallback onToggleSidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      key: const Key('workspace-shell'),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.035),
          theme.scaffoldBackgroundColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (buttonContext) => IconButton(
                      key: Key(isWideLayout ? 'toggle-sidebar' : 'open-drawer'),
                      onPressed: isWideLayout
                          ? onToggleSidebar
                          : Scaffold.of(buttonContext).openDrawer,
                      tooltip: isWideLayout && isSidebarExpanded
                          ? '收起导航'
                          : '展开导航',
                      icon: Icon(
                        isWideLayout && isSidebarExpanded
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeItem.headerTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          activeItem.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      activeItem.groupTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
