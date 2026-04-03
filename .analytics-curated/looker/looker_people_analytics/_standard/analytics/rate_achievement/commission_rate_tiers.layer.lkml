include: "/_base/analytics/rate_achievement/commission_rate_tiers.view.lkml"

view: +commission_rate_tiers {
  label: "Commission Rate Tiers"

  dimension: commission_percentage {
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
    value_format: "0.0%"
  }

}
