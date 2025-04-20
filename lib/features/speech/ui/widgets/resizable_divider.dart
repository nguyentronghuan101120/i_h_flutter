import 'package:flutter/material.dart';

class ResizableDivider extends StatelessWidget {
  final Function(double) onDrag;
  final Color? color;
  final double height;

  const ResizableDivider({
    super.key,
    required this.onDrag,
    this.color,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        onDrag(details.delta.dy);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).dividerColor.withAlpha(100),
          ),
          child: Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withAlpha(300),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
