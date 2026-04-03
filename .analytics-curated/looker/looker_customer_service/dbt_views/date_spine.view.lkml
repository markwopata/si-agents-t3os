view: date_spine {
  sql_table_name: business_intelligence.gold.dim_dates_bi;;

  dimension: dt_date {
    label: "Date"
    primary_key: yes
    type: date
    sql: ${TABLE}.dt_date ;;
  }
}
