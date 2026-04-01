import 'package:url_launcher/url_launcher.dart';

const String _unityLaunchModeFromEnv = String.fromEnvironment(
  'UNITY_BIG_WALKER_LAUNCH_MODE',
  defaultValue: 'in_app',
);

enum UnityRuntimeLaunchMode { inApp, external }

class UnityRuntimeLaunchResult {
  const UnityRuntimeLaunchResult({required this.ok, required this.mode});

  final bool ok;
  final UnityRuntimeLaunchMode mode;
}

abstract class UnityRuntimeAdapter {
  UnityRuntimeLaunchMode get mode;
  Future<UnityRuntimeLaunchResult> launch(Uri uri);
}

class InAppBrowserUnityRuntimeAdapter implements UnityRuntimeAdapter {
  @override
  UnityRuntimeLaunchMode get mode => UnityRuntimeLaunchMode.inApp;

  @override
  Future<UnityRuntimeLaunchResult> launch(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    return UnityRuntimeLaunchResult(ok: opened, mode: mode);
  }
}

class ExternalUnityRuntimeAdapter implements UnityRuntimeAdapter {
  @override
  UnityRuntimeLaunchMode get mode => UnityRuntimeLaunchMode.external;

  @override
  Future<UnityRuntimeLaunchResult> launch(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return UnityRuntimeLaunchResult(ok: opened, mode: mode);
  }
}

UnityRuntimeAdapter createUnityRuntimeAdapter() {
  if (_unityLaunchModeFromEnv == 'external') return ExternalUnityRuntimeAdapter();
  return InAppBrowserUnityRuntimeAdapter();
}
