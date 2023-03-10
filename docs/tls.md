## TLS Configuration for self-signed CAs

### relevant certificates that have to be known upfront

In our setup we were relying on the certificate manager implementation of Swisscom Helix. This means we have a CA certifcate bundle we have to make trusted for each application.

```bash
kubectl annotate secret -n helix-ingress-gateway-internal-camunda internal-camunda-gateway-credential replicator.v1.mittwald.de/replicate-to=camunda8-dev
rm -f trust-store.jks
kubens helix-ingress-gateway-internal-camunda
kubectl get secret internal-camunda-gateway-credential -o jsonpath="{.data.ca\.crt}" | base64 -d > helix-ca.crt
kubectl get secret internal-camunda-gateway-credential -o jsonpath="{.data.tls\.crt}" | base64 -d > helix-gw.crt
cp cacerts.org trust-store.jks
keytool -import -alias example.com -keystore trust-store.jks -file helix-gw.crt -srcstorepass demodemo -deststorepass demodemo -noprompt
keytool -import -alias example.com.ca -keystore trust-store.jks -file helix-ca.crt -srcstorepass demodemo -deststorepass demodemo -noprompt 
kubectl create configmap trust-store-jks --from-file=./trust-store.jks
cat helix-gw.crt helix-ca.crt > trusted.crt
kubectl create configmap trusted-cas --from-file=./trusted.crt
```
After keycloak is up and running and the camunda realm is created, take the JWS keys from this URL: https://camunda.example.com/auth/realms/camunda-platform/protocol/openid-connect/certs
and paste the content of the response as the jwks attribute [here](../security/istio/request-authentication.yaml).

Hint: on a platform with low ressources it might be better to start the IAM part separately and upfront. Camunda identity is setting up a keycloak realm "camunda-platform" with all needed clients and secrets. Before this is not properly done, most of the other services have issues on startup and will retry.

```bash
kubectl apply -f ./camunda-platform-8/camunda8-dev-namespace.yaml
sleep 3
kubens camunda8-dev
kubectl apply -k ./camunda-platform-8/iam
#wait for keycloak and identity to come up
kubectl apply -k ./camunda-platform-8
```

These above variants of certificates are used all over the place. Most of the containers are hosting spring boot applications that can easily be configured from outside:

```bash
JDK_JAVA_OPTIONS=-Dlogging.level.root=info -Djavax.net.ssl.trustStore=/etc/ssl/camunda/trust-store.jks -Djavax.net.ssl.trustStorePassword=demodemo
```

The trust store file itself is mounted by the configmap trust-store-jks:

```yaml
        volumeMounts:
        - name: config
          mountPath: /usr/local/operate/config/application.yml
          subPath: application.yml
        - name: keystore
          mountPath: /etc/ssl/camunda     
      volumes:
      - name: config
        configMap:
          name: camunda-operate
          defaultMode: 484
      - name: keystore
        configMap:
          name: trust-store-jks
```

In this snippet you can see how easy it is to override the spring configuration itself.

Special cases are the webmodeler application(node.js) and webmodeler websockets (php), each with special requirements when it comes to accept self-signed certificates.

Camunda webmodeler is Beta and not licensed for productive use anyway and we have currently [one open issue](https://forum.camunda.io/t/webmodeler-0-3-0-beta-for-kubernetes-and-istio/41938) with the webmodeler with TLS support.

The issues with self-signed CAs will repeat using the [Desktop Modeler (see bottom of the page)](./permissions.md).

