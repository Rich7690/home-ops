{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'ApplicationSet',
  metadata: {
    name: 'charts-k3s-kustomize',
    namespace: 'argocd',
  },
  spec: {
    syncPolicy: {
      preserveResourcesOnDeletion: true,
      applicationsSync: 'create-update'
    },
    generators: [
      {
        git: {
          repoURL: std.extVar('repoURL'),
          revision: 'HEAD',
          directories: [
            { path: 'charts-k3s/*' },
          ],
        },
      },
    ],
    template: {
      metadata: {
        name: '{{path.basename}}-k3s',
        namespace: 'argocd',
        finalizers: [
          'resources-finalizer.argocd.argoproj.io',
        ],
      },
      spec: {
        project: 'remote-apps',
        source: {
          repoURL: std.extVar('repoURL'),
          targetRevision: 'HEAD',
          path: '{{path}}',
          kustomize: {
            commonAnnotations: {
              env: 'prod',
            },
          },
        },
        destination: {
          server: 'https://10.0.0.3:6443',
          // namespace: '{{path[1]}}' Namespace provided by kustomize
        },
      },
    },
  },
}
