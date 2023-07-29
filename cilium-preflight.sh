set -xe
export API_SERVER_IP="192.168.48.2"
export API_SERVER_PORT="6443"
helm template cilium-preflight cilium/cilium --version "1.14.0" \
  --namespace=kube-system \
  --set preflight.enabled=true \
  --set agent=false \
  --set operator.enabled=false \
  --set k8sServiceHost=$API_SERVER_IP \
  --set k8sServicePort=$API_SERVER_PORT > preflight.yaml
