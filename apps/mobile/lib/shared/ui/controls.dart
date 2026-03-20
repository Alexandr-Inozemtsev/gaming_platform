// Назначение файла: совместимость старых вызовов controls с новым UI Kit.

import 'package:flutter/material.dart';

import 'ui_kit.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({super.key, required this.onPressed, required this.label});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => AppButton(label: label, onPressed: onPressed, variant: AppButtonVariant.primary);
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({super.key, required this.onPressed, required this.label});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => AppButton(label: label, onPressed: onPressed, variant: AppButtonVariant.secondary);
}

class AppGhostButton extends StatelessWidget {
  const AppGhostButton({super.key, required this.onPressed, required this.label});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => AppButton(label: label, onPressed: onPressed, variant: AppButtonVariant.ghost);
}

class AppTextInput extends StatelessWidget {
  const AppTextInput({super.key, required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class AppPanelCard extends StatelessWidget {
  const AppPanelCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppPanel(child: child);
}

class AppChoiceTab extends StatelessWidget {
  const AppChoiceTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => AppChip(label: label, selected: selected, onTap: onSelected);
}
