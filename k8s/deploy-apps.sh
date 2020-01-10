
oc login https://api.cluster-madrid-808a.madrid-808a.example.opentlc.com:6443 -u opentlc-mgr -p r3dh4t1!

echo "###############################"
echo "#### Deploying Quarkus Native #"
echo "###############################"
export NAMESPACE=quarkus-native-fruits-app

echo "# Create Namespace"
oc create namespace $NAMESPACE
echo "# Deploy Postgresql"
oc -n $NAMESPACE apply -f postgresql.yaml
echo "# Wait for Postgresql deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/postgresql
echo "# Deploy Fruits App"
oc -n $NAMESPACE apply -f quarkus-fruits-app-native.yaml
echo "# Wait for Quarkus app deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/quarkus-native-fruits
echo "# Expose service quarkus-native-fruits"
oc -n $NAMESPACE expose service quarkus-native-fruits
echo " "
echo " "


echo "###############################"
echo "#### Deploying Quarkus JVM #"
echo "###############################"

export NAMESPACE=quarkus-jvm-fruits-app
echo "# Create Namespace"
oc create namespace $NAMESPACE
echo "# Deploy Postgresql"
oc -n $NAMESPACE apply -f postgresql.yaml
echo "# Wait for Postgresql deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/postgresql
echo "# Deploy Fruits App"
oc -n $NAMESPACE apply -f quarkus-fruits-app-jvm.yaml
echo "# Wait for Quarkus app deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/quarkus-jvm-fruits
echo "# Expose service quarkus-jvm-fruits"
oc -n $NAMESPACE expose service quarkus-jvm-fruits
echo " "
echo " "

echo "###############################"
echo "#### Deploying Springboot JVM #"
echo "###############################"

export NAMESPACE=springboot-jvm-fruits-app
echo "# Create Namespace"
oc create namespace $NAMESPACE
echo "# Deploy Postgresql"
oc -n $NAMESPACE apply -f postgresql.yaml
echo "# Wait for Postgresql deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/postgresql
echo "# Deploy Fruits App"
oc -n $NAMESPACE apply -f springboot-fruits-app-jvm.yaml
echo "# Wait for Quarkus app deployment to be ready"
oc -n $NAMESPACE wait --timeout=300s --for=condition=available deployment/springboot-jvm-fruits
echo "# Expose service springboot-jvm-fruits"
oc -n $NAMESPACE expose service springboot-jvm-fruits
echo " "
echo " "


echo "########################"
echo "#### Delete"
echo "########################"
#oc delete all --all
#oc delete project springboot-jvm-fruits-app
#oc delete project quarkus-jvm-fruits-app
#oc delete project quarkus-native-fruits-app
#cd .. && rm -rf test