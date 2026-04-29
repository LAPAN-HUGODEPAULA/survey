import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:design_system_flutter/components/admin/ds_task_button.dart';

class DsAdminShell extends StatelessWidget {
  const DsAdminShell({
    super.key,
    required this.navigation,
    required this.child,
    required this.currentSection,
    required this.onNavigateToSection,
    this.userProfile,
    this.recentUpdates,
    this.onRefresh,
    this.headerActions,
  });

  final List<NavigationItem> navigation;
  final Widget child;
  final String currentSection;
  final ValueChanged<String> onNavigateToSection;
  final Widget? userProfile;
  final List<RecentUpdate>? recentUpdates;
  final VoidCallback? onRefresh;
  final List<Widget>? headerActions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 768;

        if (isDesktop) {
          return _buildDesktopLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar Navigation
        Container(
          width: 280,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Logo/Brand
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Survey Builder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: navigation.map((item) {
                    final isSelected = item.key == currentSection;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _buildNavigationItem(
                        context,
                        item,
                        isSelected: isSelected,
                        isDesktop: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // User Profile
              if (userProfile != null) ...[
                const Divider(),
                userProfile!,
              ],
            ],
          ),
        ),
        // Main Content Area
        Expanded(
          child: Column(
            children: [
              // Page Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Breadcrumbs
                    Expanded(
                      child: Row(
                        children: [
                          _buildBreadcrumbItem(
                            context,
                            'Dashboard',
                            currentSection == 'dashboard'
                                ? null
                                : () => _navigateToSection('dashboard'),
                          ),
                          if (currentSection != 'dashboard') ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, size: 16),
                            const SizedBox(width: 8),
                            _buildBreadcrumbItem(
                              context,
                              _sectionLabel(currentSection),
                              null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    if (onRefresh != null)
                      IconButton(
                        tooltip: 'Atualizar',
                        icon: const Icon(Icons.refresh),
                        onPressed: onRefresh,
                      ),
                    if (headerActions != null) ...headerActions!,
                  ],
                ),
              ),
              // Content Area
              Expanded(
                child: child,
              ),
              // Recent Activity Feed
              if (recentUpdates != null && recentUpdates!.isNotEmpty) ...[
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atividade Recente',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentUpdates!.take(5).length,
                          itemBuilder: (context, index) {
                            final update = recentUpdates![index];
                            return Container(
                              width: 250,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    update.title,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    update.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    update.time,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Page Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button (only if not on dashboard)
              if (currentSection != 'dashboard') ...[
                IconButton(
                  tooltip: 'Voltar ao dashboard',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _navigateToSection('dashboard'),
                ),
              ] else ...[
                const SizedBox(width: 48),
              ],
              // Title
              Expanded(
                child: Text(
                  _sectionLabel(currentSection),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Actions
              if (onRefresh != null)
                IconButton(
                  tooltip: 'Atualizar',
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                ),
              if (headerActions != null) ...headerActions!,
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: child,
        ),
        // Bottom Navigation
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: navigation.map((item) {
              final isSelected = item.key == currentSection;
              return Expanded(
                child: _buildNavigationItem(
                  context,
                  item,
                  isSelected: isSelected,
                  isDesktop: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItem item, {
    required bool isSelected,
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);

    if (isDesktop) {
      return DsTaskButton(
        icon: item.icon,
        label: item.label,
        onTap: () => _navigateToSection(item.key),
        emotion: item.emotion,
        size: DsTaskButtonSize.medium,
        showChevron: item.hasChildren,
      );
    } else {
      return InkWell(
        onTap: () => _navigateToSection(item.key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBreadcrumbItem(
      BuildContext context, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onTap != null
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
            ),
      ),
    );
  }

  void _navigateToSection(String sectionKey) {
    onNavigateToSection(sectionKey);
  }

  String _sectionLabel(String key) {
    for (final item in navigation) {
      if (item.key == key) {
        return item.label;
      }
    }
    return 'Dashboard';
  }
}

class NavigationItem {
  const NavigationItem({
    required this.key,
    required this.label,
    required this.icon,
    this.emotion = DsEmotion.neutral,
    this.hasChildren = false,
  });

  final String key;
  final String label;
  final IconData icon;
  final DsEmotion emotion;
  final bool hasChildren;
}

class RecentUpdate {
  const RecentUpdate({
    required this.title,
    required this.description,
    required this.time,
  });

  final String title;
  final String description;
  final String time;
}
