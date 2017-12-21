oc new-build --binary=true --name=integration-app fis-java-openshift
oc new-app mes/integration-app --name=integration-app --allow-missing-imagestream-tags=true