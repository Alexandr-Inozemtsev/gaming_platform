// Назначение файла: предоставить reusable production-ready UI Kit для landscape-first интерфейса.
// Роль в проекте: централизовать базовые, навигационные и gameplay-компоненты для iOS/Android.
// Основные функции: кнопки, чипы, панели, баннеры статуса, HUD, карточки и контейнеры состояния.
// Связи с другими файлами: используется экранами Home/Catalog/Room и опирается на theme/tokens.dart.
// Важно при изменении: поддерживать типизацию, states и touch-target не ниже 44dp.

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum AppButtonVariant { primary, secondary, ghost }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final minHeight = switch (size) {
      AppButtonSize.sm => 44.0,
      AppButtonSize.md => 48.0,
      AppButtonSize.lg => 52.0,
    };
    final child = loading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: AppSpacing.xs)],
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.secondary => OutlinedButton(onPressed: enabled ? onPressed : null, child: child),
      AppButtonVariant.ghost => TextButton(onPressed: enabled ? onPressed : null, child: child),
      AppButtonVariant.primary => FilledButton(onPressed: enabled ? onPressed : null, child: child),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: fullWidth ? double.infinity : 44),
      child: Opacity(opacity: enabled ? 1 : AppOpacity.disabled, child: button),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accentPrimarySoft,
      labelStyle: TextStyle(color: selected ? AppColors.accentPrimary : AppColors.textSecondary),
      side: const BorderSide(color: AppColors.strokeDefault),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.color = AppColors.info});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: AppTypography.label.copyWith(color: color)),
    );
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.md)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.strokeSoft),
        boxShadow: AppElevation.level1,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(children: [Expanded(child: Text(title, style: AppTypography.h3)), if (trailing != null) trailing!]),
    );
  }
}

class FeaturedGameBanner extends StatelessWidget {
  const FeaturedGameBanner({super.key, required this.title, required this.subtitle, this.cta});
  final String title;
  final String subtitle;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.bgElevated2, AppColors.accentPrimarySoft]),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.strokeDefault),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: AppTypography.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          if (cta != null) cta!,
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.title,
    required this.description,
    this.badge,
    this.onPlay,
  });
  final String title;
  final String description;
  final String? badge;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(title, style: AppTypography.h3)), if (badge != null) AppBadge(label: badge!)]),
        const SizedBox(height: AppSpacing.xs),
        Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySm),
        const SizedBox(height: AppSpacing.sm),
        AppButton(label: 'Играть', onPressed: onPlay, icon: Icons.play_arrow_rounded),
      ]),
    );
  }
}

class TurnIndicator extends StatelessWidget {
  const TurnIndicator({super.key, required this.myTurn});
  final bool myTurn;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.easeEmphasized,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: myTurn ? AppColors.turnActive.withOpacity(0.18) : AppColors.turnOpponent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: myTurn ? AppColors.turnActive : AppColors.turnOpponent),
        boxShadow: myTurn ? AppElevation.glowPrimary : const [],
      ),
      child: Text(myTurn ? 'Ваш ход' : 'Ход соперника', style: AppTypography.label),
    );
  }
}

class TimerIndicator extends StatelessWidget {
  const TimerIndicator({super.key, required this.seconds, this.urgent = false});
  final int seconds;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: urgent ? 1.03 : 1),
      duration: urgent ? AppMotion.fast : AppMotion.base,
      curve: AppMotion.easeStandard,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: AppBadge(label: '${seconds}s', color: urgent ? AppColors.warning : AppColors.info),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      child: visible
          ? Container(
              key: const ValueKey('offline-banner'),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              color: AppColors.warning.withOpacity(0.15),
              child: Row(children: const [
                Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 16),
                SizedBox(width: AppSpacing.xs),
                Expanded(child: Text('Нет соединения. Работаем в режиме восстановления.', style: AppTypography.bodySm)),
              ]),
            )
          : const SizedBox.shrink(),
    );
  }
}

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, required this.name, this.online = true});
  final String name;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.bgElevated2, child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: online ? AppColors.success : AppColors.textMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bgBase),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerSlot extends StatelessWidget {
  const PlayerSlot({super.key, required this.name, required this.ready, this.host = false});
  final String name;
  final bool ready;
  final bool host;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          PlayerAvatar(name: name, online: true),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(name, style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis)),
          if (host) const AppBadge(label: 'HOST', color: AppColors.info),
          const SizedBox(width: AppSpacing.xs),
          AppBadge(label: ready ? 'Ready' : 'Waiting', color: ready ? AppColors.success : AppColors.warning),
        ],
      ),
    );
  }
}

class InviteCodeBadge extends StatelessWidget {
  const InviteCodeBadge({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) => AppBadge(label: 'INVITE: $code', color: AppColors.accentSecondary);
}

class ScorePanel extends StatelessWidget {
  const ScorePanel({super.key, required this.items});
  final Map<String, int> items;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: items.entries
            .map((entry) => Column(mainAxisSize: MainAxisSize.min, children: [Text(entry.key, style: AppTypography.caption), Text('${entry.value}', style: AppTypography.h3)]))
            .toList(),
      ),
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.actions});
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [for (final action in actions) ...[action, const SizedBox(width: AppSpacing.xs)]]),
      ),
    );
  }
}

class HandTray extends StatelessWidget {
  const HandTray({super.key, required this.items, required this.selectedIndex, required this.onSelect});
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: AppMotion.base,
              width: 70,
              decoration: BoxDecoration(
                color: selected ? AppColors.accentPrimarySoft : AppColors.bgElevated2,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: selected ? AppColors.accentPrimary : AppColors.strokeSoft),
              ),
              alignment: Alignment.center,
              child: Text(items[index], style: AppTypography.label),
            ),
          );
        },
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.title, this.subtitle, this.trailing, this.onTap, this.destructive = false});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(color: destructive ? AppColors.error : AppColors.textPrimary)),
                  if (subtitle != null) Text(subtitle!, style: AppTypography.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


class BreadcrumbNav extends StatelessWidget {
  const BreadcrumbNav({super.key, required this.items, required this.currentIndex, required this.onTap});
  final List<String> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: i == currentIndex ? AppColors.accentPrimarySoft : AppColors.bgElevated1,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: i == currentIndex ? AppColors.accentPrimary : AppColors.strokeSoft),
                ),
                child: Text(items[i], style: AppTypography.caption.copyWith(color: i == currentIndex ? AppColors.accentPrimary : AppColors.textSecondary)),
              ),
            ),
            if (i != items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textMuted),
              ),
          ]
        ],
      ),
    );
  }
}
