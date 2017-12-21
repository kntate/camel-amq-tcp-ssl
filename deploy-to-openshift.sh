mvn --settings configuration/settings.xml install
oc start-build integration-app --from-file=./target/integration-app-1.0.jar --follow
