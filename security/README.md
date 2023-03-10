# Camunda 8 Platform Security

Kubernetes Resources exposing and securing the services.

[istio](../docs/istio-config.md) is the more advanced option if an Istio enabled cluster ist available. It is the only possiblity to have a fully OAuth 2.0 compliant access security only by configuration.

[ingress](.) is the option without Istio but with an ingress controller such as ngnix or Contour.

[network-policies](.) are the rules to establish a zero trust micro-segmentation.

[psp](.) needed for clusters that still enforce PodSecurityPolicy.

[tls](../docs/tls.md) contain secrets and configmaps that apply to a given environment. You will have to setup them correctly for your environment.