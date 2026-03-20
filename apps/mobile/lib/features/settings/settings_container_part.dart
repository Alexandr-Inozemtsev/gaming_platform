part of '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text(state.t('settings.title')),
        Text('${state.t('settings.lang')}: ${state.lang.toUpperCase()}'),
        Wrap(
          spacing: AppTokens.s8,
          children: AppStrings.supported
              .map((l) => AppChoiceTab(label: l.toUpperCase(), selected: state.lang == l, onSelected: () => state.setLang(l)))
              .toList(),
        ),
        const SizedBox(height: 12),
        Text(state.t('settings.summary')),
      ],
    );
  }
}
