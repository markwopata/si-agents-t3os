view: rolling_achieved_rates {
sql_table_name: ANALYTICS.RATE_ACHIEVEMENT.ACHIEVED_RATES_BY_REGION ;;














dimension: equipment_class_id {

  type: number
  sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
  value_format_name: id


}


dimension: region_name {

  type: string
  sql: ${TABLE}.REGION_NAME ;;


}

dimension: regional_achieved_rate_90d {

  type: number
  sql: ${TABLE}.ROLLING_90_DAY_AVG ;;
  value_format_name: usd_0


}


}
