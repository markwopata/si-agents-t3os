view: arc_equip_assignments_rollup_market {
derived_table: {
  sql:
 select
    c.date,
    c.market_id,
    COALESCE(COUNT(distinct c.company_id),0) as actively_renting_customers,
    COALESCE(SUM(c.oec),0) as oec_on_rent_sum,
    COALESCE(COUNT(distinct c.asset_id),0) as assets_on_rent_sum
    FROM business_intelligence.triage.stg_bi__daily_actively_renting_customers c
    GROUP BY c.date, c.market_id ;;

}

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month {
    group_label: "HTML Formatted Date"
    label: "Month Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${date_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: actively_renting_customers {
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
  }

  measure: avg_arc {
    label: "Average Actively Renting Customers"
    type: number
    sql: SUM(${actively_renting_customers})/ COUNT(DISTINCT ${date_date}) ;;
    value_format_name: decimal_1
  }

  measure: max_arc {
    label: "Max Actively Renting Customers"
    type: max
    sql: ${actively_renting_customers} ;;
  }


}
