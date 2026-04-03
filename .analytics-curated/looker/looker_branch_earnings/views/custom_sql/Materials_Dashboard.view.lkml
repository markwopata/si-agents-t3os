view: materials_dashboard {
  derived_table: {
    sql:
        with materials as (
          select *
          from analytics.materials.int_revenue_cost

          union all

          select
            bt_branch_id,
            market_id,
            null as line_id,
            null as header_id,
            null as header_number,
            description,
            0    as unit_amount,
            0    as total_cost,
            total_amount,
            0    as total_tax,
            0    as total_margin,
            datetime_created,
            0    as quantity,
            null as product_id,
            null as rev_gl_code,
            null as exp_gl_code,
            line_type,
            market_name,
            null as bt_start_date
          from analytics.materials.int_pre_acquisition_revenue)

      select  materials.*,
              mrx.current_months_open,
              mrx.district
      from materials
      join  analytics.public.market_region_xwalk mrx
        on materials.market_id = mrx.market_id;;

  }

  dimension: current_months_open {
    type: number
    sql:  ${TABLE}.current_months_open ;;
  }

  dimension: district {
    type: string
    sql:  ${TABLE}.district ;;
  }

  dimension: market_name {
    type: string
    sql:  ${TABLE}.market_name ;;
  }

  dimension: market_id {
    type: number
    sql:  ${TABLE}.market_id ;;
  }

  dimension: bt_branch_id {
    type: number
    value_format_name: id
    sql:  ${TABLE}.bt_branch_id ;;
  }

  dimension: line_id {
    type: string
    value_format_name: id
    sql:  ${TABLE}.line_id ;;
  }

  dimension: header_id {
    type: string
    value_format_name: id
    sql:  ${TABLE}.header_id ;;
  }

  dimension: header_number {
    type: string
    value_format_name: id
    sql:  ${TABLE}.header_id ;;
  }

  dimension: description {
    type: string
    sql:  ${TABLE}.description ;;
  }

  measure: unit_amount {
    type: sum
    value_format_name: usd
    sql:  ${TABLE}.unit_amount ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: usd
    sql:  ${TABLE}.total_cost ;;
  }

  measure: total_amount {
    type: sum
    value_format_name: usd
    sql:  ${TABLE}."TOTAL_AMOUNT" ;;
  }

  measure: total_amount_number {
    type: number
    value_format_name: usd
    sql:  ${TABLE}."TOTAL_AMOUNT" ;;
  }

  measure: total_tax {
    type: sum
    value_format_name: usd
    sql:  ${TABLE}.total_tax ;;
  }

  dimension: total_margin {
    type: number
    sql:  ${TABLE}.total_margin ;;
  }

  dimension_group: datetime_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.datetime_created;;
  }

  dimension: line_type {
    type:  string
  }

  dimension: is_bisTrack{
    type: string
    sql:
    CASE
      WHEN ${TABLE}.bt_branch_id < 0 THEN 'No'
      ELSE 'Yes'
    END ;;
  }

  measure: last_month_revenue {
    type: sum
    sql: ${TABLE}.total_amount ;;
    # previous full calendar month
    filters: [datetime_created_date: "last month"]
    value_format_name: usd
  }

  measure: current_month_revenue {
    type: sum
    sql: ${TABLE}.total_amount ;;
    filters: [datetime_created_date: "this month"]
    value_format_name: usd
  }
  measure: running_total_current_month {
    type: number
    sql:
    SUM(${current_month_revenue}) OVER (
      PARTITION BY DATE_TRUNC('month', CAST(${TABLE}.datetime_created AS DATE))
      ORDER BY CAST(${TABLE}.datetime_created AS DATE))
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) ;;
    value_format_name: decimal_2
  }

  measure: running_total_prior_month {
    type: number
    sql:
    SUM(${last_month_revenue}) OVER (
      PARTITION BY DATE_TRUNC('month', CAST(${TABLE}.datetime_created AS DATE))
      ORDER BY CAST(${TABLE}.datetime_created AS DATE))
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) ;;
    value_format_name: decimal_2
  }
}
