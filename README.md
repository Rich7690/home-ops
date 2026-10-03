<div align="center">

![61287648](https://github.com/Rich7690/home-ops/assets/11451714/38f85ed1-393d-4d40-b3a7-d3d1ccf8cf48)


## My home server configuration
</div>

<br/>

## 📖 Overview

This repository contains the configuration I use to manage a lot of the software I run on my home server. The primary orchestrator I use to run applications in my home server environment is [Kubernetes](https://kubernetes.io) due to its many various features for running software. I'm a big user of the [k8s-at-home](https://github.com/k8s-at-home/) project configs for simple deployments of commonly used applications in the cluster.

At the moment, I primarly use a ArgoCD to deploy applications into the cluster.

## Developer workflow

### Updating encrypted Kubernetes secrets

SOPS uses the repository's age recipient and field rules in `.sops.yaml`. To encrypt a new secret, create a `*.sops.yaml` file under `kustomize/secrets/` and run this from the repository root:

```sh
./kustomize/secrets/encrypt.sh ./kustomize/secrets
```

The script writes a matching `.enc.yaml` file beside each source file and leaves the plaintext source in place; do not commit the plaintext file. Add the encrypted file's path to the `files` list in `kustomize/ksops.yaml`, which is loaded by `kustomize/kustomization.yaml`.

Argo CD decrypts these files through the KSOPS generator. Its repo-server expects the age private-key Secret named `age-key` in the `argocd` namespace, as configured in `argo-cd/argocd-repo-server-ksops.yaml`.
