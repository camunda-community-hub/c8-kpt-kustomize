modeler webapp is a node.js application and uses the [zeebe-client](https://www.npmjs.com/package/zeebe-node#tls). These are the environment variables needed to support custom CAs:

ZEEBE_CA_CERTIFICATE_PATH: /var/run/ssl/trusted.crt
ZEEBE_CLIENT_SSL_CERT_CHAIN_PATH: /var/run/ssl/trusted-chain.crt
ZEEBE_CLIENT_SSL_PRIVATE_KEY_PATH: /var/run/tls/tls.key
ZEEBE_CLIENT_SSL_ROOT_CERTS_PATH: /var/run/ssl/trusted.crt
ZEEBE_SECURE_CONNECTION: "true"
#NODE_TLS_REJECT_UNAUTHORIZED: "0"

The source certificates are created during the deployment of the istio gateway you're publishing your virtual services on. In our environment, this secret is automatically replicated by Swisscom's Helix components:

kubectl annotate secret -n helix-ingress-gateway-internal-camunda internal-camunda-gateway-credential replicator.v1.mittwald.de/replicate-to=camunda8-dev

You might have to copy it manually from the namespace of the ingress gateway.

kubectl get secret internal-camunda-gateway-credential -o jsonpath="{.data.ca\.crt}" | base64 -d > helix-ca.crt
kubectl get secret internal-camunda-gateway-credential -o jsonpath="{.data.tls\.crt}" | base64 -d > helix-gw.crt
cat helix-gw.crt helix-ca.crt > trusted-chain.crt
kubectl create configmap trusted-cas --from-file=./trusted-chain.crt --from-file=trusted.crt=./helix-ca.crt

This way you have both, the server ca only (needed for ZEEBE_CA_CERTIFICATE_PATH) and the full chain.

modeler webapp depends on other services that are configured cluster local wherever possible. See [modeler-webapp-env-vars.yaml](modeler-webapp-env-vars.yaml) for details. 