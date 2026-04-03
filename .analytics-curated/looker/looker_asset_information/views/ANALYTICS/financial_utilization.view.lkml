view: financial_utilization {
  sql_table_name: "ANALYTICS"."PUBLIC"."FINANCIAL_UTILIZATION"
    ;;

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ' ', ${market_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: rental_rev {
    type: number
    sql: ${TABLE}."RENTAL_REV" ;;
  }

  measure: rental_revenue {
    type: sum
    sql: ${rental_rev} ;;
  }

  measure: ttl_oec {
    type: sum
    sql: ${oec} ;;
  }

  measure: fin_util {
    type: number
    label: "Financial Utilization"
    value_format: "0.0%"
    sql: ${rental_revenue} * 365 / 31 / case when ${ttl_oec} = 0 then null else ${ttl_oec} end ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_id, rental_branch_id, class, rental_rev, oec]
  }
}
