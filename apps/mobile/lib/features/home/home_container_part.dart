part of '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: AppPanelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.t('home.continue')),
            const SizedBox(height: AppTokens.s12),
            Row(
              children: [
                AppPrimaryButton(onPressed: () => state.setTab(3), label: state.t('home.play')),
                const SizedBox(width: AppTokens.s12),
                AppSecondaryButton(onPressed: () => state.createPrivateRoom(state.currentGameId), label: state.t('home.createRoom')),
              ],
            ),
            const SizedBox(height: AppTokens.s12),
            Text(state.t('home.teaser')),
          ],
        ),
      ),
    );
  }
}
