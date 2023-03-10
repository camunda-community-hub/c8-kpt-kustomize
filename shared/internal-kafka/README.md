NAME: kafka-1676936615
LAST DEPLOYED: Tue Feb 21 00:43:37 2023
NAMESPACE: camunda8-dev
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kafka
CHART VERSION: 21.0.1
APP VERSION: 3.4.0

** Please be patient while the chart is being deployed **

Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:

    kafka-1676936615.camunda8-dev.svc.cluster.local

Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    kafka-1676936615-0.kafka-1676936615-headless.camunda8-dev.svc.cluster.local:9092

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run kafka-1676936615-client --restart='Never' --image docker.io/bitnami/kafka:3.4.0-debian-11-r2 --namespace camunda8-dev --command -- sleep infinity
    kubectl exec --tty -i kafka-1676936615-client --namespace camunda8-dev -- bash

    PRODUCER:
        kafka-console-producer.sh \
            --broker-list kafka-1676936615-0.kafka-1676936615-headless.camunda8-dev.svc.cluster.local:9092 \
            --topic test

    CONSUMER:
        kafka-console-consumer.sh \
            --bootstrap-server kafka-1676936615.camunda8-dev.svc.cluster.local:9092 \
            --topic test \
            --from-beginning

