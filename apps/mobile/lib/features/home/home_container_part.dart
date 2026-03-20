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
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF364A5C), Color(0xFF1B2431), Color(0xFF0F1115)],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: AppButton(
              label: state.t('home.play'),
              onPressed: () => state.createPrivateRoom(state.currentGameId),
              size: AppButtonSize.lg,
            ),
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
                            onPressed: () => state.setTab(3),
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
    );
  }
}
