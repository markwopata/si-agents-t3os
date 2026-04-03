  view: engine_active {

    derived_table: {
      sql:
      SELECT  distinct asset_id
from ES_WAREHOUSE."PUBLIC".asset_status_key_values
where lower(name)  like '%engine_active%'
and lower(value)  like '%true%'
                         ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}.asset_id ;;
    }}
