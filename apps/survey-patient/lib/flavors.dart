enum Deployment { dockerVps, firebase }

const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dockerVps');
const apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
final deployment = Deployment.values.byName(flavor);

extension DeploymentExtension on Deployment {
  String get apiBaseUrl {
    if (apiBaseUrlEnv.isNotEmpty) {
      return apiBaseUrlEnv;
    }
    switch (this) {
      case Deployment.dockerVps:
        return '/api/v1';
      case Deployment.firebase:
        return 'https://us-central1-darv-13c19.cloudfunctions.net/api';
    }
  }
}
