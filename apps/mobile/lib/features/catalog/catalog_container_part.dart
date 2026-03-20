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
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            AppChoiceTab(label: state.t('home.botEasy'), selected: state.botLevel == 'easy', onSelected: () => state.setBotLevel('easy')),
            AppChoiceTab(
              label: state.t('home.botNormal'),
              selected: state.botLevel == 'normal',
              onSelected: () => state.setBotLevel('normal'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...state.games.map((raw) {
          final game = raw as Map<String, dynamic>;
          return Card(
            child: ListTile(
              title: Text(game['title']?.toString() ?? game['id'].toString()),
              subtitle: Text(game['id'].toString()),
              trailing: AppPrimaryButton(
                onPressed: () {
                  state.setCurrentGame(game['id'].toString());
                  state.createPrivateRoom(game['id'].toString());
                },
                label: state.t('home.join'),
              ),
            ),
          );
        }),
      ],
    );
  }
}
