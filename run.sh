#! /bin/bash
read -rsp 'Password: ' ES_PASS

echo " "
echo "**********************"
echo "Starting td-agent."
echo "**********************"
systemctl restart td-agent.service
systemctl status td-agent.service

echo " "
echo "**********************"
echo "Starting elasticsearch."
echo "**********************"
systemctl start elasticsearch.service
sleep 60
systemctl status elasticsearch.service

curl --cacert /etc/elasticsearch/certs/ca/ca.crt  -u elastic:$ES_PASS -H "Content-Type: application/json" -XPOST https://localhost:9200/_security/user/kibana_system/_password -d'
{
  "password" : "kibana_pw"
}'

echo " "
echo "**********************"
echo "Starting Kibana."
echo "**********************"
systemctl start kibana.service
sleep 60
systemctl status kibana.service

echo " "
echo "**********************"
echo "completed."
echo "**********************"