view: materials_payroll {
  # # You can specify the table name if it's different from the view name:
  derived_table: {
    sql:
      select
          market_id,
          market_name,
          date_trunc('month',entry_date) as entry_month,
          sum(-1 * amount) as payroll_amount
      from analytics.materials.int_materials_payroll
      group by all;;
  }

  # # Define your dimensions and measures here, like this:
  dimension: pk_derived {
    primary_key: yes
    hidden: yes
    description: "Unique ID for each line"
    type: number
    sql:
     ${TABLE}.market_id::varchar || '|' ||
     to_char(${TABLE}.entry_month, 'YYYY-MM-DD') || '|' ||
     ${TABLE}.market_name::varchar ;;
  }



  dimension: market_id {
    description: "market id for individual market"
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    description: "Market Name"
    type: string
    sql: ${TABLE}.market_name ;;
  }

  measure: payroll_amount_sum {
    description: "total amount of payroll"
    type: sum
    sql: ${TABLE}."PAYROLL_AMOUNT" ;;
  }

  measure: payroll_amount_number {
    description: "total amount of payroll"
    type: number
    sql: ${TABLE}."PAYROLL_AMOUNT" ;;
  }

  measure: payroll_to_revenue {
    description: "payroll divided by revenue"
    type: number
    sql: round(DIV0NULL(${payroll_amount_sum},${materials_dashboard.total_amount})*100,2) ;;
  }


  dimension: entry_month{
    description: "date of journal entry"
    type: date
    sql: ${TABLE}.entry_month ;;
  }


}
