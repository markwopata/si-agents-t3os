view: keys_to_success {
  derived_table: {
    sql:
WITH charge_grouping AS (SELECT MKT_ID,
                                DATE_TRUNC('MONTH', GL_DATE)                                           AS month_date,
                                ACCTNO,
                                TYPE,
                                ROUND(SUM(CASE WHEN ACCTNO = '6308' THEN AMT ELSE 0 END), 2)           AS maintenance_costs,
                                ROUND(SUM(CASE WHEN TYPE = 'Service Revenues' THEN AMT ELSE 0 END), 2) AS service_revenue,
                                ROUND(SUM(CASE WHEN TYPE = 'Cost of Service Revenues' THEN AMT ELSE 0 END),
                                      2)                                                               AS cost_of_service_revenues
                         FROM ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP bes
                         WHERE ACCTNO IN ('6308')
                            OR TYPE IN ('Service Revenues', 'Cost of Service Revenues')
                         GROUP BY MKT_ID, DATE_TRUNC('MONTH', GL_DATE), ACCTNO, TYPE)
   , pl_aggregates AS (SELECT MKT_ID,
                              month_date,
                              SUM(maintenance_costs)        AS maintenance_costs,
                              SUM(service_revenue)          AS service_revenue,
                              SUM(cost_of_service_revenues) AS cost_of_service_revenues
                       FROM charge_grouping
                       GROUP BY MKT_ID, month_date)
SELECT hlf.pk_high_level_financials_id,
       hlf.gl_date,
       hlf.market_id,
       hlf.market_name,
       hlf.district,
       hlf.region_name,
       hlf.oec,
       hlf.on_rent_oec,
       hlf.unavailable_oec,
       hlf.rental_revenue,
       hlf.delivery_revenue,
       hlf.nonintercompany_delivery_revenue,
       hlf.delivery_expense,
       hlf.sales_revenue,
       hlf.sales_expense,
       hlf.sales_gross_profit,
       hlf.total_revenue,
       hlf.payroll_compensation_expense,
       hlf.payroll_wage_expense,
       hlf.payroll_overtime_expense,
       hlf.outside_hauling_expense,
       hlf.net_income,
       hlf.average_discount_numerator,
       hlf.average_discount_denominator,
       hlf.service_total_oec,
       hlf.service_unavailable_oec,
       hlf.unassigned_hours_pct,
       hlf.month_rank,
       LAG(hlf.month_rank, 1) OVER (PARTITION BY hlf.market_id ORDER BY hlf.gl_date) AS last_month_rank,
       pla.service_revenue,
       pla.maintenance_costs,
       pla.cost_of_service_revenues
FROM analytics.branch_earnings.high_level_financials AS hlf
         LEFT JOIN pl_aggregates pla
                   ON hlf.market_id = pla.MKT_ID
                       AND DATE_TRUNC('MONTH', hlf.gl_date) = pla.month_date
where date_trunc(month, gl_date) in (
  select
  trunc::date
  from
  analytics.gs.plexi_periods
  where {% condition period_name %} display {% endcondition %})
    ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods_published
    suggest_dimension: plexi_periods_published.display
  }

  dimension: pk_high_level_financials_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK_HIGH_LEVEL_FINANCIALS_ID" ;;
  }

  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_name
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_district
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_name
  }

  measure: oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: most_recent_selected_period_oec {
    type: sum
    label: "OEC"
    value_format: "$#,##0;-$#,##0;-"
    sql: CASE
          WHEN ${plexi_periods_published.date} = (
                select max(${plexi_periods_published.date}) from "ANALYTICS"."GS"."PLEXI_PERIODS"
                where {% condition period_name %} DISPLAY {% endcondition %}
              )
          THEN ${TABLE}."OEC"
          ELSE NULL
        END ;;
  }

  measure: on_rent_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."ON_RENT_OEC" ;;
  }

  measure: unavailable_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
  }

  measure: rental_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: delivery_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."DELIVERY_REVENUE" ;;
  }

  measure: nonintercompany_delivery_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."NONINTERCOMPANY_DELIVERY_REVENUE" ;;
  }

  measure: delivery_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."DELIVERY_EXPENSE" ;;
  }

  measure: sales_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SALES_REVENUE" ;;
  }

  measure: sales_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SALES_EXPENSE" ;;
  }

  measure: sales_gross_profit {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SALES_GROSS_PROFIT" ;;
  }

  measure: total_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: payroll_compensation_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."PAYROLL_COMPENSATION_EXPENSE" ;;
  }

  measure: payroll_wage_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."PAYROLL_WAGE_EXPENSE" ;;
  }

  measure: payroll_overtime_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."PAYROLL_OVERTIME_EXPENSE" ;;
  }

  measure: outside_hauling_expense {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OUTSIDE_HAULING_EXPENSE" ;;
  }

  measure: net_income {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."NET_INCOME" ;;
  }

  measure: average_discount_numerator {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."AVERAGE_DISCOUNT_NUMERATOR" ;;
  }

  measure: average_discount_denominator {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."AVERAGE_DISCOUNT_DENOMINATOR" ;;
  }

  measure: service_total_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SERVICE_TOTAL_OEC" ;;
  }

  measure: service_unavailable_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SERVICE_UNAVAILABLE_OEC" ;;
  }

  measure: unassigned_hours_pct {
    type: average
    label: "Unassigned Tech Hours %"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${TABLE}."UNASSIGNED_HOURS_PCT" ;;
  }

  dimension: month_rank {
    type: number
    sql: ${TABLE}."MONTH_RANK" ;;
  }

  dimension: last_month_rank {
    type: number
    sql: ${TABLE}."LAST_MONTH_RANK" ;;
  }


  # Metrics for the High Level Financials Dashboard
  measure: average_discount_percent {
    type: number
    label: "Average Discount"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${average_discount_denominator} = 0 then 0 else ${average_discount_numerator} / ${average_discount_denominator} end ;;
  }

  measure: unavailable_oec_percent {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${oec} = 0 then 0 else ${unavailable_oec} / ${oec} end ;;
  }

  measure: service_unavailable_oec_percent {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${service_total_oec} = 0 then 0 else ${service_unavailable_oec} / ${service_total_oec} end ;;
  }

  measure: financial_utilization {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when ${oec} = 0 then 0 else ${rental_revenue} * 12 / ${oec} end;;
  }

  measure: rental_revenue_to_oec {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when ${oec} = 0 then 0 else ${rental_revenue} / ${oec} end;;
  }

  measure: total_labor_percent_of_rent_revenue {
    type: number
    label: "Payroll to Rental Revenue"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rental_revenue} = 0 then 0 else ${payroll_compensation_expense} / ${rental_revenue} end ;;
  }

  measure: overtime_percent_of_total_labor {
    type: number
    label: "Overtime to Total Wages"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${payroll_compensation_expense} = 0 then 0 else ${payroll_overtime_expense} / ${payroll_compensation_expense} end ;;
  }

  measure: delivery_recovery_percent {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${delivery_expense} = 0 then 0 else ${nonintercompany_delivery_revenue} / ${delivery_expense} end  ;;
  }

  measure: net_income_percent_of_total_revenue {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_revenue} = 0 then 0 else ${net_income} / ${total_revenue} end ;;
  }

  measure: unavailable_oec_percent_with_service_unavailable {
    type: number
    label: "Unavailable OEC % (SD %)"
    sql: ${unavailable_oec_percent} ;;
    html: {{ unavailable_oec_percent._rendered_value }} ({{ service_unavailable_oec_percent._rendered_value }}) ;;
  }

  measure: count {
    type: count
    drill_fields: [period_name, market_name]
  }

  measure: maintenance_costs {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."MAINTENANCE_COSTS" ;;
  }

  measure: service_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SERVICE_REVENUE" ;;
  }

  measure: cost_of_service_revenues {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."COST_OF_SERVICE_REVENUES" ;;
  }
}
