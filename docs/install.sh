#clean up old stuff
rm -f trust-store.jks helix-ca.crt helix-gw.crt trusted.crt

#replicate TLS secret for camunda istio ingress gateway.
#this works only with the activated replicator!
#Alternative: kubectl get secret helix-ingress-gateway-internal-camunda -o yaml > helix-ingress-gateway-internal-camunda.yaml 
#Don't forget to edit the file: change namespace and delete all instance related data like timestamp lastAppliedConfiguration and so on.
kubectl annotate secret -n helix-ingress-gateway-internal-camunda internal-camunda-gateway-credential replicator.v1.mittwald.de/replicate-to=camunda8-dev
sleep 3 #give some time to execute...

#extract some certificates from the replicated secret
kubectl get secret -n camunda8-dev internal-camunda-gateway-credential -o jsonpath="{.data.ca\.crt"} | base64 -d > helix-ca.crt
kubectl get secret -n camunda8-dev internal-camunda-gateway-credential -o jsonpath="{.data.tls\.crt"} | base64 -d > helix-gw.crt

#import them into java keystores
keytool -import -alias example.com -keystore trust-store.jks -file helix-gw.crt -srcstorepass demodemo -deststorepass demodemo -noprompt
keytool -import -alias example.com.ca -keystore trust-store.jks -file helix-ca.crt -srcstorepass demodemo -deststorepass demodemo -noprompt

#make sure namespace camunda8-dev exists
kubectl apply -f ./camunda-platform-8/camunda8-dev-namespace.yaml
sleep 3

#create configmaps from files
#java keystore for spring boot apps
kubectl create configmap -n camunda8-dev trust-store-jks --from-file=./trust-store.jks
#trusted-cas for zeebe client, who wants a combinend server & CA certificate
cat helix-ca.crt helix-gw.crt > trusted.crt #attention, order matters
kubectl create configmap -n camunda8-dev trusted-cas --from-file=./trusted.crt

kubens camunda8-dev
kubectl apply -k ./camunda-platform-8/iam

#kubectl apply -f regcred.yaml