
view: rental_revenue_per_day_with_goal {
  derived_table: {
    sql:
      with current_month_market_goal as (
      select
          market_id,
          name as market,
          revenue_goals,
          (revenue_goals/DAY(LAST_DAY(current_date))) as per_day_goal
      from
          analytics.public.market_goals
      where
        months::date = date_trunc('month',current_date)::date
        AND end_date is null
      )

      , per_day_revenue as (
      select
        m.market_id,
        dd.date,
        dd.current_month,
        dd.prior_month,
        sum(ild.invoice_line_details_amount) as rental_revenue
      from
        platform.gold.v_line_items r
        JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
        JOIN platform.gold.v_markets m on m.market_key = ild.INVOICE_LINE_DETAILS_MARKET_KEY
        JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
      where
        (
        dd.current_month = TRUE
        OR
        dd.prior_month = TRUE
        )
        AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
        --AND m.market_id = 1 ---- Removing this... I wonder if we should dynamically pass the m.market_name here and at the last select statement.
      group by
        m.market_id,
        dd.date,
        dd.current_month,
        dd.prior_month
      )
      , generate_series as (
      select
          series::date as series,
          market_id
      from
          table(es_warehouse.public.generate_series(
          date_trunc('month',dateadd(months,-1,current_date))::timestamp_tz,
          current_date::timestamp_tz,
          'day'))
          left join analytics.public.market_region_xwalk
      )
      select
          gs.series as generated_date,
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          gs.market_id,
          mrx.market_type,
          vmt.is_current_months_open_greater_than_twelve as months_open_over_12,
          coalesce(cmg.revenue_goals,0) as current_month_goal,
          coalesce(cmg.per_day_goal,0) as per_day_goal,
          coalesce(pdr.current_month,IFF(date_trunc('month',gs.series) = date_trunc('month',current_date),TRUE,FALSE)) current_month,
          coalesce(pdr.prior_month,IFF(date_trunc('month',gs.series) = date_trunc('month',current_date),FALSE,TRUE)) prior_month,
          IFF(
              date_trunc('month', gs.series) = date_trunc('month', dateadd(month, -1, current_date))
              AND day(gs.series) = day(current_date),
              TRUE,
              FALSE
                ) AS last_month_to_date_flag,
          IFF(current_date = gs.series,TRUE,FALSE) as current_date_flag,
          coalesce(pdr.rental_revenue,0) as rental_revenue_on_date,
          case when gs.series > current_date then null else
          sum(pdr.rental_revenue) OVER (partition by date_trunc('month',generated_date), gs.market_id ORDER BY gs.series asc) end as running_total_of_rental_revenue,
          sum(coalesce(cmg.per_day_goal,0)) OVER (partition by date_trunc('month',generated_date), gs.market_id ORDER BY gs.series asc) as running_total_of_goal_revenue
      from
          generate_series gs
          LEFT JOIN per_day_revenue pdr on gs.series::date = pdr.date AND gs.market_id = pdr.market_id
          JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = gs.market_id
          LEFT JOIN current_month_market_goal cmg on cmg.market_id = gs.market_id and date_trunc('month',gs.series) = date_trunc('month',current_date)
          left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = gs.market_id
          --JOIN market_open_length mol on gs.MARKET_ID = mol.MARKET_ID
      group by
          generated_date,
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          vmt.is_current_months_open_greater_than_twelve,
          --mol.months_open_over_12,
          current_month_goal,
          per_day_goal,
          pdr.current_month,
          pdr.prior_month,
          pdr.rental_revenue,
          gs.market_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: generated_date {
    label: ""   # This label removes the repetative "date" in the dimension name
    type: time
    sql: ${TABLE}."GENERATED_DATE" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
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

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."MONTHS_OPEN_OVER_12" ;;
  }

  dimension: current_month_goal {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_GOAL" ;;
  }

  dimension: per_day_goal {
    type: number
    sql: ${TABLE}."PER_DAY_GOAL" ;;
  }

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }

  dimension: prior_month {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH" ;;
  }

  dimension: last_month_to_date_flag {
    type: yesno
    sql: ${TABLE}."LAST_MONTH_TO_DATE_FLAG" ;;
  }

  dimension: current_date_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_DATE_FLAG" ;;
  }

  dimension: rental_revenue_on_date {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE_ON_DATE" ;;
  }

  dimension: running_total_of_goal_revenue {
    type: number
    sql: ${TABLE}."RUNNING_TOTAL_OF_GOAL_REVENUE" ;;
  }

  dimension: running_total_of_rental_revenue {
    type: number
    sql: ${TABLE}."RUNNING_TOTAL_OF_RENTAL_REVENUE" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${generated_date_date},${market_id}) ;;
  }

  dimension: formatted_generated_date {
    group_label: "HTML Formatted Time"
    label: "Date"
    type: date
    sql: ${generated_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_revenue_goal_by_day {
    type: sum
    sql: ${per_day_goal} ;;
  }

  measure: revenue_goal_by_day {
    type: sum
    # sql: DAY(current_date)*${total_revenue_goal_by_day} ;;
    sql: ${running_total_of_goal_revenue} ;;
  }

  measure: running_total_current_month_rental_revenue {
    type: sum
    sql: ${running_total_of_rental_revenue} ;;
    filters: [current_month: "TRUE"]
    value_format_name: usd
  }

  measure: running_total_prior_month_rental_revenue {
    type: sum
    sql: ${running_total_of_rental_revenue} ;;
    filters: [prior_month: "TRUE"]
    value_format_name: usd
  }

  measure: last_mtd_rental_revenue {
    type: sum
    sql: ${running_total_of_rental_revenue} ;;
    filters: [prior_month: "TRUE", last_month_to_date_flag: "TRUE"]
    value_format_name: usd_0
  }


  measure: running_total_prior_month_rental_revenue_zeros {
    type: number
    sql: CASE WHEN ${running_total_prior_month_rental_revenue} = 0 and ${generated_date_day_of_month} > 25 THEN NULL ELSE  ${running_total_prior_month_rental_revenue} END;;

    value_format_name: usd_0
  }

  measure: current_month_total_rental_revenue_by_day {
    type: number
    sql: case when ${running_total_current_month_rental_revenue} = 0 then null else ${running_total_current_month_rental_revenue} end ;;
    value_format_name: usd
  }

  measure: current_day {
    label: "Current Day Rental Revenue"
    type: number
    sql: case when DAY(current_date) = ${generated_date_day_of_month} then ${current_month_total_rental_revenue_by_day} else null end ;;
    value_format_name: usd_0
    drill_fields: [current_month_rental_revenue_drill.customer, current_month_rental_revenue_drill.salesperson,
                  current_month_rental_revenue_drill.total_revenue]
  }

  measure: current_month_total_rental_revenue {
    type: sum
    sql: ${rental_revenue_on_date} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE"]
    drill_fields: [current_month_rental_revenue_drill.customer, current_month_rental_revenue_drill.salesperson,
                  current_month_rental_revenue_drill.total_revenue]
  }

  measure: prior_month_total_rental_revenue {
    type: sum
    sql: ${rental_revenue_on_date} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE"]
    drill_fields: [prior_month_rental_revenue_drill.customer, prior_month_rental_revenue_drill.salesperson,
                  prior_month_rental_revenue_drill.total_rental_revenue]
  }

  measure: current_month_rental_revenue_goal {
    type: sum
    sql: ${current_month_goal} ;;
    value_format_name: usd_0
    filters: [current_date_flag: "TRUE"]
  }

  measure: current_month_rental_rev_goal {
    type: sum_distinct
    sql: ${current_month_goal} ;;
    value_format_name: usd_0
  }

  measure: rental_revenue_current_vs_prior_month {
    type: number
    sql: ${current_month_total_rental_revenue} - ${prior_month_total_rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: goal_progress {
    type: number
    sql: ${current_month_total_rental_revenue}/${current_month_rental_revenue_goal} ;;
    value_format_name: percent_1
  }

  measure: rental_revenue_above_goal {
    group_label: "Rental Revenue vs Goal"
    label: "Above Monthly Goal"
    type: number
    sql: IFF((${current_month_total_rental_revenue}/NULLIF(${current_month_rental_revenue_goal},0)) >= 1,${current_month_total_rental_revenue},NULL)  ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_revenue_below_goal {
    group_label: "Rental Revenue vs Goal"
    label: "Close to Monthly Goal"
    type: number
    sql: IFF(((${current_month_total_rental_revenue}/NULLIF(${current_month_rental_revenue_goal},0)) >= .9 AND (${current_month_total_rental_revenue}/NULLIF(${current_month_rental_revenue_goal},0)) < 1),${current_month_total_rental_revenue},NULL) ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_revenue_close_to_goal {
    group_label: "Rental Revenue vs Goal"
    label: "Below Monthly Goal"
    type: number
    sql: IFF((${current_month_total_rental_revenue}/NULLIF(${current_month_rental_revenue_goal},0)) < .9,${current_month_total_rental_revenue},NULL)  ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: mtd_vs_lmtd_rental_revenue_change {
    group_label: "Rental Revenue MTD vs LMTD"
    label: "MTD vs LMTD Rental Revenue"
    type: number
    sql: ${current_month_total_rental_revenue} - ${last_mtd_rental_revenue} ;;
    value_format_name: usd_0
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;
  }

  measure: mtd_change_total_rental_revenue_percent_change {
    group_label: "Rental Revenue MTD vs LMTD"
    label: "MTD Change %"
    type: number
    sql: CASE WHEN  ${last_mtd_rental_revenue} = 0 AND ${current_month_rental_revenue_goal} = 0 THEN 0
              WHEN  ${last_mtd_rental_revenue} = 0 AND ${current_month_rental_revenue_goal} > 0 THEN 1
              WHEN  ${last_mtd_rental_revenue} = 0 AND ${current_month_rental_revenue_goal} < 0 THEN -1
              ELSE DIV0NULL(${current_month_total_rental_revenue} - ${last_mtd_rental_revenue}, ${last_mtd_rental_revenue}) END;;
    value_format_name: percent_1
  }

  measure: mtd_day_card {
    group_label: "Rental Revenue Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_month_total_rental_revenue} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Rental Revenue</td>
  </tr>


      {% if mtd_change_total_rental_revenue_percent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if mtd_change_total_rental_revenue_percent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>MTD Rental Revenue: </td>
      <td>
      {% if mtd_change_total_rental_revenue_percent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ current_month_total_rental_revenue._rendered_value }}</a>
      {% if mtd_change_total_rental_revenue_percent_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Rental Revenue: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ last_mtd_rental_revenue._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if mtd_change_total_rental_revenue_percent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if mtd_change_total_rental_revenue_percent_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ mtd_vs_lmtd_rental_revenue_change._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rental_revenue_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ mtd_vs_lmtd_rental_revenue_change._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rental_revenue_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  set: detail {
    fields: [
      generated_date_date,
      region_name,
      district,
      market_name,
      market_type,
      per_day_goal,
      current_month,
      prior_month,
      rental_revenue_on_date,
      running_total_of_rental_revenue
    ]
  }
}
