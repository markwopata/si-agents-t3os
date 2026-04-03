view: engine_serial_plate_added_process {
 derived_table: {
   sql: with oa_add as (
  select PARAMETERS:work_order_id work_order_id
           ,PARAMETERS:tag_name tag_name
           ,COMMAND
           ,PARAMETERS
           ,DATE_CREATED
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT
    where COMMAND in ('AssociateCompanyTag','CreateAndAssociateCompanyTag')
        and  PARAMETERS:tag_name ilike '%ENGINE SERIAL NEEDED%'
        and user_id = 301047 --richelle nixon, currently running the script. when this automatic will it have a new user id?
  )
  select  wo.asset_id
           , ca.DATE_CREATED
           , iff(oa.work_order_id is not null,'OA Prompt','Other') process_flag
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    left join oa_add oa
    on ca.PARAMETERS:work_order_id=oa.work_order_id
    and ca.date_created>=oa.date_created
    join es_warehouse.work_orders.work_orders wo
    on ca.PARAMETERS:work_order_id=wo.work_order_id
    where ca.COMMAND in ('AssociateCompanyTag','CreateAndAssociateCompanyTag')
        and  ca.PARAMETERS:tag_name ilike '%ENGINE SERIAL PLATE ADDED%'
        qualify min(ca.date_created) over (partition by ca.PARAMETERS:work_order_id)=ca.date_created ;;
 }

dimension: asset_id {
  type: string
  primary_key: yes
  sql: ${TABLE}."ASSET_ID" ;;
}

  dimension_group: date_tagged {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: process_flag {
    type: string
    sql: ${TABLE}."PROCESS_FLAG" ;;
  }

  measure: distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
  }
}
