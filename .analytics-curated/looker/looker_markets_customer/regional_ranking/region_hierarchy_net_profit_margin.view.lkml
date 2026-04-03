
view: region_hierarchy_net_profit_margin {
  derived_table: {
    sql:with max_update_date as (
      select
          max(hlfs.gl_date) as max_date
      from
          analytics.branch_earnings.high_level_financials hlfs
          JOIN analytics.gs.plexi_periods pp on pp.trunc::date = hlfs.gl_date::date
      where
          period_published = 'published'
      )

      select
          hlfs.region_name as region,
          hlfs.district,
          hlfs.market_name as market,
          hlfs.market_id,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
        --  mop.months_open_over_12,
          hlfs.total_revenue as total_rev,
          hlfs.net_income,
          mud.max_date,
          mrx.is_open_over_12_months as is_current_months_open_greater_than_twelve
      from
          max_update_date mud
          JOIN analytics.branch_earnings.high_level_financials hlfs on hlfs.gl_date = mud.max_date
          LEFT JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = hlfs.market_id
   --   left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
    --  group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
    --        on vmt.market_id = hlfs.market_id
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  dimension: net_income {
    type: number
    sql: ${TABLE}."NET_INCOME" ;;
  }

  dimension_group: max_date {
    type: time
    sql: ${TABLE}."MAX_DATE" ;;
  }

  dimension: entry_start_date {
    group_label: "HTML Formatted Time"
    label: "Last Update Date"
    type: date
    sql: ${max_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_revenue {
    type: sum
    sql: ${total_rev} ;;
    value_format: "$#,##0;($#,##0);-"
  }

  measure: total_net_income {
    type: sum
    sql: ${net_income} ;;
    value_format: "$#,##0;($#,##0);-"
  }

  measure: net_profit_margin {
    type: number
    sql: IFF(${total_revenue} > 0,${total_net_income}/${total_revenue},0)  ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
        region,
  district,
  market,
  market_type,
  total_rev,
  net_income
    ]
  }
}
