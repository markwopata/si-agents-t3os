include: "/_base/analytics/payroll/pa_market_access.view.lkml"

view: +pa_market_access {
  label: "PA Market Access"

  dimension: market_access_email {
    sql: ${market_access_emails} ;;
  }
  dimension: market_id {
    value_format_name: id
  }
  measure: count {
    type: count
  }
}
