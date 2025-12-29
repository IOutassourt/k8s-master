export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo chmod o+r /etc/rancher/k3s/k3s.yaml

######################################################################
#         Installing Knative                                         #
######################################################################

# Serving
sudo k3s kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.20.0/serving-crds.yaml
sudo k3s kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.20.0/serving-core.yaml

# Eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.20.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.20.0/eventing-core.yaml
kubectl apply -f eventing-core.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.20.0/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/blob/main/config/channels/in-memory-channel/deployments/controller.yaml
kubectl create clusterrolebinding eventing-controller-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=knative-eventing:eventing-controller
openssl genrsa -out /home/lima-master/ca.key 2048
openssl req -x509 -new -nodes -key /home/lima-master/ca.key -subj "/CN=knative-ca" -days 365 -out /home/lima-master/ca.crt
openssl genrsa -out /home/lima-master/tls.key 2048
openssl req -new -key /home/lima-master/tls.key -subj "/CN=inmemorychannel-webhook.knative-eventing.svc" -out /home/lima-master/tls.csr
openssl x509 -req -in /home/lima-master/tls.csr -CA /home/lima-master/ca.crt -CAkey /home/lima-master/ca.key -CAcreateserial -out /home/lima-master/tls.crt -days 365 -extensions v3_req -extfile <(printf "[v3_req]\nsubjectAltName=DNS:inmemorychannel-webhook.knative-eventing.svc")
mv /home/lima-master/ca.crt /home/lima-master/ca-cert.pem
kubectl delete secret inmemorychannel-webhook-certs -n knative-eventing
kubectl create secret generic inmemorychannel-webhook-certs \
  --from-file=tls.crt=/home/lima-master/tls.crt \
  --from-file=tls.key=/home/lima-master/tls.key \
  --from-file=ca-cert.pem=/home/lima-master/ca-cert.pem \
  -n knative-eventing
kubectl rollout restart deployment eventing-webhook -n knative-eventing
kubectl rollout restart deployment imc-controller -n knative-eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.20.0/mt-channel-broker.yaml

# Kourier
sudo k3s kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.20.0/kourier.yaml

# Patch the config to use Kourier
sudo k3s kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'



#
#curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
#
#sudo k3s kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
#
#sudo k3s kubectl create namespace kong
#
#
helm repo add kong https://charts.konghq.com
helm repo update

##helm upgrade --install kgo kong/gateway-operator -n kong-system \
##  --create-namespace \
##  --set env.ENABLE_CONTROLLER_KONNECT=true

#
#
#sudo k3s kubectl -n kong-system wait --for=condition=Available=true --timeout=120s deployment/kong-operator-kong-operator-controller-manager
#
#if [[ $? -ne 0 ]]; then
#  echo "Did not receive the expected return code"
#fi
#
#
#sudo k3s kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml
#helm install kong --namespace kong --create-namespace --repo https://charts.konghq.com ingress
#
sudo k3s kubectl annotate crd ingressclassparameterses.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd ingressclassparameterses.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongclusterplugins.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongclusterplugins.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongconsumergroups.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongconsumergroups.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongconsumers.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongconsumers.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongcustomentities.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongcustomentities.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongingresses.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongingresses.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd konglicenses.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd konglicenses.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongplugins.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongplugins.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongupstreampolicies.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongupstreampolicies.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd kongvaults.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd kongvaults.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd tcpingresses.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd tcpingresses.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd udpingresses.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd udpingresses.configuration.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd aigateways.gateway-operator.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd aigateways.gateway-operator.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd aigateways.gateway-operator.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd aigateways.gateway-operator.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

sudo k3s kubectl annotate crd controlplanes.gateway-operator.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite

sudo k3s kubectl label crd controlplanes.gateway-operator.konghq.com \
  app.kubernetes.io/managed-by=Helm \
  --overwrite

##helm install kong kong/kong \
##  -n kong \
##  --create-namespace \
##  --set ingressController.installCRDs=true \
##  --set env.database=off \
##  --set env.role=traditional \
##  --set ingressController.enabled=false



sudo k3s kubectl apply -f /home/lima-master/configMap/kong.yml

sudo k3s kubectl delete namespace kong
helm upgrade --install kong kong/kong --values kong-values.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml --create-namespace -n kong
sudo k3s kubectl -n kong get pods
sudo k3s kubectl -n kong get svc


# Get Kourier proxy service name
sudo k3s kubectl -n kourier-system get svc

# Example: assume kourier-proxy is kourier in kourier-system, port 80
# Create a Kong Ingress (or Kubernetes Ingress) mapping /svc-a to the kourier proxy — example below in Resources section.
sudo k3s kubectl apply -f ns.yaml #1
sudo k3s kubectl apply -f broker.yaml #1
sudo k3s kubectl apply -f event.yaml #0
#--#sudo k3s kubectl apply -f trigger.yaml #1
#sudo k3s kubectl apply -f query.yaml #0
sudo k3s kubectl apply -f store.yaml
sudo k3s kubectl apply -f broker-proxy.yaml #1
#--#sudo k3s kubectl apply -f broker-ingress.yaml #1
sudo k3s kubectl apply -f query-ingress.yaml #1
