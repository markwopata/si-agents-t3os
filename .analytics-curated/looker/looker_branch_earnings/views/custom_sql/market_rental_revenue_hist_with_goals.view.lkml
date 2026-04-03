view: market_rental_revenue_hist_with_goals {
  derived_table: {
    sql: WITH last_fourteen_months AS (
      SELECT series::date AS date,
             market_id
      FROM
           table(es_warehouse.public.generate_series(
           dateadd(month, -14, date_trunc(month,current_date))::timestamp_tz,
           date_trunc(month,current_date)::timestamp_tz,
           'month'))
      LEFT JOIN analytics.public.market_region_xwalk
      where division_name <> 'Materials' OR division_name IS NULL

      )
      , monthly_market_revenue AS (

      SELECT date_trunc(month, d.daily_timestamp)::DATE AS revenue_month,
      d.market_id,
      SUM(COALESCE(rental_revenue,0)) AS rental_revenue
      FROM analytics.assets.market_level_asset_metrics_daily d
      WHERE date_trunc(month, d.daily_timestamp) BETWEEN dateadd(month, -14, date_trunc(month, current_date)) AND date_trunc(month, current_date)
      GROUP BY date_trunc(month, d.daily_timestamp)::DATE, d.market_id
      )
      , monthly_market_goals AS (
      SELECT mg.MARKET_ID,
      mg.NAME,
      mg.MONTHS::date AS goal_month,
      mg.REVENUE_GOALS AS revenue_goal
      FROM ANALYTICS.PUBLIC.MARKET_GOALS mg
      WHERE MONTHS::date BETWEEN dateadd(month, -14, date_trunc(month,current_date)) AND date_trunc(month,current_date) AND mg.end_date IS NULL
      )
      SELECT lfm.date,
      mmr.MARKET_ID,
      COALESCE(mmr.rental_revenue,0) as rental_revenue,
      mmg.revenue_goal,
      CASE WHEN mmr.rental_revenue/nullifzero(mmg.revenue_goal) >= 0.9 AND mmr.rental_revenue/nullifzero(mmg.revenue_goal) < 1 THEN 'Close to Goal'
      WHEN mmr.rental_revenue/nullifzero(mmg.revenue_goal) < 0.9 THEN 'Below Goal'
      WHEN mmr.rental_revenue/nullifzero(mmg.revenue_goal) >= 1 or mmg.revenue_goal = 0 THEN 'Above Goal'
      END AS goal_met_type_flag
      FROM last_fourteen_months lfm
      LEFT JOIN monthly_market_revenue mmr ON mmr.MARKET_ID = lfm.MARKET_ID AND mmr.revenue_month = lfm.date
      LEFT JOIN monthly_market_goals mmg ON mmg.MARKET_ID = lfm.MARKET_ID AND mmg.goal_month = lfm.date

      ;;
  }

  dimension: date {
    type: date_month
    sql: ${TABLE}."DATE" ;;
  }

  dimension: month_date {
    type: date
    label: "Month"
    sql: ${TABLE}."DATE" ;;
    html: {{ value | date: "%b %Y" }};;
  }

  dimension: market_id {
    type: string
    # group_label: "Location Information"
    sql: ${TABLE}."MARKET_ID" ;;
  }


  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  dimension: revenue_goal {
    type: number
    sql: ${TABLE}."REVENUE_GOAL" ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [market_goal_drill*]
  }

  measure: total_revenue_form {
    label: "Total Revenue"
    type: number
    sql: COALESCE(SUM(${rental_revenue}),0) ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [market_goal_drill*]
  }


  measure: total_market_goal {
    type: sum
    sql: ${revenue_goal} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: goal {
    group_label: "ES"
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${revenue_goal} ;;
    drill_fields: [company_goal_drill*]
  }

  measure: perc_of_goal {
    label: "% of Goal"
    type: number
    sql: DIV0NULL(SUM(${rental_revenue}), SUM(${revenue_goal})) ;;
    value_format_name: percent_1
  }

  measure: rental_revenue_goal_met {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${total_revenue} <= 0 then ${total_revenue}
                 else null end;;
    drill_fields: [company_goal_drill*]
  }

  measure: rental_revenue_goal_unmet {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${total_revenue} > 0 then ${total_revenue}
                 else null end;;
    drill_fields: [company_goal_drill*]
  }

  measure: rental_revenue_no_goal {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_revenue}
      else null end ;;
    drill_fields: [company_goal_drill*]
  }

  measure: tot_rev_goal_above {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${total_revenue} > ${goal} THEN ${total_revenue}
                 when DIV0NULL(${total_revenue}, ${goal}) >= 1 then ${total_revenue}
                 else null end;;
    drill_fields: [company_goal_drill*]
  }

  measure: tot_rev_goal_close {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) >= 0.9 AND DIV0NULL(${total_revenue}, ${goal}) < 1 then ${total_revenue}
                 else null end;;
    drill_fields: [company_goal_drill*]
  }

  measure: tot_rev_goal_below {
    group_label: "ES"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                  when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) < 0.9 then ${total_revenue}
                 else null end;;
    drill_fields: [company_goal_drill*]
  }

  measure: goal_region {
    group_label: "Regional"
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${revenue_goal} ;;
    drill_fields: [region_goal_drill*]
  }

  measure: rental_revenue_goal_met_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${total_revenue} <= 0 then ${total_revenue}
                 else null end;;
    drill_fields: [region_goal_drill*]
  }

  measure: rental_revenue_goal_unmet_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${total_revenue} > 0 then ${total_revenue}
                 else null end;;
    drill_fields: [region_goal_drill*]
  }

  measure: rental_revenue_no_goal_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_revenue}
      else null end ;;
    drill_fields: [region_goal_drill*]
  }

  measure: tot_rev_goal_above_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${total_revenue} > ${goal} THEN ${total_revenue}
                 when DIV0NULL(${total_revenue}, ${goal}) >= 1 then ${total_revenue}
                 else null end;;
    drill_fields: [region_goal_drill*]
  }

  measure: tot_rev_goal_close_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) >= 0.9 AND DIV0NULL(${total_revenue}, ${goal}) < 1 then ${total_revenue}
                 else null end;;
    drill_fields: [region_goal_drill*]
  }

  measure: tot_rev_goal_below_region {
    group_label: "Regional"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                  when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) < 0.9 then ${total_revenue}
                 else null end;;
    drill_fields: [region_goal_drill*]
  }

  measure: goal_district {
    group_label: "District"
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${revenue_goal} ;;
    drill_fields: [district_goal_drill*]
  }

  measure: rental_revenue_goal_met_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${total_revenue} <= 0 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: rental_revenue_goal_unmet_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${total_revenue} > 0 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: rental_revenue_no_goal_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_revenue}
      else null end ;;
    drill_fields: [district_goal_drill*]
  }

  measure: tot_rev_goal_above_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${total_revenue} > ${goal} THEN ${total_revenue}
                 when DIV0NULL(${total_revenue}, ${goal}) >= 1 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: tot_rev_goal_close_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) >= 0.9 AND DIV0NULL(${total_revenue}, ${goal}) < 1 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: tot_rev_goal_below_district {
    group_label: "District"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                  when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) < 0.9 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: goal_market {
    group_label: "Market"
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${revenue_goal} ;;
    drill_fields: [market_goal_drill*]
  }

  measure: rental_revenue_goal_met_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${total_revenue} <= 0 then ${total_revenue}
                 else null end;;
    drill_fields: [market_goal_drill*]
  }

  measure: rental_revenue_goal_unmet_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${total_revenue} > 0 then ${total_revenue}
                 else null end;;
    drill_fields: [market_goal_drill*]
  }

  measure: rental_revenue_no_goal_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_revenue}
      else null end ;;
    drill_fields: [market_goal_drill*]
  }

  measure: tot_rev_goal_above_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${total_revenue} > ${goal} THEN ${total_revenue}
                 when DIV0NULL(${total_revenue}, ${goal}) >= 1 then ${total_revenue}
                 else null end;;
    drill_fields: [market_goal_drill*]
  }

  measure: tot_rev_goal_close_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) >= 0.9 AND DIV0NULL(${total_revenue}, ${goal}) < 1 then ${total_revenue}
                 else null end;;
    drill_fields: [district_goal_drill*]
  }

  measure: tot_rev_goal_below_market {
    group_label: "Market"
    type: number
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                  when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) < 0.9 then ${total_revenue}
                 else null end;;
    drill_fields: [market_goal_drill*]
  }

  dimension: has_data {
    type: yesno
    sql: CASE WHEN ${revenue_goal} IS NULL AND ${total_revenue} IS NULL THEN FALSE ELSE TRUE END ;;
  }

  measure: remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${goal} - ${total_revenue} < 0 then null
      else ${goal} - ${total_revenue} end;;
  }



  set: company_goal_drill {
    fields: [month_date, market_region_xwalk.region_name, total_revenue_form, goal, perc_of_goal]
  }

  set: region_goal_drill {
    fields: [month_date, market_region_xwalk.district, total_revenue_form, goal, perc_of_goal]
  }

  set: district_goal_drill {
    fields: [month_date, market_region_xwalk.market_name, total_revenue_form, goal, perc_of_goal]
  }

  set: market_goal_drill {
    fields: [month_date, market_region_xwalk.market_name, total_revenue_form, goal, perc_of_goal]
  }


  set: detail {
    fields: [
      month_date,
      market_id,
      market_region_xwalk.market_name,
      rental_revenue,
      revenue_goal

    ]
  }
}
