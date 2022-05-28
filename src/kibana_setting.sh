curl -H "kbn-xsrf: reporting" -H 'Content-Type: application/json' -X PUT "http://localhost:5601/api/spaces/space/default" -d '
{
"id": "default",
"name": "Default",
"disabledFeatures": ["apm","maps","canvas","infrastructure","logs","siem","uptime","monitoring","dev_tools","ml","graph"]
}
'