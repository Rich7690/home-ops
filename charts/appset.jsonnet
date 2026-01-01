{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'ApplicationSet',
  metadata: {
    name: 'charts',
    namespace: 'argocd',
  },
  spec: {
    syncPolicy: {
      preserveResourcesOnDeletion: true,
    },
    generators: [
      {
        git: {
          repoURL: std.extVar('repoURL'),
          revision: 'HEAD',
          directories: [
            { path: 'charts/default/*' },
            { path: 'charts/metrics/*' },
            { path: 'charts/kube-system/*' },
            { path: 'charts/kyverno/*' },
            { path: 'charts/cert-manager/*' },
            { path: 'charts/volsync-system/*' },
          ],
        },
      },
    ],
    template: {
      metadata: {
        name: '{{path.basename}}',
        namespace: 'argocd',
        annotations: {
          // resolves to the directory
          'argocd.argoproj.io/manifest-generate-paths': '.',
        },
      },
      spec: {
        project: 'remote-apps',
        ignoreDifferences: [
          {
            group: 'apps',
            kind: 'Deployment',
            jqPathExpressions: [
              '.spec.template.spec.containers[] | select(.name == "paperless") | .env[] | select(.name == "PAPERLESS_URL")',
            ],
          },
          {
            group: '*',
            kind: 'Secret',
            namespace: 'kube-system',
            jqPathExpressions: [
              '.data',
            ],
          },
        ],
        source: {
          repoURL: std.extVar('repoURL'),
          targetRevision: 'HEAD',
          path: '{{path}}',
          helm: {
            releaseName: '{{path.basename}}',
            valueFiles: [
              'values.yaml',
            ],
          },
        },
        destination: {
          server: 'https://kubernetes.default.svc',
          namespace: '{{path[1]}}',
        },
      },
    },
  },
}
