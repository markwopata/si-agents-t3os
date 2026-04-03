view: commission_rate_tiers {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."COMMISSION_RATE_TIERS" ;;

  # Dimensions
  dimension: rate_tier_id {
    type: string
    sql: ${TABLE}."RATE_TIER_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: commission_percentage {
    type: string
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }


 }
