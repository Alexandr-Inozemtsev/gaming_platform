part of '../../main.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppLayout.safeAwarePadding(context),
      children: [
        TopBar(
          title: 'Campaigns',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChoiceTab(label: 'All-time', selected: state.leaderboardPeriod == 'all-time', onSelected: () => state.setLeaderboardPeriod('all-time')),
              const SizedBox(width: AppSpacing.xs),
              AppChoiceTab(label: 'Weekly', selected: state.leaderboardPeriod == 'weekly', onSelected: () => state.setLeaderboardPeriod('weekly')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Create "Save the Plumpkin"',
                onPressed: state.createCampaignQuick,
                icon: Icons.add_circle_outline,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            AppButton(label: 'Refresh', variant: AppButtonVariant.secondary, onPressed: state.loadCampaigns),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.campaigns.map((raw) {
          final campaign = raw as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: AppMotion.medium,
              closedBuilder: (context, open) => GameCard(
                title: campaign['name']?.toString() ?? 'Campaign',
                description: campaign['description']?.toString() ?? 'Campaign details',
                badge: 'campaign',
                onPlay: open,
              ),
              openBuilder: (context, close) => Scaffold(
                appBar: AppBar(title: Text(campaign['name']?.toString() ?? 'Campaign')),
                body: Padding(
                  padding: AppLayout.safeAwarePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign['description']?.toString() ?? 'Description', style: AppTypography.bodyMd),
                      const SizedBox(height: AppSpacing.md),
                      Text('Levels JSON', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text((campaign['levels'] ?? const []).toString(), style: AppTypography.bodySm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Start Campaign',
                              onPressed: () async {
                                await state.startCampaignFlow(campaign['id'].toString());
                                if (context.mounted) Navigator.of(context).pop();
                              },
                              icon: Icons.play_arrow_rounded,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          AppButton(label: 'Back', variant: AppButtonVariant.secondary, onPressed: close),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Text('Leaderboard (${state.leaderboardPeriod})', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        ...state.leaderboard.take(10).map((row) {
          final item = row as Map<String, dynamic>;
          return ListTile(
            title: Text(item['userId']?.toString() ?? 'user'),
            trailing: Text('${item['score'] ?? 0}', style: AppTypography.h3.copyWith(color: AppColors.accentPrimary)),
          );
        }),
      ],
    );
  }
}
