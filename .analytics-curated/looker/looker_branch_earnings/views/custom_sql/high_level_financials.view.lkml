view: high_level_financials {
  derived_table: {
    sql:
      select
          hlf.pk_high_level_financials_id,
          hlf.gl_date,
          hlf.market_id,
          hlf.market_name,
          hlf.district,
          hlf.region_name,
          hlf.general_manager_employee_id,
          hlf.general_manager_name,
          hlf.general_manager_url_greenhouse,
          hlf.general_manager_url_disc,
          hlf.general_manager_disc_code,
          hlf.general_manager_email,
          hlf.general_manager_position_effective_date,
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
          hlf.non_es_reg_wages,
          hlf.non_es_ot_wages,
          hlf.rental_fleet_oec_daily_sum,
          hlf.unavailable_oec_daily_sum,
          hlf.month_rank,
          lag(hlf.month_rank, 1) over (partition by hlf.market_id order by hlf.gl_date) as last_month_rank
      from analytics.branch_earnings.high_level_financials as hlf
      where date_trunc(month, gl_date) in (
        select
        trunc::date
        from
        analytics.gs.plexi_periods
        where {% condition period_name %} display {% endcondition %}
      )
    ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
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
    link: {
      label: "How Do I Improve?"
      url: "@{db_how_do_i_improve}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Market+Name={{ filterable_value }}&toggle=det"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Market+Name={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Market Dashboard"
      url: "@{db_market_dashboard}?Market={{ filterable_value }}"
    }
    link: {
      label: "Market Headcount Allocation"
      url: "@{db_market_headcount_allocation}?Market+Name={{ filterable_value }}&toggle=det"
    }
    link: {
      label: "Executive Summary"
      url: "@{db_executive_summary}?Market+Name={{ filterable_value }}&Region+Granularity=market&toggle=det"
    }
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_district
    link: {
      label: "How Do I Improve?"
      url: "@{db_how_do_i_improve}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Region+District={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&District+Number={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Market Dashboard"
      url: "@{db_market_dashboard}?District={{ filterable_value }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&Months+Open+Over+12+%28Yes+%2F+No%29={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Market Headcount Allocation"
      url: "@{db_market_headcount_allocation}?District+ID={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['high_level_financials.months_open_greater_than_twelve'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Executive Summary"
      url: "@{db_executive_summary}?District={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['high_level_financials.months_open_greater_than_twelve'] | url_encode }}&Region+Granularity=market&toggle=det"
    }
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_name
    link: {
      label: "How Do I Improve?"
      url: "@{db_how_do_i_improve}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Region+Name={{ filterable_value }}&&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Region+Name={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Market Dashboard"
      url: "@{db_market_dashboard}?Region={{ filterable_value }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&Months+Open+Over+12+%28Yes+%2F+No%29={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    link: {
      label: "Market Headcount Allocation"
      url: "@{db_market_headcount_allocation}?Region+Name={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['high_level_financials.months_open_greater_than_twelve'] | url_encode }}&toggle=det"
    }
  }

  dimension: general_manager_employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."GENERAL_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: general_manager_disc_code {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_DISC_CODE" ;;
  }

  dimension: general_manager_url_greenhouse {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_URL_GREENHOUSE" ;;
  }

  dimension: general_manager_url_disc {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_URL_DISC" ;;
  }

  dimension: general_manager_name {
    type: string
    label: "General Manager"
    sql: ${TABLE}."GENERAL_MANAGER_NAME" ;;
    link: {
      label: "Greenhouse Profile"
      url: "{{ general_manager_url_greenhouse }}"
    }
    link: {
      label: "DISC Profile ({{ general_manager_disc_code }})"
      url: "{{ general_manager_url_disc }}"
    }
    html: <span title={{value}}>{{linked_value}}</span> ;;
  }

  dimension: general_manager_employee_id_name {
    type: string
    label: "General Manager ID Name"
    sql: concat(${general_manager_employee_id}, '-', ${general_manager_name}) ;;
  }

  dimension: general_manager_email {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }

  dimension: general_manager_position_effective_date {
    type: string
    sql: ${TABLE}.general_manager_position_effective_date ;;
  }

  dimension: gm_months_at_location {
    type: number
    label: "GM Months in Role"
    sql:
    datediff(
      month,
      to_date(${general_manager_position_effective_date}),
      dateadd(day, 1, ${latest_plexi_period})
    )
    + 1
  ;;
  }


  measure: oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OEC" ;;
    link: {
      label: "Detail View"
      url: "@{db_oec_detail}?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
  }

  measure: most_recent_selected_period_oec {
    type: sum
    label: "OEC"
    value_format: "$#,##0;-$#,##0;-"
    sql: CASE
          WHEN ${plexi_periods.date} = (
                select max(${plexi_periods.date}) from "ANALYTICS"."GS"."PLEXI_PERIODS"
                where {% condition period_name %} DISPLAY {% endcondition %}
              )
          THEN ${TABLE}."OEC"
          ELSE NULL
        END ;;
    html:
    {% assign market_name_param = '' %}
    {% if _filters['high_level_financials.market_name'] %}
      {% assign market_name_param = _filters['high_level_financials.market_name'] | url_encode %}
    {% elsif high_level_financials.market_name._filterable_value and high_level_financials.market_name._filterable_value != "NULL" %}
      {% assign market_name_param = high_level_financials.market_name._filterable_value | url_encode %}
    {% endif %}

      {% assign district_param = '' %}
      {% if _filters['high_level_financials.district']%}
      {% assign district_param = _filters['high_level_financials.district'] | url_encode %}
      {% elsif high_level_financials.district._filterable_value and high_level_financials.district._filterable_value != "NULL" %}
      {% assign district_param = high_level_financials.district._filterable_value | url_encode %}
      {% endif %}

      {% assign mkt_type_param = '' %}
      {% if _filters['market_region_xwalk.market_type'] %}
      {% assign mkt_type_param = _filters['market_region_xwalk.market_type'] | url_encode %}
      {% elsif market_region_xwalk.market_type._filterable_value and market_region_xwalk.market_type._filterable_value != "NULL" %}
      {% assign mkt_type_param = market_region_xwalk.market_type._filterable_value | url_encode %}
      {% endif %}

      {% assign region_name_param = '' %}
      {% if _filters['market_region_xwalk.region_name'] %}
      {% assign region_name_param = _filters['market_region_xwalk.region_name'] | url_encode %}
      {% elsif market_region_xwalk.region_name._filterable_value and market_region_xwalk.region_name._filterable_value != "NULL" %}
      {% assign region_name_param = market_region_xwalk.region_name._filterable_value | url_encode %}
      {% endif %}

      <u><a href="@{db_oec_detail}?Region+Name={{ region_name_param }}&Period={{ _filters['high_level_financials.period_name'] | url_encode }}&Market+Name={{ market_name_param }}&District+Number={{ district_param }}&Market+Type={{ mkt_type_param }}&toggle=det" target="_blank">{{ linked_value }}</a></u>
      ;;
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

  measure: non_es_reg_wages {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."NON_ES_REG_WAGES" ;;
  }

  measure: non_es_ot_wages {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."NON_ES_OT_WAGES" ;;
  }

  measure: annualized_payroll_to_oec {
    type: number
    label: "Annualized Payroll to OEC"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${oec} = 0 then 0 else 12 * (${payroll_wage_expense} - ${non_es_reg_wages} - ${non_es_ot_wages}) / ${oec} end ;;
  }

  dimension: month_rank {
    type: number
    sql: ${TABLE}."MONTH_RANK" ;;
  }

  dimension: last_month_rank {
    type: number
    sql: ${TABLE}."LAST_MONTH_RANK" ;;
  }

  measure: rental_fleet_oec_daily_sum {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM" ;;
  }

  measure: unavailable_oec_daily_sum {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."UNAVAILABLE_OEC_DAILY_SUM" ;;
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
    sql: case when ${rental_fleet_oec_daily_sum} = 0 then 0 else ${unavailable_oec_daily_sum} / ${rental_fleet_oec_daily_sum} end ;;
  }

  measure: financial_utilization {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when ${rental_fleet_oec_daily_sum} = 0 then 0 else (${rental_revenue} * 365) / ${rental_fleet_oec_daily_sum} end;;
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
    sql: case when ${rental_revenue} = 0 then 0 else (${payroll_wage_expense} - ${non_es_reg_wages} - ${non_es_ot_wages}) / ${rental_revenue} end ;;
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
    label: "Net Profit Margin"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_revenue} = 0 then 0 else ${net_income} / ${total_revenue} end ;;
  }

  measure: unavailable_oec_percent_with_service_unavailable {
    type: number
    label: "Unavailable OEC %"
    sql: ${service_unavailable_oec_percent} ;;
    html: {{ service_unavailable_oec_percent._rendered_value }} ;;
  }

  dimension: latest_plexi_period {
    type: date
    sql: (select max(${plexi_periods.date}) from "ANALYTICS"."GS"."PLEXI_PERIODS"
      where {% condition period_name %} DISPLAY {% endcondition %}) ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${latest_plexi_period})+1 ;;
  }

  dimension: months_open_greater_than_twelve {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  dimension: exclude_hard_down {
    label: "Exclude Hard Down?"
    type: yesno
    sql: ${market_name} not ilike '%hard down%';;
  }

  dimension: static_months_open_greater_thank_twelve {
    label: "Static Dashboard Markets Greater Than 12 Months Open"
    type: yesno
    sql: (datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1) > 12 ;;
  }

  measure: count {
    type: count
    drill_fields: [period_name, market_name]
  }

  ### new measures added by Paul Lim (02/05/2026)
  measure: outside_hauling_to_rent {
    type: number
    label: "Outside Hauling to Rental Revenue"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_revenue} = 0 then 0 else (${outside_hauling_expense} + ${delivery_expense}) / ${total_revenue} end ;;
  }

  measure: overtime_to_revenue {
    type: number
    label: "Overtime to Revenue"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_revenue} = 0 then 0 else ${payroll_overtime_expense} / ${total_revenue} end ;;
  }

  measure: regular_time_to_revenue {
    type: number
    label: "Regular Time to Revenue"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_revenue} = 0 then 0 else ${payroll_wage_expense} / ${total_revenue} end ;;
  }




}
