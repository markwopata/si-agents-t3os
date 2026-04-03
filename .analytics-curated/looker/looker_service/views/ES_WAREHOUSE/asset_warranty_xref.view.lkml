view: asset_warranty_xref {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSET_WARRANTY_XREF" ;;
  drill_fields: [asset_warranty_xref_id]

  dimension: asset_warranty_xref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_WARRANTY_XREF_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: warranty_id {
    type: number
    sql: ${TABLE}."WARRANTY_ID" ;;
  }
  measure: warranties {
    type: list
    list_field: warranty_id
  }
  measure: warranty_count {
    type: count_distinct
    sql: ${warranty_id} ;;
  }
  measure: under_warranty {
    type: yesno
    sql: iff(${warranty_count} is null,false,true) ;;
  }
  # measure: has_flex_50 {
  #   type: sum
  #   sql: iff(${warranty_id}=900,1,0) ;;
  # }
  # measure: flex_50_flag {
  #   type: yesno
  #   sql: iff(${has_flex_50}>0,true,false) ;;
  # }
  dimension: flex50flag {
    label: "Flex 50"
    type: string
    case: {
      when: {
        sql: ${TABLE}."WARRANTY_ID" = 900 ;;
        label: "Yes"
      }
      else: "No"
    }
  }
  measure: count {
    type: count
    drill_fields: [asset_warranty_xref_id]
  }
}

view: asset_under_warranty {
  derived_table: {
    sql:
      select
        a.asset_id,
        a.maintenance_group_id,
        listagg(iff(awx.date_deleted is null,awx.warranty_id,null),', ') as active_warranties,
        listagg(iff(awx.date_deleted is not null,awx.warranty_id,null),', ') as expired_warranties,
        iff(active_warranties = '' and expired_warranties = '',false,true) as has_warranty
      from es_warehouse.public.assets a
      left join es_warehouse.public.asset_warranty_xref awx
        on a.asset_id = awx.asset_id
      group by a.asset_id,a.maintenance_group_id ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
    value_format: "0"
  }
  dimension: maintenacne_group_yn {
    type: yesno
    sql: iff(${maintenance_group_id} is null,false,true) ;;
  }
  dimension: active_warranties {
    type: string
    sql: ${TABLE}."ACTIVE_WARRANTIES" ;;
  }
  dimension: under_active_warranties {
    type: yesno
    sql: iff(${active_warranties} = '',false,true) ;;
  }
  dimension: expired_warranties {
    type: string
    sql: ${TABLE}."EXPIRED_WARRANTIES" ;;
  }
  dimension: under_expired_warranties {
    type: yesno
    sql: iff(${expired_warranties} = '',false,true) ;;
  }
  dimension: under_warranty {
    type: yesno
    sql: ${TABLE}."HAS_WARRANTY" ;;
  }
  measure: asset_count_warranty {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [under_warranty: "YES"]
  }
  measure: perc_asset_count_warranty {
    type: number
    sql: ${asset_count_warranty} / ${maintenance_group_interval_study.count_by_company} ;;
    value_format: "0.00%"
  }
  measure: asset_count_mg_and_active_warranty {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [under_active_warranties: "Yes",maintenacne_group_yn: "Yes"]
  }
  measure: perc_asset_count_mg_and_active_warranty {
    type: number
    sql: ${asset_count_mg_and_active_warranty} / ${maintenance_group_interval_study.count_by_company} ;;
    value_format: "0.00%"
  }
  measure: asset_count_mg_and_expired_warranty {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [under_expired_warranties: "Yes",maintenacne_group_yn: "Yes"]
  }
  measure: perc_asset_count_mg_and_expired_warranty {
    type: number
    sql: ${asset_count_mg_and_expired_warranty} / ${maintenance_group_interval_study.count_by_company} ;;
    value_format: "0.00%"
  }
}
