import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../services/auth_service.dart';

class ChildProfileSelector extends StatelessWidget {
  const ChildProfileSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
    required this.label,
    required this.emptyMessage,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final List<UserProfile> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;
  final String label;
  final String emptyMessage;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && children.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: _decoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AudyColors.skyBlue,
              ),
            ),
            SizedBox(width: 12),
            Text('Loading child profiles…'),
          ],
        ),
      );
    }

    if (errorMessage != null && children.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(16),
        decoration: _decoration(borderColor: AudyColors.error),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AudyColors.error),
            const SizedBox(width: 12),
            Expanded(child: Text(errorMessage!)),
            if (onRetry != null)
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Try again',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
          ],
        ),
      );
    }

    if (children.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _decoration(),
        child: Row(
          children: [
            const Icon(Icons.child_care_rounded, color: AudyColors.textLight),
            const SizedBox(width: 12),
            Expanded(child: Text(emptyMessage)),
          ],
        ),
      );
    }

    final selected = children.firstWhere(
      (child) => child.id == selectedChildId,
      orElse: () => children.first,
    );

    return Semantics(
      button: true,
      label: '$label: ${selected.name}',
      child: PopupMenuButton<String>(
        initialValue: selected.id,
        tooltip: label,
        onSelected: onSelected,
        itemBuilder: (context) {
          return children.map((child) {
            return PopupMenuItem<String>(
              value: child.id,
              height: 56,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AudyColors.blushPink.withValues(
                      alpha: 0.2,
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 20,
                      color: AudyColors.blushPink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (child.id == selected.id)
                    const Icon(Icons.check_rounded, color: AudyColors.success),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: _decoration(borderColor: AudyColors.skyBlue),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AudyColors.blushPink.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.child_care_rounded,
                  size: 22,
                  color: AudyColors.blushPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AudyColors.textLight,
                      ),
                    ),
                    Text(
                      selected.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AudyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AudyColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration({Color borderColor = AudyColors.borderLight}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }
}
