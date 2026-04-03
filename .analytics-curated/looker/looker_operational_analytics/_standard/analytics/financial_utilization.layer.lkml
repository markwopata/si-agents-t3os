include: "/_base/analytics/public/financial_utilization.view.lkml"

view: +financial_utilization {
  label: "Financial Utilization"

  dimension: custom_primary_key {
    type: string
    sql: concat(${asset_id},' - ',zeroifnull(${market_id})) ;;
    primary_key: yes
  }

  measure: sum_rental_rev {
    type: sum
    sql: ${rental_rev} ;;
  }

  measure: sum_oec {
    type: sum
    sql: ${oec} ;;
  }

  measure: finacial_utilization {
    type: number
    sql: ${sum_rental_rev} * 365 / 31 / nullifzero(${sum_oec}) ;;
    value_format_name: percent_2
  }
}
