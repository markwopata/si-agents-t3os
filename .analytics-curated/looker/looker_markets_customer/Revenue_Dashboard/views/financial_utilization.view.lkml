view: financial_utilization {
  sql_table_name: "UTILIZATION"."FINANCIAL_UTILIZATION"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: fin_util_180 {
    type: number
    sql: ${TABLE}."FIN_UTIL_180" ;;
  }

  dimension: fin_util_30 {
    type: number
    sql: ${TABLE}."FIN_UTIL_30" ;;
  }

  dimension: fin_util_365 {
    type: number
    sql: ${TABLE}."FIN_UTIL_365" ;;
  }

  dimension: fin_util_60 {
    type: number
    sql: ${TABLE}."FIN_UTIL_60" ;;
  }

  dimension: fin_util_90 {
    type: number
    sql: ${TABLE}."FIN_UTIL_90" ;;
  }

  dimension: parent_category {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: pkey {
    hidden: yes
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ${rental_branch_id}) ;;
  }

  # - - - - - MEASURES - - - - -

  measure: avg_fin_util_30 {
    type: average
    value_format_name: percent_1
    sql: ${fin_util_30} ;;
    drill_fields: [period_30_detail*]
  }
  measure: avg_fin_util_60 {
    type: average
    value_format_name: percent_1
    sql: ${fin_util_60} ;;
    drill_fields: [period_60_detail*]
  }
  measure: avg_fin_util_90 {
    type: average
    value_format_name: percent_1
    sql: ${fin_util_90} ;;
    drill_fields: [period_90_detail*]
  }
  measure: avg_fin_util_180 {
    type: average
    value_format_name: percent_1
    sql: ${fin_util_180} ;;
    drill_fields: [period_180_detail*]
  }
  measure: avg_fin_util_365 {
    type: average
    value_format_name: percent_1
    sql: ${fin_util_365} ;;
    drill_fields: [period_365_detail*]
  }

  measure: count {
    type: count
    drill_fields: []
  }

  set: period_30_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_fin_util_30]
  }

  set: period_60_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_fin_util_60]
  }

  set: period_90_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_fin_util_90]
  }

  set: period_180_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_fin_util_180]
  }

  set: period_365_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_fin_util_365]
  }
}
