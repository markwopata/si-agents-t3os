### Deprecated Tables in es_warehouse.public

| Source           | Table                   | Previous DBT Model Name                     | Deprecation Reason                                               | Model to Use Instead               |
|------------------|--------------------------|---------------------------------------------|-------------------------------------------------------------------|------------------------------------|
| es_warehouse.public        | time_tracking_entities        | stg_es_warehouse_public__time_tracking_entities         | Empty      | analytics.intacct_models.stg_es_warehouse_time_tracking__time_entries |
| es_warehouse.public        | regions        | stg_es_warehouse_public__regions         | Better model available      | analytics.intacct_models.stg_analytics_public__regions|
| es_warehouse.public        | districts        | stg_es_warehouse_public__districts         | Better model available (has district_id column)    | analytics.intacct_models.stg_analytics_public__districts|