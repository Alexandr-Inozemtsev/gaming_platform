part of '../../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final dashboard = state.analyticsDashboardData;
    final dau = (dashboard['dauProxy'] as List?) ?? const [];
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text('${state.t('profile.title')}: ${state.userId ?? state.t('profile.guest')}'),
        const SizedBox(height: 8),
        Text(state.t('profile.adminAnalytics')),
        Row(
          children: [
            Container(width: 24, height: 2, color: AppTokens.analyticsChartLine),
            const SizedBox(width: 8),
            Container(width: 24, height: 2, color: AppTokens.analyticsAxis),
          ],
        ),
        Text('${state.t('profile.matches7d')}: ${state.formatNumber((dashboard['matches7d'] as num?) ?? 0)}'),
        ...dau.map((row) => Text('${state.t('profile.dauPrefix')} ${row['day']}: ${state.formatNumber((row['uniqueUsers'] as num?) ?? 0)}')),
        const SizedBox(height: 8),
        AppSecondaryButton(onPressed: state.loadAdminAnalytics, label: state.t('profile.refreshAnalytics')),
        const SizedBox(height: 8),
        Text(state.t('profile.moderationFlow')),
        const SizedBox(height: 8),
        ...state.moderationQueue.take(10).map((entry) {
          final item = entry as Map<String, dynamic>;
          final isOpen = (item['status']?.toString() ?? '') == 'open';
          return Card(
            child: ListTile(
              title: Text('${state.t('profile.casePrefix')} ${item['id']} • ${item['targetType']}'),
              subtitle: Text('${state.t('profile.caseStatus')}=${item['status']} • ${state.t('profile.caseReason')}=${item['reason']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? AppTokens.modCaseOpen : AppTokens.modCaseClosed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item['status']?.toString() ?? '-'),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(state.tp('profile.auditEntries', state.moderationAuditLog.length)),
        ...state.analyticsEventsTable.take(20).map((e) {
          final item = e as Map<String, dynamic>;
          return ListTile(dense: true, title: Text(item['eventName']?.toString() ?? 'event'), subtitle: Text(item['ts']?.toString() ?? ''));
        }),
      ],
    );
  }
}
