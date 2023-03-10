modeler-websockets (also referred as pusher host in the config) is a PHP implementation of a websockets server.

This time we took the easy way out and deactivated SSL checks completely.

We encountered a second challenge with the websockets protocol (http.1) over Istio. Istio switches aggressively to http2 causing errors. With the [modeler-websockets-envoy-filter.yaml](modeler-websockets-envoy-filter.yaml) the envoy proxy configuration of the websockets pod can be tweaked to enforce http.1 in all cases.