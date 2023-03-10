[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![](https://img.shields.io/badge/Lifecycle-Incubating-blue)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#incubating-)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)
[![](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)

# Camunda 8 Platform for Kubernetes with Istio with kustomize and kpt

The solution allows to deploy camunda 8 platform modularized to any kubernetes cluster. It supports kubernetes ingress as well as Istio network capabilities ([see blog](https://vdan.niceneasy.ch/camunda-8-oauth-for-zeebe-with-istio/)). It can be tailored to the following packages:

- Camunda Identity, Operate, Tasklist, Optimize, Connectors (8.1.8, optimize: 3.9.3)

- Webmodeler (0.6.0-beta)

- Zeebe, keycloak, elasticsearch can be deployed "internally" - in the target namespace - or consumed by simply setting the URLs to external services.

- DB services and elasticsearch clusters (ELK) are already widely available in the k8s space and could ideally reused (data lake concept: bring all together and have it combined).

For the connectors this project will enable

- [SecretProvider based on Hashicorp Vault](https://github.com/bluebossa63/camunda-custom-connector-poc)
- [Kafka Inbound and Outbound Connectors](https://github.com/bluebossa63/camunda-custom-connector-poc)
- [Kafka Exporter](https://github.com/camunda-community-hub/zeebe-kafka-exporter)

If you are interested to contribute, we're looking for help.

## Repository Documentation

This repo shall enable a modular deployment of camunda components as needed. Based on the official helm charts, Istio and the webmodeler are added. This repository is built on the standard tools of the Swisscom Helix platform: [kpt](https://kpt.dev/installation/) and [kustomize](https://kustomize.io/).

The process is basically to check out the package (repo template) over kpt into a fresh repository of yours. kpt will then update the files, the result will be checked into your repository.

fetch the package

adapt the Kptfile  (see Kptfile.pipeline.example for hints)

render the changes  (kpt fn render)

check in the result

apply the result  (kubectl apply -k .)

The modularisation is implemented over kpt: the kustomize configuration gets adapted according to your needs. Each time you change the Kptfile you have to render the project again, check in and apply it to the cluster.

The reasoning behind the modularization is documented in
[Shared Services](./docs/shared-services.md) and it is similar to the options of the values file of the official helm chart.

## Top Level Structure

### /camunda
All camunda microservices and connectors - without zeebe

### /docs
Static content for docs site.

### /security
All manifests for Istio, TLS and more

### /shared
library with shared services like zeebe, elasticsearch and others

### /showroom
An awesome camunda [demo app](https://github.com/camunda-consulting/showroom-customer-onboarding/tree/c8-iteration2)

### /webmodeler
camunda webmodeler beta

## PoC initial deployment

This kustomize/kpt project was developed based on the official helm charts according to the docs

https://docs.camunda.io/docs/self-managed/platform-deployment/helm-kubernetes/overview/

and the enterprise access to the webmodeler ( user and pw needed )

https://docs.camunda.io/docs/self-managed/platform-deployment/docker/  

I have found out the the docker-compose repo seems to bee the most uptodate source of truth:

https://github.com/camunda/camunda-platform

The manifests for the webmodeler parts are generated by kompose.

### Architecture Overview

[Istio Configuration](./docs/istio-config.md)

[Permission with Camunda Identity](./docs/permissions.md)

### TLS with self-signed CAs

[TLS with self-signed CAs](./docs/tls.md)
## Open Issues

### CAs

Most of the microservices depend on java keystores. 
It seems not to be possible, to entirely rely on purely internal communication on http and let do Istio the rest. Still WIP to investigate why the internal URLs are not enough.
Please see [TLS with self-signed CAs](./docs/tls.md).
For the variant without istio you'll be forced to solve the problem anyway.

### Initial User creation is faulty

Please login to keycloak and add email, name and lastname for the user demo. This is needed for the webmodeler.
Hint: this could be changed in the realm setup of Identity setup/sync process.

### Shared Services

Keycloak and webmodeler both rely on postgresql that could be replaced by a managed service.
The same considerations should be made for elasticsearch and zeebe. Both are candidates for managed services if they are not already available. See [Shared Services](./docs/shared-services.md) for further discussion.

## Application URLs

| Service | URL |
| --- | --- |
| Operate | https://camunda.example.com/operate/ |
| Optimize | https://camunda.example.com/optimize/ |
| Tasklist | https://camunda.example.com/tasklist/ |
| Zeebe    | https://zeebe.camunda.example.com |
| Webmodeler | https://webmodeler.example.com |
| Keycloak | https://camunda.example.com/auth/ |
| Identity | https://camunda.example.com/identity/ |
| Kibana   | https://kibana.example.com/ |
| Vault    | https://vault.example.com/ |
| Kafka    | kafka.example.com:80 |
| Showroom | https://camunda.example.com/camunda |
