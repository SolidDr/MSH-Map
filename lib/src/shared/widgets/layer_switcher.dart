import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/_module_registry.dart';

class LayerSwitcher extends ConsumerStatefulWidget {

  const LayerSwitcher({super.key, this.onLayerChanged});
  final VoidCallback? onLayerChanged;

  @override
  ConsumerState<LayerSwitcher> createState() => _LayerSwitcherState();
}

class _LayerSwitcherState extends ConsumerState<LayerSwitcher> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final modules = ModuleRegistry.instance.all;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          for (final module in modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ModuleButton(
                module: module,
                isActive: ModuleRegistry.instance.active.contains(module),
                onToggle: () {
                  setState(() {
                    final active =
                        ModuleRegistry.instance.active.contains(module);
                    ModuleRegistry.instance.setActive(module.moduleId, !active);
                  });
                  widget.onLayerChanged?.call();
                },
              ),
            ),
        ],
        FloatingActionButton(
          heroTag: 'layer_switcher_main',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          tooltip: _isExpanded ? 'Ebenen schließen' : 'Ebenen auswählen',
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.layers),
          ),
        ),
      ],
    );
  }
}

class _ModuleButton extends StatelessWidget {

  const _ModuleButton({
    required this.module,
    required this.isActive,
    required this.onToggle,
  });
  final MshModule module;
  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isActive
          ? '${module.displayName} ausblenden'
          : '${module.displayName} anzeigen',
      child: FloatingActionButton.small(
        heroTag: 'module_${module.moduleId}',
        backgroundColor: isActive ? module.primaryColor : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.grey[600],
        onPressed: onToggle,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(module.icon),
            if (isActive)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: module.primaryColor, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
