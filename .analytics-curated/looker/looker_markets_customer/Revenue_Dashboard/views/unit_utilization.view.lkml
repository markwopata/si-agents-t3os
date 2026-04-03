view: unit_utilization {
  sql_table_name: "ANALYTICS"."UTILIZATION"."UNIT_UTILIZATION"
    ;;

  dimension: asset_total_180 {
    type: number
    sql: ${TABLE}."ASSET_TOTAL_180" ;;
  }

  dimension: asset_total_30 {
    type: number
    sql: ${TABLE}."ASSET_TOTAL_30" ;;
  }

  dimension: asset_total_365 {
    type: number
    sql: ${TABLE}."ASSET_TOTAL_365" ;;
  }

  dimension: asset_total_60 {
    type: number
    sql: ${TABLE}."ASSET_TOTAL_60" ;;
  }

  dimension: asset_total_90 {
    type: number
    sql: ${TABLE}."ASSET_TOTAL_90" ;;
  }

  dimension: current_total_assets {
    type: number
    sql: ${TABLE}."CURRENT_TOTAL_ASSETS" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: oec_180 {
    type: number
    sql: ${TABLE}."OEC_TOTAL_180" ;;
  }

  dimension: oec_30 {
    type: number
    sql: ${TABLE}."OEC_TOTAL_30" ;;
  }

  dimension: oec_365 {
    type: number
    sql: ${TABLE}."OEC_TOTAL_365" ;;
  }

  dimension: oec_60 {
    type: number
    sql: ${TABLE}."OEC_TOTAL_60" ;;
  }

  dimension: oec_90 {
    type: number
    sql: ${TABLE}."OEC_TOTAL_90" ;;
  }

  dimension: oec_utilization_180 {
    type: number
    sql: ${TABLE}."OEC_UTILIZATION_180" ;;
  }

  dimension: oec_utilization_30 {
    type: number
    sql: ${TABLE}."OEC_UTILIZATION_30" ;;
  }

  dimension: oec_utilization_365 {
    type: number
    sql: ${TABLE}."OEC_UTILIZATION_365" ;;
  }

  dimension: oec_utilization_60 {
    type: number
    sql: ${TABLE}."OEC_UTILIZATION_60" ;;
  }

  dimension: oec_utilization_90 {
    type: number
    sql: ${TABLE}."OEC_UTILIZATION_90" ;;
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

  dimension: unit_utilization_180 {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION_180" ;;
  }

  dimension: unit_utilization_30 {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION_30" ;;
  }

  dimension: unit_utilization_365 {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION_365" ;;
  }

  dimension: unit_utilization_60 {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION_60" ;;
  }

  dimension: unit_utilization_90 {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION_90" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: pkey {
    hidden: yes
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ${rental_branch_id}) ;;
  }

  # - - - - - MEASURES - - - - -

  # Asset totals
  measure: asset_count_30 {
    type: sum
    sql: ${asset_total_30} ;;
    drill_fields: [period_30_detail*]
  }
  measure: asset_count_60 {
    type: sum
    sql: ${asset_total_60} ;;
    drill_fields: [period_60_detail*]
  }
  measure: asset_count_90 {
    type: sum
    sql: ${asset_total_90} ;;
    drill_fields: [period_90_detail*]
  }
  measure: asset_count_180 {
    type: sum
    sql: ${asset_total_180} ;;
    drill_fields: [period_180_detail*]
  }
  measure: asset_count_365 {
    type: sum
    sql: ${asset_total_365} ;;
    drill_fields: [period_365_detail*]
  }
  measure: total_assets {
    type: sum
    sql: ${current_total_assets} ;;
  }

  # OEC Total
  measure: oec_total_30 {
    type: sum
    value_format_name: usd_0
    sql: ${oec_30} ;;
    drill_fields: [period_30_detail*]
  }
  measure: oec_total_60 {
    type: sum
    value_format_name: usd_0
    sql: ${oec_60} ;;
    drill_fields: [period_60_detail*]
  }
  measure: oec_total_90 {
    type: sum
    value_format_name: usd_0
    sql: ${oec_90} ;;
    drill_fields: [period_90_detail*]
  }
  measure: oec_total_180 {
    type: sum
    value_format_name: usd_0
    sql: ${oec_180} ;;
    drill_fields: [period_180_detail*]
  }
  measure: oec_total_365 {
    type: sum
    value_format_name: usd_0
    sql: ${oec_365} ;;
    drill_fields: [period_365_detail*]
  }

  # OEC Utilization
  measure: avg_oec_util_30 {
    type: average
    value_format_name: percent_1
    sql: ${oec_utilization_30} ;;
    drill_fields: [period_30_detail*]
  }
  measure: avg_oec_util_60 {
    type: average
    value_format_name: percent_1
    sql: ${oec_utilization_60} ;;
    drill_fields: [period_60_detail*]
  }
  measure: avg_oec_util_90 {
    type: average
    value_format_name: percent_1
    sql: ${oec_utilization_90} ;;
    drill_fields: [period_90_detail*]
  }
  measure: avg_oec_util_180 {
    type: average
    value_format_name: percent_1
    sql: ${oec_utilization_180} ;;
    drill_fields: [period_180_detail*]
  }
  measure: avg_oec_util_365 {
    type: average
    value_format_name: percent_1
    sql: ${oec_utilization_365} ;;
    drill_fields: [period_365_detail*]
  }

  # Unit Utilization
  measure: avg_unit_util_30 {
    type: average
    value_format_name: percent_1
    sql: ${unit_utilization_30} ;;
    drill_fields: [period_30_detail*]
  }
  measure: avg_unit_util_60 {
    type: average
    value_format_name: percent_1
    sql: ${unit_utilization_60} ;;
    drill_fields: [period_60_detail*]
  }
  measure: avg_unit_util_90 {
    type: average
    value_format_name: percent_1
    sql: ${unit_utilization_90} ;;
    drill_fields: [period_90_detail*]
  }
  measure: avg_unit_util_180 {
    type: average
    value_format_name: percent_1
    sql: ${unit_utilization_180} ;;
    drill_fields: [period_180_detail*]
  }
  measure: avg_unit_util_365 {
    type: average
    value_format_name: percent_1
    sql: ${unit_utilization_365} ;;
    drill_fields: [period_365_detail*]
  }

  measure: count {
    type: count
    drill_fields: []
  }

  set: period_30_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_oec_util_30, avg_unit_util_30]
  }

  set: period_60_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_oec_util_60, avg_unit_util_60]
  }

  set: period_90_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_oec_util_90, avg_unit_util_90]
  }

  set: period_180_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_oec_util_180, avg_unit_util_180]
  }

  set: period_365_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, avg_oec_util_365, avg_unit_util_365]
  }
}
