view: executive_summary {
  derived_table: {
    sql:
    select
      case
        when coalesce({% parameter region_granularity %},'company') = 'region' then hlfs.region_name
        when coalesce({% parameter region_granularity %},'company') = 'district' then hlfs.district
        when coalesce({% parameter region_granularity %},'company') = 'market' then hlfs.market_name
        else 'Total Company'
      end grouping,
      case
        when coalesce({% parameter granularity %},'month') = 'year' then left(hlfs.gl_date,4)
        when coalesce({% parameter granularity %},'month') = 'quarter' then left(hlfs.gl_date,4) || 'Q' || date_part(quarter, hlfs.gl_date::date)
        else left(hlfs.gl_date,7)
      end period,
      case
        when hlfs.gl_date = case when coalesce({% parameter granularity %},'month') = 'year' then max(hlfs.gl_date) over (partition by date_trunc(year, hlfs.gl_date))
                            when coalesce({% parameter granularity %},'month') = 'quarter' then max(hlfs.gl_date) over (partition by date_trunc('quarter', hlfs.gl_date))
                            else hlfs.gl_date end
            then hlfs.oec
        else 0
      end oec_for_utilization,
      case
        when coalesce({% parameter granularity %},'month') = 'year' then 12 / count(distinct hlfs.gl_date) over (partition by date_trunc(year, hlfs.gl_date))
        when coalesce({% parameter granularity %},'month') = 'quarter' then 12 / count(distinct hlfs.gl_date) over (partition by date_trunc(quarter, hlfs.gl_date))
        else 12
      end * hlfs.rental_revenue annualized_rental_revenue,
      hlfs.*
    from
      analytics.branch_earnings.high_level_financials hlfs
    where
      1=1
      and gl_date >= coalesce({% parameter start_date %}::date, '2021-01-01'::date)
      and gl_date < add_months(date_trunc(month, coalesce({% parameter end_date %}::date, '2050-01-01'::date)), 1)
    ;;
  }

  dimension: pk_high_level_financials_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK_HIGH_LEVEL_FINANCIALS_ID" ;;
  }

  parameter: start_date {
    type: date
  }

  parameter: end_date {
    type: date
  }

  parameter: granularity {
    description: "Group data in this dashboard at either a month or quarter granularity"
    allowed_value: {
      label: "Month"
      value: "month"
    }
    allowed_value: {
      label: "Quarter"
      value: "quarter"
    }
    allowed_value: {
      label: "Year"
      value: "year"
    }
  }

  parameter: region_granularity {
    description: "Segment data by region, district, or total company"
    allowed_value: {
      label: "Region"
      value: "region"
    }
    allowed_value: {
      label: "District"
      value: "district"
    }
    allowed_value: {
      label: "Market"
      value: "market"
    }
    allowed_value: {
      label: "Company"
      value: "company"
    }
  }

  measure: total_oec_raw {
    type: sum
    hidden: yes
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OEC" ;;
  }


  measure: service_total_oec {
    type: sum
    hidden: yes
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SERVICE_TOTAL_OEC" ;;
  }

  measure: total_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:
      CASE
        WHEN {{ granularity._parameter_value }} = 'month'
          THEN ${TABLE}."OEC"
        WHEN {{ granularity._parameter_value }} = 'quarter'
          THEN ${TABLE}."OEC" / 3
        ELSE
          ${TABLE}."OEC" / 12
      END ;;
  }

  measure: oec_for_utilization {
    type: sum
    hidden: yes
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OEC_FOR_UTILIZATION" ;;
  }

  measure: rental_revenue {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: annualized_rental_revenue {
    type: sum
    hidden: yes
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."ANNUALIZED_RENTAL_REVENUE" ;;
  }

  measure: delivery_revenue {
    type: sum
    sql: ${TABLE}."NONINTERCOMPANY_DELIVERY_REVENUE" ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: delivery_expense {
    type: sum
    sql: ${TABLE}."DELIVERY_EXPENSE" ;;
  }

  measure: total_compensation {
    type: sum
    sql: ${TABLE}."PAYROLL_COMPENSATION_EXPENSE" ;;
  }

  measure: wages {
    type: sum
    sql: ${TABLE}."PAYROLL_WAGE_EXPENSE" ;;
  }

  measure: overtime {
    type: sum
    sql: ${TABLE}."PAYROLL_OVERTIME_EXPENSE" ;;
  }

  measure: outside_hauling {
    type: sum
    sql: ${TABLE}."OUTSIDE_HAULING_EXPENSE" ;;
  }

  measure: rental_fleet_oec_daily_sum {
    type: sum
    sql: ${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM" ;;
  }

  measure: oec_on_rent_daily_sum {
    type: sum
    sql: ${TABLE}."OEC_ON_RENT_DAILY_SUM" ;;
  }

  measure: unavailable_oec_daily_sum {
    type: sum
    sql: ${TABLE}."UNAVAILABLE_OEC_DAILY_SUM" ;;
  }

  measure: financial_utilization {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    # TODO 12 should depend on month vs quarter
    sql:  case when ${rental_fleet_oec_daily_sum} = 0 then 0 else (${rental_revenue} * 365) / ${rental_fleet_oec_daily_sum} end;;
  }

  measure: delivery_recovery {
    label: "Delivery Recovery %"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${delivery_expense} = 0 then 0 else ${delivery_revenue} / ${delivery_expense} end  ;;
  }

  measure: labor_to_rental_revenue {
    label: "Total Labor % of Rent Revenue"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rental_revenue} = 0 then 0 else ${total_compensation} / ${rental_revenue} end ;;
  }

  measure: overtime_percent {
    label: "Overtime % of Total Labor"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${wages} = 0 then 0 else ${overtime} / ${wages} end ;;
  }


  measure: net_income  {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:  ${TABLE}."NET_INCOME" ;;
  }

  measure: net_income_margin {
    label: "Net Income Margin"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when ${total_revenue} = 0 then 0 else ${net_income} / ${total_revenue} end ;;
  }

  dimension: gl_date {
    type: date
    label: "GL Date"
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: grouping {
    type: string
    sql: ${TABLE}."GROUPING" ;;
    link: {
      label: "Branch Earnings Dashbboard"
      url: " {% if _filters['executive_summary.region_granularity'] == 'market' %}
      @{db_branch_earnings_dashboard}?Market+Name={{ filterable_value }}&toggle=det
      {% elsif _filters['executive_summary.region_granularity'] == 'region'  %}
      @{db_branch_earnings_dashboard}?Region+Name={{ filterable_value }}&toggle=det
      {% elsif _filters['executive_summary.region_granularity'] == 'district'  %}
      @{db_branch_earnings_dashboard}?District+Number={{ filterable_value }}&toggle=det
      {% else %}
      @{db_branch_earnings_dashboard}
      {% endif %}"

    }
    link: {
      label: "High Level Financials Dashbboard"
      url: "{% if _filters['executive_summary.region_granularity'] == 'market' %}
      @{db_district_region_manager_directory}?Market+Name={{ filterable_value }}&toggle=det
      {% elsif _filters['executive_summary.region_granularity'] == 'region'  %}
      @{db_district_region_manager_directory}?Region+Name={{ filterable_value }}&toggle=det
      {% elsif _filters['executive_summary.region_granularity'] == 'district'  %}
      @{db_district_region_manager_directory}?District={{ filterable_value }}&toggle=det
       {% else %}
      @{db_district_region_manager_directory}
      {% endif %}"
    }
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension_group: gl_date {
    type: time
    timeframes: [month, quarter, year, raw]
    label: "GL Date"
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_name
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT";;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_district
  }

  dimension: region_name {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.region_name
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${gl_date})+1 ;;
    #was using plexi_periods.trunc for dynamic date but switched back to current date - also removed the +1 to make months_open closer
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  measure: unavailable_oec {
    label: "Unavailable OEC"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SERVICE_UNAVAILABLE_OEC" ;;
  }

  measure: unavailable_oec_percent {
    label: "Unavailable OEC %"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${service_total_oec} = 0 then 0 else ${unavailable_oec_daily_sum} / ${rental_fleet_oec_daily_sum} end  ;;

  }

  measure: on_rent_oec {
    label: "On Rent OEC"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."ON_RENT_OEC" ;;

  }

  measure: on_rent_oec_percent {
    label: "On Rent OEC %"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rental_fleet_oec_daily_sum} = 0 then 0 else ${oec_on_rent_daily_sum} / ${rental_fleet_oec_daily_sum} end ;;
  }

  measure: average_discount_numerator {
    type: sum
    hidden: yes
    sql: ${TABLE}."AVERAGE_DISCOUNT_NUMERATOR" ;;
  }

  measure: average_discount_denominator {
    type: sum
    hidden: yes
    sql: ${TABLE}."AVERAGE_DISCOUNT_DENOMINATOR" ;;
  }

  measure: percent_discount_average {
    label: "Average Discount Rate"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${average_discount_denominator} = 0 then 0 else ${average_discount_numerator} / ${average_discount_denominator} end  ;;
  }

  measure: unassigned_hours {
    type: average
    #value_format: "#,##0.00;(#,##0.00);-"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${TABLE}."UNASSIGNED_HOURS_PCT"  ;;
  }

  measure: sales_revenue {
    label: "Sales Revenue"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SALES_REVENUE" ;;
  }

  measure: sales_expense {
    label: "Sales Expense"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."SALES_EXPENSE" ;;
  }

  measure: sales_profit {
    type: number
    value_format: "$#,##0;-$#,##0;-"
    sql: ${sales_revenue} - ${sales_expense} ;;
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

  measure: payroll_to_oec {
    type: number
    label: "Payroll to OEC"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_oec} = 0 then 0 else (${wages} - ${non_es_reg_wages} - ${non_es_ot_wages}) / ${total_oec} end ;;
  }

  measure: payroll_to_rental_revenue {
    type: number
    label: "Payroll to Rental Revenue"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${total_oec} = 0 then 0 when ${rental_revenue} = 0 then 0 else (${wages} - ${non_es_reg_wages} - ${non_es_ot_wages}) / ${rental_revenue} end ;;
  }

  measure: annualized_payroll_to_oec {
    type: number
    label: "Annualized Payroll to OEC"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:
    CASE
        WHEN {{ granularity._parameter_value }} = 'month'
          THEN case when ${total_oec} = 0 then 0 else (12 * (${wages} - ${non_es_reg_wages} - ${non_es_ot_wages})) / ${total_oec} end
        WHEN {{ granularity._parameter_value }} = 'quarter'
          THEN case when ${total_oec} = 0 then 0 else (4 * (${wages} - ${non_es_reg_wages} - ${non_es_ot_wages})) / ${total_oec} end
        ELSE
          case when ${total_oec} = 0 then 0 else (${wages} - ${non_es_reg_wages} - ${non_es_ot_wages}) / ${total_oec} end
      END;;
  }

  measure: site_count {
    type: sum
    sql:
      CASE
        WHEN {{ granularity._parameter_value }} = 'month'
          THEN case when ${months_open} > 0 then 1 else 0 end
        WHEN {{ granularity._parameter_value }} = 'quarter'
          THEN ceil(case when ${months_open} > 0 then 1 else 0 end / 3)
        ELSE
          ceil(case when ${months_open} > 0 then 1 else 0 end / 12)
      END
      ;;
  }

  measure: count {
    type: count
    drill_fields: [gl_date, market_name]
  }
}
