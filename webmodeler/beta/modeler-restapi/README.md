modeler-restapi is a spring boot webapp.

To enable custom CAs, JAVA_OPTIONS are used to set a trust store with the added CAs and the needed files are mounted. Check [TLS](../../../docs/tls.md) for additional details.

[modeler-restapi-configmap.yaml](modeler-restapi-configmap.yaml) contains the application.yaml used to override the container configuration. Reason for this was to enable the usage of postgresql clusters. The original implementation did not allow to specifiy multiple hosts or directly a jdbc url.