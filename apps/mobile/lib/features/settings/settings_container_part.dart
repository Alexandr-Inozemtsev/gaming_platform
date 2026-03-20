part of '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppLayout.safeAwarePadding(context),
      children: [
        TopBar(title: state.t('settings.title')),
        const SizedBox(height: AppSpacing.sm),
        AppPanel(
          child: Column(
            children: [
              SettingsRow(title: state.t('settings.lang'), subtitle: state.lang.toUpperCase(), trailing: const Icon(Icons.language_rounded)),
              const Divider(color: AppColors.strokeSoft),
              Wrap(
                spacing: AppSpacing.xs,
                children: AppStrings.supported
                    .map((l) => AppChoiceTab(label: l.toUpperCase(), selected: state.lang == l, onSelected: () => state.setLang(l)))
                    .toList(),
              ),
              const Divider(color: AppColors.strokeSoft),
              SettingsRow(title: state.t('settings.summary'), subtitle: 'Audio, accessibility, gameplay preferences'),
              const Divider(color: AppColors.strokeSoft),
              const SettingsRow(title: 'Выйти', destructive: true, trailing: Icon(Icons.logout_rounded, color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}
