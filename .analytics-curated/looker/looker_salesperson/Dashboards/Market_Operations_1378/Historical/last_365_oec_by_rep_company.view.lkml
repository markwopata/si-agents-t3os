view: last_365_oec_by_rep_company {
  derived_table: {
    sql: select *,
 CASE WHEN  l.date >= DATEADD(day, '-6',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 end AS past_7_day

, CASE WHEN  l.date >= DATEADD(day, '-29',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 end AS past_30_day

, CASE WHEN  l.date >= DATEADD(day, '-89',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 end AS past_90_day

, CASE WHEN  l.date >= DATEADD(day, '-179',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 end AS past_180_day

, CASE WHEN  l.date >= DATEADD(day, '-364',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 end AS past_365_day

    from analytics.bi_ops.last_365_oec_by_rep_company l
    inner join (
        select sp_full_name, current_home_market, salesperson_user_id as sp_user_id , concat(sp_full_name, ' - ', current_home_market) as rep_home , sum(assets_on_rent) as current_assets_on_rent, sum(oec_on_rent) as current_oec_on_rent
        from analytics.bi_ops.daily_sp_market_rollup
        where current_home_market is not null and employee_status_present = 'Active' and date = CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE
        and {% condition rep_home_filter %} rep_home {% endcondition %}
        group by 1,2,3  ) d ON d.sp_user_id = l.salesperson_user_id
    ;;
  }

  filter: rep_home_filter {
    type: string
  }

  parameter: days_timeframe {
    type: string
    default_value: "90"
    allowed_value: {
      label: "7 Days"
      value: "7"
    }
    allowed_value: {
      label: "30 Days"
      value: "30"
    }
    allowed_value: {
      label: "90 Days"
      value: "90"
    }
    allowed_value: {
      label: "180 Days"
      value: "180"}
    allowed_value: {
      label: "365 Days"
      value: "365"
    }
  }

  dimension: past_7_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_7_DAY" ;;
  }

  dimension: past_30_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_30_DAY" ;;
  }

  dimension: past_90_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_90_DAY" ;;
  }

  dimension: past_180_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_180_DAY" ;;
  }

  dimension: past_365_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_365_DAY" ;;
  }

  dimension: days_flag  {
    type: yesno
    sql:
    case
    when {{ days_timeframe._parameter_value }} = '7' then ${past_7_day} = 1
    when {{ days_timeframe._parameter_value }} = '30' then ${past_30_day} = 1
    when {{ days_timeframe._parameter_value }} = '90' then ${past_90_day} = 1
    when {{ days_timeframe._parameter_value }} = '180' then ${past_180_day} = 1
    when {{ days_timeframe._parameter_value }} = '365' then ${past_365_day} = 1
    end
    ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_formatted {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: month_date {
    type: string
    sql: DATE_TRUNC('month', ${date_date}) ;;
  }

  dimension: salesperson_user_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SP_FULL_NAME" ;;
  }

  dimension: email_address {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: home_market {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET" ;;
  }

  dimension: rep {
    group_label: "Sales Rep Info"
    label: "Rep - Market"
    sql: concat(${name}, ' - ', ${home_market}) ;;
  }

  dimension: home_market_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."HOME_MARKET_ID" ;;
  }

  dimension: district {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: employee_title {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }


  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  measure: company_id_count{
    type: count_distinct
    sql:${company_id} ;;
    drill_fields:[actively_renting_drill*]

  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_max {
    type: max
    label: "Assets On Rent Max"
    sql: ${assets_on_rent} ;;
  }

  measure: assets_on_rent_sum {
    type: sum
    label: "Assets On Rent"
    sql: ${assets_on_rent} ;;
    drill_fields: [actively_renting_drill*]
  }

  measure: assets_on_rent_avg {
    type: average
    label: "Assets On Rent - Avg"
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_1
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
    label: "OEC On Rent"
  }

  measure: oec_on_rent_max{
    type: max
    label: "OEC On Rent"
    sql:  ${oec_on_rent};;

    value_format_name: usd_0
  }

  measure: avg_oec_day {
    type: number
    sql: ROUND(DIV0NULL(SUM(${oec_on_rent}),COUNT(${oec_on_rent})), 2) ;;
    value_format_name: usd_0
  }

  measure: total_oec {
    type: sum
    sql: ${oec_on_rent};;
    label: "OEC On Rent"
    drill_fields: [oec_on_rent_drill*]
    value_format_name: usd_0
  }



  dimension: one_flag {
    type:  number
    sql:${TABLE}."ONE_FLAG" ;;
  }

  set: oec_on_rent_drill {
    fields: [company_name, total_oec, assets_on_rent_sum]
  }

  set: actively_renting_drill {
    fields: [company_name, total_oec, assets_on_rent_sum]
  }



  set: detail {
    fields: [

      salesperson_user_id,
      company_name,
      company_id,
      assets_on_rent_max
    ]
  }
}
