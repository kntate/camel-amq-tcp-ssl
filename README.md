# Camel TCP+SSL application publishing messages in a AMQ Broker in Openshift

This shows how to connect a external application (outside Openshift) to an A-MQ xPaaS message broker inside Openshift.

Doc: https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html-single/red_hat_jboss_a-mq_for_openshift/

### Building

The example can be built with

    mvn --settings configuration/settings.xml clean install

After it you can exec the application using (Note: OpenShift AMQ must be running)

    mvn --settings configuration/settings.xml spring-boot:run

### Running the example in OpenShift

#### AMQ Install

a) connect to mes project
```
$ oc login https://via.us.lmco.com:8443 --token=<token>
$ oc project mes
```

b) generate self signed certs (or use the certs in the certs directory)
```
$ keytool -genkey -alias broker -keyalg RSA -keystore broker.ks
$ keytool -export -alias broker -keystore broker.ks -file broker_cert
$ keytool -genkey -alias client -keyalg RSA -keystore client.ks
$ keytool -import -alias broker -keystore client.ts -file broker_cert
```

c) create OpenShift secrets
```
$ echo '{"kind": "ServiceAccount", "apiVersion": "v1", "metadata": {"name": "amq-service-account"}}' | oc create -f -
$ oc policy add-role-to-user view system:serviceaccount:mes:amq-service-account
$ oc secrets new amq-secret broker.ks client.ts
$ oc secrets add sa/amq-service-account secret/amq-secret
```

e) Use the  amq62-persistent-ssl.yml file in certs directory to create an AMQ service
```
$ oc process -f amq62-persistent-ssl.yml --param APPLICATION_NAME=broker --param MQ_PROTOCOL=openwire --param MQ_USERNAME=redhat --param MQ_PASSWORD=redhat --param AMQ_SECRET=amq-secret --param AMQ_TRUSTSTORE=client.ts --param AMQ_TRUSTSTORE_PASSWORD=password --param AMQ_KEYSTORE=broker.ks --param AMQ_KEYSTORE_PASSWORD=password --param AMQ_MESH_DISCOVERY_TYPE=kube --param IMAGE_STREAM_NAMESPACE=openshift --param AMQ_STORAGE_USAGE_LIMIT="100 gb" | oc create -f -e) Use the  amq62-persistent-ssl to create an AMQ service
```

#### Openshift Setup                                                                                                                                                                                                                                                                                                                                                                                                                                                                        oc process -f amq62-persistent-ssl --param APPLICATION_NAME=broker --param MQ_PROTOCOL=openwire --param MQ_USERNAME=redhat --param MQ_PASSWORD=redhat --param AMQ_SECRET=amq-secret --param AMQ_TRUSTSTORE=client.ts --param AMQ_TRUSTSTORE_PASSWORD=password --param AMQ_KEYSTORE=broker.ks --param AMQ_KEYSTORE_PASSWORD=password --param AMQ_MESH_DISCOVERY_TYPE=kube --param IMAGE_STREAM_NAMESPACE=openshift --param AMQ_STORAGE_USAGE_LIMIT="100 gb" | oc create -f -

Create a new binary build inside OpenShift

```
$ oc new-build --binary=true --name=integration-app fis-java-openshift
```

#### Openshift Deploy

To deploy a new version of the application, run a maven build then start an OpenShift binary build with the Spring Boot fat jar.

```
$ mvn --settings configuration/settings.xml install
$ oc start-build integration-app --from-file=./target/integration-app-1.0.jar --follow
```

If you ever want to delete the application you can run the following.

```
$ oc delete svc,dc,bc,is integration-app
```

    


