enum Deployment { dockerVps, firebase }

const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dockerVps');
const apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
final deployment = Deployment.values.byName(flavor);

extension DeploymentExtension on Deployment {
  String get apiBaseUrl {
    if (apiBaseUrlEnv.isEmpty) {
      throw StateError('API_BASE_URL is not set.');
    }
    return apiBaseUrlEnv;
  }
}
