enum Deployment { dockerVps, firebase }

const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dockerVps');
final deployment = Deployment.values.byName(flavor);

extension DeploymentExtension on Deployment {
  String get apiBaseUrl {
    switch (this) {
      case Deployment.dockerVps:
        return 'http://localhost:8000/api/v1';
      case Deployment.firebase:
        return 'https://us-central1-darv-13c19.cloudfunctions.net/api';
    }
  }
}
