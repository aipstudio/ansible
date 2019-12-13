POST /_aliases
{
    "actions" : [
        { "add" : { "index" : "filebeat-7.4.1", "alias" : "filebeat" } }
    ]
}


PUT _template/filebeat
{
  "index_patterns": ["filebeat*"],
  "settings":
{
"number_of_replicas": "0"
}
}

PUT filebeat-7.4.1-000000001
{
  "aliases": {
    "filebeat":{
      "is_write_index": true
    }
  }
}

PUT filebeat-7.4.1-000000001/_settings
{
  "index": {
  "blocks": {
  "read_only_allow_delete": "false"
}
}
}

PUT _template/filebeat-template
{
  "index_patterns": ["filebeat-*"],
  "settings": {
    "index.lifecycle.name": "filebeat-policy",
    "index.lifecycle.rollover_alias": "filebeat"
  }
}

GET _ilm/status

GET filebeat-*/_ilm/explain

GET filebeat/_settings

GET _ilm/policy

GET _template/filebeat

GET _cluster/settings

GET /_cluster/health
