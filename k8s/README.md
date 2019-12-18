# Deploy Fruits Apps on K8s

Below steps will deploy a Postgresql and the fruits apps (Native and JVM) into a given namespace. 

You can expose the svc using an `Ingress` or changing the svc type from `ClusterIP` to `LoadBalancer`.

## Deploying Quarkus Native 

~~~sh
export NAMESPACE=quarkus-native-fruits-app
# Create Namespace
kubectl create namespace $NAMESPACE
# Deploy Postgresql
kubectl -n $NAMESPACE apply -f postgresql.yaml
# Wait for Postgresql deployment to be ready
kubectl -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/postgresql
# Deploy Fruits App
kubectl -n $NAMESPACE apply -f quarkus-fruits-app-native.yaml
# Wait for Quarkus app deployment to be ready
kubectl -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/quarkus-native-fruits
~~~

## Deploying Quarkus JVM

~~~sh
export NAMESPACE=quarkus-jvm-fruits-app
# Create Namespace
kubectl create namespace $NAMESPACE
# Deploy Postgresql
kubectl -n $NAMESPACE apply -f postgresql.yaml
# Wait for Postgresql deployment to be ready
kubectl -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/postgresql
# Deploy Fruits App
kubectl -n $NAMESPACE apply -f quarkus-fruits-app-jvm.yaml
# Wait for Quarkus app deployment to be ready
kubectl -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/quarkus-jvm-fruits
~~~

