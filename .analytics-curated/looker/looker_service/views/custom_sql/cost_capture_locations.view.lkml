view: cost_capture_locations {
  derived_table: {
    sql: with store_info as (
          select
              re.parent_id,
              re.object_id,
              s.branch_id,
              s.name as store_name
          from
             ES_WAREHOUSE.inventory.inventory_locations s
             join ES_WAREHOUSE.inventory.resources re
                 on s.branch_id = re.object_id
                     and s.date_archived is null
                     and s.company_id = 1854
                     and s.default_location = TRUE
                     and re.resource_type_id = 5
          )
          , region_info as (
          select
              resource_id,
              r.name as region_name
          from
              ES_WAREHOUSE.inventory.resources re
              left join ES_WAREHOUSE.inventory.regions r on r.region_id = re.object_id
          where
              resource_type_id = 3
          )
          select
              region_name,
              store_name
          from
              store_info si
              left join region_info ri on si.parent_id = ri.resource_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }

  set: detail {
    fields: [region_name, store_name]
  }
}
