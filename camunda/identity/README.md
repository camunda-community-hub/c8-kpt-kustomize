# Camunda 8 Identity

After a user centric [introduction](https://docs.camunda.io/docs/self-managed/identity/what-is-identity/) from camunda, you might be interested in the [configuration docs](https://docs.camunda.io/docs/self-managed/identity/deployment/configuration-variables/) and you can extract the used environment variables from the official [docker-compose](https://github.com/camunda/camunda-platform/blob/main/docker-compose.yaml).

## Identity Configuration

The identity component is able to initialize and enforce a keycloak domain with all needed clients, users and roles. The default installation is located at ```camunda-identity-<suffix>:/app/identity.jar/BOOT-INF/classes/keycloak```.

For the PoC we deployed a dedicated instance of keycloak ("internal-keycloak) but for an automated deplyoment we'll target the shared keycloak with the need to setup a dedicated keycloak domain per installation - and the need to get it deleted on undeploy of the main components. 

The most important acceptance criteria for the PoC was to ensure that the zeebe grpc endpoints are fully secured by standard OAuth mechanisms. This could be implemented by Istio RequestAuthentication and AuthorizationPolicies (see [Istio](../../docs/istio-config.md)) based on permissions created in camunda identity. Please see the [permissions setup guide](../../docs/permissions.md) the additions to the configuration are not yet included in the base config of identity and have to be created manually if you initialize or drop the keycloak database.

## Identity Deployment

The deployment dependencies are not properly managed in kubernetes: if you deploy the whole project, it will take a while and after restarts of some components the system will be stabilized and up and running.

A reasonable start order would be

- keycloak postgresql
- keycloak
- identity

---- IAM up and running

- elasticsearch
- zeebe broker
- zeebe gateway
- operate
- tasklist
- optimize
- connectors
- kibana

---- Camunda 8 Platform up and running
- modeler-postgressql
- modeler-restapi
- modeler-websockets
- modeler-webapp

---- Camunda 8 Webmodeler up and running

Please see also the ```depends_on``` attribute in the [docker compose files](https://github.com/camunda/camunda-platform).






