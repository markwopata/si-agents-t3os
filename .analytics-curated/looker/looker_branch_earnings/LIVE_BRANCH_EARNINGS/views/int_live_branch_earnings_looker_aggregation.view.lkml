view: int_live_branch_earnings_looker_aggregation {
  sql_table_name: "BRANCH_EARNINGS"."INT_LIVE_BRANCH_EARNINGS_LOOKER_AGGREGATION" ;;

  dimension: account_category {
    type: string
    sql: TRIM(${TABLE}."ACCOUNT_CATEGORY") ;; # optional but helps whitespace issues
    order_by_field: category_sort_order

    # Keep your wide cell formatting
    html: <div style="width:500px">{{ rendered_value }}</div> ;;

    link: {
      label: "Cycle Report"
      url: "{% if value == 'Rental Revenues' %}@{db_cycle_report}?Market={{ _filters['market_name'] | url_encode }}&Region={{ _filters['region_name'] | url_encode }}&District={{ _filters['district'] | url_encode }}&Market+Type={{ _filters['market_type'] | url_encode }}{% endif %}"
    }
  }

  dimension: account_category_id {
    type: number
    sql: ${TABLE}."ACCOUNT_CATEGORY_ID" ;;
    order_by_field: category_sort_order
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: category_sort_order {
    type: number
    sql: ${TABLE}."CATEGORY_SORT_ORDER" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: gl_month {
    type: string
    sql: ${TABLE}."GL_MONTH" ;;
  }
  measure: inventory_bulk_part_expense_to_rental_revenue_ratio{
    type: number
    sql: case when ${total_rental_revenue} != 0
            then abs(${total_inventory_bulk_part_expense}) / ${total_rental_revenue}
            else 0 end;;
  }
  dimension: is_overtime_wage {
    type: yesno
    sql: ${TABLE}."IS_OVERTIME_WAGE" ;;
  }
  dimension: market_greater_than_12_months {
    type: yesno
    sql: ${TABLE}."MARKET_GREATER_THAN_12_MONTHS" ;;
  }
  dimension: admin_only_data {
    type: yesno
    sql: ${TABLE}."ADMIN_ONLY_DATA" ;;
  }
  measure: total_overtime_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_OVERTIME_WAGE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  dimension: is_payroll_expense {
    type: yesno
    sql: ${TABLE}."IS_PAYROLL_EXPENSE" ;;
  }
  measure: total_payroll_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_PAYROLL_EXPENSE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  measure: overtime_to_payroll_ratio {
    type: number
    sql: case when ${total_payroll_expense} != 0
            then abs(${total_overtime_expense}) / abs(${total_payroll_expense})
            else 0 end;;
  }
  dimension: is_paid_delivery_revenue {
    type: yesno
    sql: ${TABLE}."IS_PAID_DELIVERY_REVENUE" ;;
  }
  measure: total_delivery_revenue {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_PAID_DELIVERY_REVENUE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  dimension: is_delivery_expense_account {
    type: yesno
    sql: ${TABLE}."IS_DELIVERY_EXPENSE_ACCOUNT" ;;
  }
  measure: total_delivery_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_DELIVERY_EXPENSE_ACCOUNT" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  measure: delivery_ratio {
    type: number
    sql: case when ${total_delivery_expense} != 0
            then ${total_delivery_revenue} / abs(${total_delivery_expense})
            else 0 end;;
  }
  dimension: filter_month {
    type: string
    sql: ${TABLE}."FILTER_MONTH" ;;
    order_by_field: gl_month
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  measure: original_equipment_cost {
    type: sum
    sql:  ${TABLE}."ORIGINAL_EQUIPMENT_COST" ;;
    value_format_name: usd_0
  }

  measure: original_equipment_cost_with_link {
    type: sum
    sql:  ${TABLE}."ORIGINAL_EQUIPMENT_COST" ;;
    value_format_name: usd_0
    link: {
      label: "View Detail"
      url: "@{db_oec_detail}?Period={{ _filters['filter_month'] | url_encode }}&Market+Name={{ _filters['market_name'] | url_encode }}&Region+Name={{ _filters['region_name'] | url_encode }}&District+Number={{ _filters['district'] | url_encode }}&Market+Type={{ _filters['market_type'] | url_encode }}&Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ _filters['market_greater_than_12_months'] | url_encode }}"
    }
  }
  measure: rental_revenue_to_oec_ratio{
    type: number
    sql: case when ${original_equipment_cost} != 0
            then ${total_rental_revenue} / ${original_equipment_cost}
            else 0 end;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  measure: payroll_to_rental_revenue_ratio{
    type: number
    sql: case when ${total_rental_revenue} != 0
            then abs(${total_payroll_expense}) / ${total_rental_revenue}
            else 0 end;;
  }
  dimension: revenue_expense {
    type: string
    sql: ${TABLE}."REVENUE_EXPENSE" ;;
  }
  dimension: segment {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  measure: previous_month_total_amount {
    type: sum
    sql:  ${TABLE}."PREVIOUS_MONTH_AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: static_same_month_total_amount {
    type: sum
    sql:  ${TABLE}."STATIC_SAME_MONTH_AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: total_amount {
    type: sum
    sql:  ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
    link: {
      label: "View Detail"
      url: "@{db_live_branch_earnings_detail}?Period={{ _filters['filter_month'] | url_encode }}&Account%20Number={{ account_number | url_encode }}&Account%20Category={{ account_category | url_encode }}&Market%20Name={{ _filters['market_name'] | url_encode }}&Market+Greater+Than+12+Months+%28Yes+%2F+No%29={{ _filters['market_greater_than_12_months'] | url_encode }}&Region%20Name={{ _filters['region_name'] | url_encode }}&District={{ _filters['district'] | url_encode }}"
    }
  }

  measure: previous_month_difference {
    type: sum
    sql:  coalesce(${TABLE}."AMOUNT",0) - coalesce(${TABLE}."PREVIOUS_MONTH_AMOUNT", 0) ;;
    value_format_name: usd_0
  }

  measure: total_revenue {
    type: sum
    sql:  iff(${revenue_expense} = 'revenue', ${TABLE}."AMOUNT", 0);;

    value_format_name: usd_0
    }

  measure: total_amount_no_link {
    type: sum
    sql:  ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: total_rental_revenue {
    type: sum
    sql: CASE WHEN ${TABLE}."ACCOUNT_CATEGORY_ID" = 1 THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  measure: total_inventory_bulk_part_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."ACCOUNT_NUMBER" in ('6330', 'GDDA') THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  measure: total_amount_investigation {
    type: sum
    sql:  ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
    link: {
      label: "View Dashboard"
      url: "@{db_live_branch_earnings_detail}?Period={{ _filters['filter_month'] | url_encode }}&Account%20Name={{ account_name | url_encode }}&Account%20Category={{ account_category | url_encode }}&Market%20Name={{ _filters['market_name'] | url_encode }}&Market+Greater+Than+12+Months+%28Yes+%2F+No%29={{ _filters['market_greater_than_12_months'] | url_encode }}&Region%20Name={{ _filters['region_name'] | url_encode }}&District={{ _filters['district'] | url_encode }}"
    }
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}.district in ({{ _user_attributes['district'] }}) OR ${TABLE}.region_name in ({{ _user_attributes['region'] }}) OR ${TABLE}.market_id in ({{ _user_attributes['market_id'] }}) ;;
  }

  # measure: total_amount_by_category {
  #   type: sum
  #   sql: SUM(${TABLE}."AMOUNT") OVER (PARTITION BY ${account_category}) ;;
  #   value_format_name: usd_0
  # }

  # measure: total_previous_amount_by_category {
  #   type: sum
  #   sql: SUM(${TABLE}."PREVIOUS_MONTH_AMOUNT") OVER (PARTITION BY ${account_category}) ;;
  #   value_format_name: usd_0
  # }
  # measure: percent_change {
  #   type: number
  #   sql: CASE WHEN ${total_previous_amount_by_category} != 0 THEN ( (${total_amount_by_category} - ${total_previous_amount_by_category}) / ${total_previous_amount_by_category} ) ELSE NULL END ;;
  #   value_format_name: percent_2
  # }
  # dimension: revenue_expense_type {
  #   type: string
  #   sql: MAX(${revenue_expense}) ;;
  # }
  # measure: category_percent_change {
  #   type: number
  #   sql:
  #   CASE
  #     WHEN SUM(${TABLE}.PREVIOUS_MONTH_AMOUNT) != 0
  #     THEN (SUM(${TABLE}.AMOUNT) - SUM(${TABLE}.PREVIOUS_MONTH_AMOUNT)) / SUM(${TABLE}.PREVIOUS_MONTH_AMOUNT)
  #     ELSE NULL
  #   END ;;
  #   value_format_name: percent_2
  # }
  # dimension: account_category_with_arrow {
  #   type: string
  #   sql: ${account_category};;
  #   html:
  #   {% assign total_amount = total_amount_by_category._value | times: 1.0 %}
  #   {% assign total_previous_amount = total_previous_amount_by_category._value | times: 1.0 %}
  #   {% assign percent_change = 0 %}
  #   {% if total_previous_amount != 0 %}
  #     {% assign difference = total_amount | minus: total_previous_amount %}
  #     {% assign percent_change = difference | divided_by: total_previous_amount | times: 100 %}
  #   {% endif %}

  #   {{ account_category._rendered_value }}
  #   {% if revenue_expense_type._value == 'revenue' and percent_change > 0 %}
  #       <span style="color: green; font-size: 10px;">&#9650;</span>
  #   {% elsif revenue_expense_type._value == 'revenue' and percent_change < 0 %}
  #       <span style="color: red; font-size: 10px;">&#9660;</span>
  #   {% elsif revenue_expense_type._value == 'expense' and percent_change > 0 %}
  #       <span style="color: red; font-size: 10px;">&#9650;</span>
  #   {% elsif revenue_expense_type._value == 'expense' and percent_change < 0 %}
  #       <span style="color: green; font-size: 10px;">&#9660;</span>
  #   {% else %}
  #     <span style="color: gray; font-size: 10px;">&#8212;</span>
  #   {% endif %};;
  #   order_by_field: category_sort_order
  # }
}
