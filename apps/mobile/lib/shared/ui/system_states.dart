// Назначение файла: предоставить переиспользуемые UI-компоненты системных состояний приложения.
// Роль в проекте: единообразно показывать loading/error/empty/reconnect в разных экранах без дублирования разметки.
// Основные функции: LoadingState, ErrorState, EmptyState, ReconnectBanner с адаптацией под mobile-landscape.
// Связи с другими файлами: используется screen-контейнерами (home/catalog/room) и может применяться в будущих feature-модулях.
// Важно при изменении: сохранять компактность компонентов для landscape viewport и не хардкодить цвета вне токенов.

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Загрузка...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(height: AppTokens.s8),
          Text(label, style: Theme.of(context).textTheme.bodySmall)
        ]
      )
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry, this.retryLabel = 'Повторить'});

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: AppTokens.danger),
              const SizedBox(height: AppTokens.s8),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: AppTokens.s12),
                FilledButton(onPressed: onRetry, child: Text(retryLabel))
              ]
            ])
          )
        )
      )
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.inbox_outlined, color: AppTokens.muted),
              const SizedBox(height: AppTokens.s8),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppTokens.s8),
                Text(subtitle!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: AppTokens.s12),
                OutlinedButton(onPressed: onAction, child: Text(actionLabel!))
              ]
            ])
          )
        )
      )
    );
  }
}

class ReconnectBanner extends StatefulWidget {
  const ReconnectBanner({super.key, required this.visible, required this.text});

  final bool visible;
  final String text;

  @override
  State<ReconnectBanner> createState() => _ReconnectBannerState();
}

class _ReconnectBannerState extends State<ReconnectBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: !widget.visible
          ? const SizedBox.shrink()
          : FadeTransition(
              opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller),
              child: Container(
                key: const ValueKey('reconnect-banner'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8),
                decoration: BoxDecoration(
                  color: AppTokens.editorWarning.withOpacity(0.2),
                  border: Border(bottom: BorderSide(color: AppTokens.editorWarning.withOpacity(0.65)))
                ),
                child: Row(children: [
                  const Icon(Icons.wifi_off, size: 16, color: AppTokens.editorWarning),
                  const SizedBox(width: AppTokens.s8),
                  Expanded(child: Text(widget.text, style: Theme.of(context).textTheme.bodySmall))
                ])
              )
            )
    );
  }
}
