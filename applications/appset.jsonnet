{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'ApplicationSet',
  metadata: {
    name: 'applications',
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
            { path: 'applications/namespaces/default/*' },
            { path: 'applications/namespaces/kube-system/*' },
            { path: 'applications/namespaces/cert-manager/*' },
          ],
        },
      },
    ],
    template: {
      metadata: {
        name: '{{path.basename}}',
        namespace: 'argocd',
        finalizers: [
          'resources-finalizer.argocd.argoproj.io',
        ],
      },
      spec: {
        project: 'default',
        ignoreDifferences: [
          {
            group: 'cert-manager.io',
            kind: 'Certificate',
            namespace: '*',
            jqPathExpressions: [
              '.spec.duration',
            ],
          },
        ],
        source: {
          repoURL: std.extVar('repoURL'),
          targetRevision: 'HEAD',
          path: '{{path}}',
        },
        destination: {
          server: 'https://kubernetes.default.svc',
          namespace: '{{path[2]}}',
        },
      },
    },
  },
}
