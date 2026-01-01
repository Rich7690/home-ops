{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'ApplicationSet',
  metadata: {
    name: 'charts-kustomize',
    namespace: 'argocd',
  },
  spec: {
    goTemplate: true,
    goTemplateOptions: ['missingkey=error'],
    syncPolicy: {
      preserveResourcesOnDeletion: true,
    },
    generators: [
      {
        git: {
          repoURL: std.extVar('repoURL'),
          revision: 'HEAD',
          directories: [
            { path: 'charts-kustomize/*' },
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
        finalizers: [
          'resources-finalizer.argocd.argoproj.io',
        ],
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
          kustomize: {
            commonAnnotations: {
              env: 'prod',
            },
          },
        },
        destination: {
          server: 'https://kubernetes.default.svc',
          // namespace: '{{path[1]}}' Namespace provided by kustomize
        },
      },
    },
  },
}
