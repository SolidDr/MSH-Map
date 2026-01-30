import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';

/// Kupferfarbe für Radwege
const _kupferColor = Color(0xFFB87333);

class CategoryQuickFilter extends StatefulWidget {
  const CategoryQuickFilter({
    required this.selectedCategories,
    required this.onCategoryToggle,
    super.key,
    this.categoryCounts = const {},
    this.onRadwegeToggle,
    this.radwegeActive = false,
  });

  final Set<String> selectedCategories;
  final ValueChanged<String> onCategoryToggle;
  final Map<String, int> categoryCounts;

  /// Callback wenn Radwege-Filter getoggelt wird
  final VoidCallback? onRadwegeToggle;

  /// Ob Radwege aktuell angezeigt werden
  final bool radwegeActive;

  @override
  State<CategoryQuickFilter> createState() => _CategoryQuickFilterState();
}

class _CategoryQuickFilterState extends State<CategoryQuickFilter> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightFade = true;
  bool _showLeftFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFadeIndicators);
    // Initial check nach dem ersten Frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeIndicators());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFadeIndicators() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final atStart = position.pixels <= 0;
    final atEnd = position.pixels >= position.maxScrollExtent - 10;

    setState(() {
      _showLeftFade = !atStart;
      _showRightFade = !atEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          // Filter-Liste
          ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(left: 12, right: 24),
            children: [
              _CategoryChip(
                label: 'Alle',
                icon: Icons.apps,
                count: widget.categoryCounts.values.fold(0, (a, b) => a + b),
                isSelected: widget.selectedCategories.isEmpty && !widget.radwegeActive,
                onTap: () {
                  // Clear all by toggling all selected categories
                  for (final cat in widget.selectedCategories.toList()) {
                    widget.onCategoryToggle(cat);
                  }
                  // Radwege auch deaktivieren wenn aktiv
                  if (widget.radwegeActive) {
                    widget.onRadwegeToggle?.call();
                  }
                },
              ),
              // Radwege-Chip (speziell, da es Polylines sind)
              if (widget.onRadwegeToggle != null)
                _CategoryChip(
                  label: 'Radwege',
                  icon: Icons.directions_bike,
                  color: _kupferColor,
                  count: 9, // Anzahl der Radwege
                  isSelected: widget.radwegeActive,
                  onTap: widget.onRadwegeToggle!,
                ),
              ..._categories.map(
                (cat) => _CategoryChip(
                  label: cat.label,
                  icon: cat.icon,
                  color: cat.color,
                  count: widget.categoryCounts[cat.id] ?? 0,
                  isSelected: widget.selectedCategories.contains(cat.id),
                  onTap: () => widget.onCategoryToggle(cat.id),
                ),
              ),
            ],
          ),
          // Linker Gradient-Fade (zeigt: mehr links)
          if (_showLeftFade)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        MshColors.background,
                        MshColors.background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Rechter Gradient-Fade (zeigt: mehr rechts)
          if (_showRightFade)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        MshColors.background.withValues(alpha: 0),
                        MshColors.background,
                      ],
                    ),
                  ),
                  // Kleiner Pfeil als visueller Hinweis
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: MshColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static const _categories = [
    (
      id: 'playground',
      label: 'Spielplätze',
      icon: Icons.child_care,
      color: MshColors.categoryPlayground
    ),
    (
      id: 'health',
      label: 'Gesundheit',
      icon: Icons.medical_services,
      color: MshColors.categoryHealth
    ),
    (
      id: 'museum',
      label: 'Museen',
      icon: Icons.museum,
      color: MshColors.categoryMuseum
    ),
    (
      id: 'nature',
      label: 'Natur',
      icon: Icons.park,
      color: MshColors.categoryNature
    ),
    (
      id: 'pool',
      label: 'Baden',
      icon: Icons.pool,
      color: MshColors.categoryPool
    ),
    (
      id: 'castle',
      label: 'Burgen',
      icon: Icons.castle,
      color: MshColors.categoryCastle
    ),
    (id: 'zoo', label: 'Zoo', icon: Icons.pets, color: MshColors.categoryZoo),
    (
      id: 'farm',
      label: 'Bauernhof',
      icon: Icons.agriculture,
      color: MshColors.categoryFarm
    ),
    (
      id: 'restaurant',
      label: 'Essen',
      icon: Icons.restaurant,
      color: MshColors.categoryGastro
    ),
    (
      id: 'civic',
      label: 'Soziales',
      icon: Icons.volunteer_activism,
      color: MshColors.categorySocialFacility
    ),
    (
      id: 'education',
      label: 'Bildung',
      icon: Icons.school,
      color: MshColors.categoryEducation
    ),
  ];
}

class _CategoryChip extends StatelessWidget {

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count, required this.isSelected, required this.onTap, this.color,
  });
  final String label;
  final IconData icon;
  final Color? color;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? chipColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? chipColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : chipColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MshColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : chipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : chipColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
