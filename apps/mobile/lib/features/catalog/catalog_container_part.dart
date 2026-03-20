part of '../../main.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.games.isEmpty) {
      return EmptyState(
        title: 'Каталог пуст',
        subtitle: 'Игры пока недоступны. Попробуйте перезапустить backend.',
        actionLabel: 'На главную',
        onAction: () => state.setTab(0),
      );
    }

    return ListView(
      padding: AppLayout.safeAwarePadding(context),
      children: [
        TopBar(
          title: 'Каталог игр',
          trailing: Wrap(
            spacing: AppSpacing.xs,
            children: [
              AppChoiceTab(label: state.t('home.botEasy'), selected: state.botLevel == 'easy', onSelected: () => state.setBotLevel('easy')),
              AppChoiceTab(label: state.t('home.botNormal'), selected: state.botLevel == 'normal', onSelected: () => state.setBotLevel('normal')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.games.map((raw) {
          final game = raw as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GameCard(
              title: game['title']?.toString() ?? game['id'].toString(),
              description: 'ID: ${game['id']}',
              badge: 'online',
              onPlay: () {
                state.setCurrentGame(game['id'].toString());
                state.createPrivateRoom(game['id'].toString());
              },
            ),
          );
        }),
      ],
    );
  }
}
