view: branch_erp_refs {
  sql_table_name: "PUBLIC"."BRANCH_ERP_REFS"
    ;;
  drill_fields: [branch_erp_refs_id]

  dimension: branch_erp_refs_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BRANCH_ERP_REFS_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }

  dimension: intacct_department_id {
    type: string
    sql: ${TABLE}."INTACCT_DEPARTMENT_ID" ;;
  }

  dimension: intacct_location_id {
    type: string
    sql: ${TABLE}."INTACCT_LOCATION_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [branch_erp_refs_id]
  }
}
