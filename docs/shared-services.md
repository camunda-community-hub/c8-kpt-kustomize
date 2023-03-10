## Shared Services

The camunda platform 8 helm chart comes with a full set of services that could easily be replaced by shared and even managed services.
Most of the following questions depend on the deployment and operating model that is chosen for a SaaS.

I would create an optional Helix package that is capable to be deployed multiple times (fqdn and ingress gateway changes).

### Keycloak

Swisscom Helix offers a Keycloak instance. Why not use this (management?) instance?

Camunda Identity has a initialization step that is setting up and maintaining state of system clients used by the microservices. This definitions are part of a spring configuration that is adoptable. If we can assure that every camunda installation has its own keycloak realm and we can operate keycloak, this could be a very good solution. A keycloak realm can offer additional integration features on demand.

This could easily be tested within the PoC, all it needs is an keycloak account with the permissions to create a new realm with users, groups, clients. The name of the realm to create is a environment variable for the identity deployment.

### Postgres

Camunda Platform 8 uses postgresql only for keycloak (shared service) and for the webmodeler. We can easily consume cloud services with postgresql.

This step is in the works, especially for the clustered camunda 7 installation.

### Elasticsearch

Camunda Zeebe, the workflow engine, exports data to elasticsearch. It would be possible to use already existing clusters like the one for helix logging.
In the current setup, elasticsearch is not secured at all (no authentication).

There are Kibana Dashboards for Camunda.
In a multi-tenant offering we need to have a good naming convention for separating the tenants in a shared elastic search cluster.

elasticsearch is a challenge for K8s: it needs a privileged container for the startup and it has direct pod to pod communication - not so easy for Istio.
Who is operating elasticsearch at scale???

### Zeebe

Camunda Zeebe has the potential to become a managed shared service like elasticsearch or postgresql. It is the core of the workflow engine and can be used without the microservices around it.

Istio allows to protect Zeebe with OAuth 2.0 JWT and to implement security on a gRPC method level (layer 7) as shown in this PoC, [here](./permissions.md) you learn how to use Camunda Platform 8 "Identity" microservice - a wrapper around keycloak holding the data - to create dynamic permissions per API and Application, and [here](./istio-config.md) you find Istio using these OAuth 2.0 definitions from the JWT.

Same Istio challenge here: Camunda Plattform 8 has splitted Zeebe in a Zeebe Gateway and a Zeebe Broker role. They communicate pod to pod with the [SWIM protocol](https://en.wikipedia.org/wiki/SWIM_Protocol). For Zeebe Broker we had to deactivate Istio completely, the Zeebe Gateway is integrated for the incoming port 26500 - a prerequisite for the JWT checks. We're still working on the issue..., request for information went out to Camunda.

### Mailhog

Camunda Platform 8 helm chart is using Mailhog as a Mailserver simulation. This is not needed and should be replaced by a proper mail relay.


## List of running pods

```bash
kubectl get PodMetrics 
NAME                                    CPU          MEMORY      WINDOW
camunda-identity-764bcb4b86-9m9mz       4718022n     287880Ki    18.422s
camunda-keycloak-0                      12364574n    661244Ki    11.521s
camunda-operate-597b4895bf-x5dnm        52957070n    457044Ki    13.253s
camunda-optimize-7c946c8c48-7qkdp       9504934n     989552Ki    19.797s
camunda-postgresql-0                    11282926n    123780Ki    13.37s
camunda-tasklist-68f7f56dd9-xd8sq       9291044n     389268Ki    18.22s
camunda-zeebe-0                         126067105n   725564Ki    18.893s
camunda-zeebe-1                         144415704n   667864Ki    19.629s
camunda-zeebe-2                         129116754n   786604Ki    13.164s
camunda-zeebe-gateway-77b896876-jlcg5   34446716n    301144Ki    10.025s
camunda-zeebe-gateway-77b896876-l5cks   33944039n    280432Ki    14.158s
elasticsearch-master-0                  42322297n    1653648Ki   11.667s
elasticsearch-master-1                  38401739n    1629304Ki   12.093s
mailhog-656c5fb4c-5z8wx                 4289207n     63556Ki     17.206s
modeler-db-0                            4227057n     126496Ki    18.111s
modeler-restapi-699b6dbc5f-k67z8        32316462n    391840Ki    16.073s
modeler-webapp-7cb896bdc-sw2vr          7569159n     198412Ki    14.358s
modeler-websockets-9bf764f5f-bjxlf      4692460n     86264Ki     10.865s
```

This is the small HA setup of the camunda helm chart:

- elasticsearch runs in a minimal cluster of two instances
- zeebe gateway (stateless) runs with minimal redundancy
- 3 zeebe brokers are waiting for work (workflow execution)

All other services are running in only one instance.

Except for the shared services keycloak and the modeler-db, this is not a real issue because outages are fixed within seconds.

A minimal Helix setup would look like

- identity, operate, optimize, tasklist (package: Camunda 8 Microservices)
- webmodeler (package: Camunda 8 Webmodeler)
- zeebe gateway and brokers (package: Camunda Zeebe)
- ESC postgresql service is used
- Helix keycloak is used
- Helix elasticsearch is used (integrated in Kibana logging)
- Helix mail relay is used

```bash
kubectl get PodMetrics 
NAME                                    CPU          MEMORY      WINDOW
#package Camunda 8 Microservices
camunda-identity-764bcb4b86-9m9mz       4718022n     287880Ki    18.422s
camunda-operate-597b4895bf-x5dnm        52957070n    457044Ki    13.253s
camunda-optimize-7c946c8c48-7qkdp       9504934n     989552Ki    19.797s
camunda-tasklist-68f7f56dd9-xd8sq       9291044n     389268Ki    18.22s
#package Camunda 8 Zeebe
camunda-zeebe-0                         126067105n   725564Ki    18.893s
camunda-zeebe-1                         144415704n   667864Ki    19.629s
camunda-zeebe-2                         129116754n   786604Ki    13.164s
camunda-zeebe-gateway-77b896876-jlcg5   34446716n    301144Ki    10.025s
camunda-zeebe-gateway-77b896876-l5cks   33944039n    280432Ki    14.158s
#package Camunda 8 Webmodeler
modeler-restapi-699b6dbc5f-k67z8        32316462n    391840Ki    16.073s
modeler-webapp-7cb896bdc-sw2vr          7569159n     198412Ki    14.358s
modeler-websockets-9bf764f5f-bjxlf      4692460n     86264Ki     10.865s
```

new external endpoints:

- postgresql cluster
- helix keycloak
- helix elasticsearch (improve security)

package dependencies:

- Camunda 8 Zeebe (standalone, no dependencies but elasticsearch)
- Camunda 8 Microservices (Camunda 8 Zeebe, keycloak)
- Camunda 8 Webmodeler (Camunda 8 Microservices, postgresql)

## List of persistent volumes

```bash

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                      STORAGECLASS   REASON   AGE
pvc-0214662c-06e0-47fb-8b6f-a70a4b405378   32Gi       RWO            Delete           Bound    camunda8-dev/data-camunda-zeebe-2                          default                 9d
pvc-5b6e3bcc-4638-4e6d-9bf2-32512d8af593   32Gi       RWO            Delete           Bound    camunda8-dev/data-camunda-zeebe-1                          default                 9d
pvc-9c82d26f-c8a9-40e1-96f6-3cd21b8a3cea   32Gi       RWO            Delete           Bound    camunda8-dev/data-camunda-zeebe-0                          default                 9d
pvc-a9c80f79-364e-43fc-b262-81e07a4451be   8Gi        RWO            Delete           Bound    camunda8-dev/data-camunda-postgresql-0                     default                 9d
pvc-acd14d75-b0cb-4300-aa86-2c98c0af722d   64Gi       RWO            Delete           Bound    camunda8-dev/elasticsearch-master-elasticsearch-master-0   default                 9d
pvc-c183191c-5153-4d9b-a10d-97a6cfc29634   8Gi        RWO            Delete           Bound    camunda8-dev/data-modeler-db-0                             default                 9d
pvc-e1d5f423-280c-4679-9fed-ea535c1391ff   64Gi       RWO            Delete           Bound    camunda8-dev/elasticsearch-master-elasticsearch-master-1   default                 9d
```



