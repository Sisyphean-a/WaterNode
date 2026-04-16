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

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                children: [
                  if (isWideLayout)
                    IconButton(
                      icon: Icon(
                        isSidebarExpanded 
                            ? Icons.menu_open_rounded 
                            : Icons.menu_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onToggleSidebar,
                      tooltip: 'Nav',
                    ),
                  if (isWideLayout) const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeItem.headerTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeItem.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
