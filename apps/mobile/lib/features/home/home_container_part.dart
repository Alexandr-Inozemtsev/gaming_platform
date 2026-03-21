part of '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> selectedGame = {'id': state.currentGameId, 'title': 'Tabletop Match'};
    for (final raw in state.games) {
      final game = raw as Map<String, dynamic>;
      if (game['id']?.toString() == state.currentGameId) {
        selectedGame = game;
        break;
      }
      selectedGame = game;
    }
    final title = selectedGame['title']?.toString() ?? selectedGame['id']?.toString() ?? 'Tabletop Match';

    return Padding(
      padding: AppLayout.safeAwarePadding(context, horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A2632), Color(0xFF111823), Color(0xFF0B0F15)],
                ),
              ),
            ),
            // Темный vignette-слой в стиле lobby-сцены.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.15),
                    radius: 0.9,
                    colors: [
                      AppColors.accentPrimary.withOpacity(0.09),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Центральный персонажный силуэт placeholder.
            Align(
              alignment: const Alignment(0, -0.08),
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: 280,
                  height: 360,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF7F8CA0), Color(0xFF3D4A5C), Color(0x00111823)],
                    ),
                    borderRadius: BorderRadius.circular(140),
                    boxShadow: AppElevation.level2,
                  ),
                  child: const Icon(Icons.shield_moon_rounded, size: 120, color: Colors.white54),
                ),
              ),
            ),
            // Минимальный верхний статус-блок без шумных боковых панелей.
            Positioned(
              right: 16,
              top: 14,
              child: AppBadge(label: 'Lobby', color: AppColors.info),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AppPanel(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Выбранная настольная игра', style: AppTypography.caption),
                      const SizedBox(height: AppSpacing.xs),
                      Text(title, style: AppTypography.h2),
                      const SizedBox(height: AppSpacing.xs),
                      Text('ID: ${selectedGame['id'] ?? state.currentGameId}', style: AppTypography.bodySm),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: state.t('home.play'),
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => state.createPrivateRoom('big_walker_demo'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          AppButton(
                            label: state.t('tab.catalog'),
                            variant: AppButtonVariant.secondary,
                            onPressed: () => state.setTab(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
