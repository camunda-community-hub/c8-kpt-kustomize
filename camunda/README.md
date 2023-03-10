# Camunda 8 Platform Microservices

A set of microservices are providing an easy access layer to zeebe and elasticsearch data and processes.

[Identity](./identity/README.md) is basically a wrapper around keycloak (and thus a hard dependency for IAM solutions). It provides a user friendly administration of users and permissions in an opiniated way. Identity has a startup/synch task setting up and maintaining a realm for the camunda system: all needed clients and users are created. This setup is defined in template files that are customizable.

[Operate](./operate/README.md) is a view on running and historized workflow processes. It enables the user to inspect the process context.

[Tasklist](./tasklist/README.md) is a dashboard for tracking open human tasks per user. The user can be notified per mail as well.

[Optimize](./optimize/README.md) is a monitoring and data analyzing frontend (diagrams look similar to Kibana).

[Connectors](./connectors/README.md) are the out of the box connectors provided by camunda together with some hints to use the Connectors SDK.