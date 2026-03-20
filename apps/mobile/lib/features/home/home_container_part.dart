part of '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppLayout.safeAwarePadding(context),
      child: ListView(
        children: [
          FeaturedGameBanner(
            title: 'Tactical Tabletop Lounge',
            subtitle: 'Лобби, партии и друзья в едином landscape-first потоке.',
            cta: AppButton(
              label: state.t('home.play'),
              icon: Icons.play_arrow_rounded,
              onPressed: () => state.setTab(3),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<String?>(
            future: RuntimeAssetPack.instance.firstInCategory('ambient_backgrounds'),
            builder: (context, snapshot) => AppPanel(
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.rewardGlow),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      "Asset pack: ${snapshot.data ?? 'loading...'}",
                      style: AppTypography.bodySm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.t('home.continue'), style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton(onPressed: () => state.setTab(3), label: state.t('home.play')),
                    AppButton(
                      onPressed: () => state.createPrivateRoom(state.currentGameId),
                      label: state.t('home.createRoom'),
                      variant: AppButtonVariant.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(state.t('home.teaser'), style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
