#!/bin/bash

# This will create a Sonarqube deployment and service

cat <<EOF | kubectl apply -f- -n "${tns}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
spec:
  selector:
    matchLabels:
      app: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
    spec:
      containers:
      - name: sonarqube
        image: sonarqube
        ports:
        - containerPort: 9000
EOF

kubectl -n "${tns}" wait --for=condition=available --timeout=600s deployment/sonarqube
kubectl -n "${tns}" expose deployment sonarqube --target-port=9000

add_task git-clone latest
