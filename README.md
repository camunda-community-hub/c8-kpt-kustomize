[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![](https://img.shields.io/badge/Lifecycle-Incubating-blue)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#incubating-)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)
[![](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)

# Camunda 8 Platform for Kubernetes with Istio with kustomize and kpt

The solution allows to deploy camunda 8 platform modularized to any kubernetes cluster. It supports kubernetes ingress as well as Istio network capabilities ([see blog](https://vdan.niceneasy.ch/camunda-8-oauth-for-zeebe-with-istio/)). It can be tailored to the following packages:

- Camunda Identity, Operate, Tasklist, Optimize, Connectors (8.1.5, optimize: 3.9.3)

- Webmodeler 0.4.1-beta

- Zeebe, keycloak, elasticsearch can be deployed "internally" - in the target namespace - or consumed by simply setting the URLs to external services.

- DB services and elasticsearch clusters (ELK) are already widely available in the k8s space and could ideally reused (data lake concept: bring all together and have it combined).

For the connectors this project will enable

- SecretProvider based on Hashicorp Vault
- Kafka Inbound and Outbound Connectors
- [Kafka Exporter](https://github.com/camunda-community-hub/zeebe-kafka-exporter)

If you are interested to contribute, we're looking for help.


