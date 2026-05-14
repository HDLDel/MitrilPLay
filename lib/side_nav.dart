import 'package:flutter/material.dart';
import 'package:mitril_play/models/view_type.dart';
import 'package:mitril_play/settings_view.dart';
import 'package:mitril_play/theme.dart';

class SideNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool blockSettings;
  final VoidCallback? onSearchTapped;
  final bool searchMode;
  const SideNav({
    super.key,
    required this.updateViewMode,
    this.startingView = ViewType.all,
    this.blockSettings = false,
    this.onSearchTapped,
    this.searchMode = false,
  });

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.startingView.index;
    });
  }

  void onRailTapped(int index) {
    if (widget.blockSettings && index == ViewType.settings.index) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Settings disabled while refreshing on start")));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == ViewType.settings.index) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SettingsView(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
        (route) => false,
      );
      return;
    }
    widget.updateViewMode(ViewType.values[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: NavigationRail(
        leading: widget.onSearchTapped != null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: widget.onSearchTapped,
                  tooltip: 'Search',
                  backgroundColor: widget.searchMode
                      ? AppColors.primary
                      : AppColors.surfaceContainerHighest,
                  foregroundColor: widget.searchMode
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                  child: const Icon(Icons.search),
                ),
              )
            : null,
        backgroundColor: AppColors.cardBackground,
        selectedIndex: _selectedIndex,
        onDestinationSelected: onRailTapped,
        labelType: NavigationRailLabelType.all,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorColor: AppColors.primaryContainer,
        destinations: <NavigationRailDestination>[
          NavigationRailDestination(
            icon: Icon(Icons.list, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.list, color: AppColors.primary),
            label: const Text('All'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.dashboard, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: const Text('Categories'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.star, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.star, color: AppColors.primary),
            label: const Text('Favorites'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.history, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: const Text("History"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
