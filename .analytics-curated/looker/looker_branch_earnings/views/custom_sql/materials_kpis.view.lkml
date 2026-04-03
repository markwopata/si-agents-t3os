view: materials_kpis {
  # # You can specify the table name if it's different from the view name:
   sql_table_name: analytics.materials.int_materials_kpi ;;
  #
  # # Define your dimensions and measures here, like this:

   dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: concat(${TABLE}.mkt_id,${TABLE}.be_month) ;;
  }


   dimension: mkt_name {
     description: "market name"
     type: string
     sql: ${TABLE}.mkt_name ;;
    }

   dimension: mkt_id {
     description: "market_id"
     type: number
     sql:  ${TABLE}.mkt_id ;;
   }

   dimension: be_month {
     description: "month"
     type: date_month
     sql:  ${TABLE}.be_month ;;
   }

  measure: manager {
    description: "manager"
    type: string
    sql:   MAX_BY(${TABLE}.manager, ${TABLE}.be_month);;
  }

   measure: net_income {
     description: "net income"
     type: sum
    value_format_name: usd_0
     sql: ${TABLE}.net_income ;;
   }

   measure: revenue {
     description: "revenue"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.revenue ;;
  }

  measure: number_of_orders {
    description: "number of orders"
    type: sum
    sql: ${TABLE}.number_of_orders ;;
  }

  measure: total_order_amount {
    description: "total order amount"
    type: sum
    sql: ${TABLE}.total_order_amount ;;
  }

  measure: average_order_value {
    description: "average order value"
    type: average
    value_format_name: usd_0
    sql:  COALESCE(${TABLE}.total_order_amount/NULLIF(${TABLE}.number_of_orders,0),0) ;;
  }



  measure: ar_running_total {
    description: "accounts receivable "
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.revenue ;;
  }

  measure: days_sales_outstanding {
    description: "days sales outstanding"
    type: average
    value_format: "0"
    sql: ${TABLE}.ar_running_total/NULLIF(${TABLE}.revenue,0) * ${TABLE}.days_in_month ;;
  }

  measure: days_in_month{
    description: "days_in_month"
    type: sum
    sql: ${TABLE}.days_in_month ;;
  }

  measure: inventory_amount {
    description: "inventory_amount"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.inventory_amount ;;
  }

  measure: avg_last_2mo_running_total {
    description: "inventory_running_total"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.avg_last_2mo_running_total ;;
  }

  measure: total_payroll {
    description: "total_payroll"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.total_payroll ;;
  }

  measure: payroll_to_revenue_ratio {
    description: "payroll_to_revenue_ratio"
    type: average
    value_format_name: percent_2
    sql: COALESCE((-1*${TABLE}.total_payroll)/NULLIF(${TABLE}.revenue,0),0) ;;
  }

  measure: square_footage {
    description: "square_footage"
    type: sum
    sql: ${TABLE}.square_footage ;;
  }

  measure: inventory_turnover_ratio {
    description: "Inventory Turnover Ratio"
    type: average
    value_format_name: decimal_2
    sql: (-1*${TABLE}.cogs/NULLIF(${TABLE}.avg_last_2mo_running_total,0)) * 12 ;;
  }


  measure: sales_per_sq_ft {
    description: "sales per square foot"
    type: average
    value_format_name: usd_0
    sql: COALESCE(${TABLE}.revenue/NULLIF(${TABLE}.square_footage,0),0) ;;
  }

  measure: net_income_pct {
    description: "net income percentage"
    type: average
    value_format_name: percent_2
    sql: COALESCE(${TABLE}.net_income/NULLIF(${TABLE}.revenue,0),0) ;;
  }

  measure: employee_count {
    description: "employee_count"
    type: sum
    sql: ${TABLE}.employee_count ;;
  }

  measure: sales_per_employee {
    description: "sales per employee"
    type: average
    value_format_name: usd_0
    sql:  COALESCE(${TABLE}.revenue/NULLIF(${TABLE}.employee_count,0),0) ;;
  }

  measure: months_open {
    description: "how many month Market has been a Forge and Build location"
    type: average
    value_format_name: decimal_0
    sql: ${TABLE}.months_open;;
  }




}
