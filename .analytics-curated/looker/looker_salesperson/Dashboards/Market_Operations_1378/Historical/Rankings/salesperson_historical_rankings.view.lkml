
view: salesperson_historical_rankings {
  derived_table: {
    sql: select
          'history' as ranking_type,
          na.date_month,
          na.sp_user_id,
          na.sp_name,
          u.email_address as sp_email_address,
          na.employee_title_dated,
          na.market_name as home_market,
          na.current_home_market as current_home_location,
          na.monthly_rank_na_es,
          na.monthly_rank_na_district,
          na.tot_na_monthly,
          na.monthly_rank_total_rev_es,
          na.monthly_rank_total_rev_district,
          na.total_rev,
          na.daily_rank_oec_es,
          na.daily_rank_oec_district,
          na.daily_oec_on_rent
      from
          analytics.bi_ops.new_account_revenue_rankings na
      left join es_warehouse.public.users u ON u.user_id = na.sp_user_id
      where
          date_month BETWEEN date_trunc(month,dateadd(month,-6,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AND date_trunc(month,dateadd(month,-1,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE))
      UNION
      select
          'current' as ranking_type,
          na.date_month,
          na.sp_user_id,
          na.sp_name,
          u.email_address as sp_email_address,
          na.employee_title_dated,
          na.market_name as home_market,
          na.current_home_market as current_home_location,
          na.monthly_rank_na_es,
          na.monthly_rank_na_district,
          na.tot_na_monthly,
          na.monthly_rank_total_rev_es,
          na.monthly_rank_total_rev_district,
          na.total_rev,
          na.daily_rank_oec_es,
          na.daily_rank_oec_district,
          na.daily_oec_on_rent
      from
          analytics.bi_ops.new_account_revenue_rankings na
      left join es_warehouse.public.users u ON u.user_id = na.sp_user_id
      where
          date_month = date_trunc(month,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: ranking_type {
    type: string
    sql: ${TABLE}."RANKING_TYPE" ;;
  }

  dimension_group: date_month {
    type: time
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: sp_email_address {
    type: string
    sql: ${TABLE}."SP_EMAIL_ADDRESS" ;;
  }

  dimension: employee_title_dated{
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: home_market {
    type: string
    sql: ${TABLE}."HOME_MARKET" ;;
  }

  dimension: current_home_location {
    type: string
    sql: ${TABLE}."CURRENT_HOME_LOCATION" ;;
  }

  dimension: monthly_rank_na_es {
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_ES" ;;
  }

  dimension: monthly_rank_na_district {
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_DISTRICT" ;;
  }

  dimension: tot_na_monthly {
    type: number
    sql: ${TABLE}."TOT_NA_MONTHLY" ;;
  }

  dimension: monthly_rank_total_rev_es {
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_ES" ;;
  }

  dimension: monthly_rank_total_rev_district {
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_DISTRICT" ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  dimension: daily_rank_oec_es {
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_ES" ;;
  }

  dimension: daily_rank_oec_district {
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_DISTRICT" ;;
  }

  dimension: daily_oec_on_rent {
    type: number
    sql: ${TABLE}."DAILY_OEC_ON_RENT" ;;
  }

  dimension: rep_and_market {
    type: string
    sql: concat(${sp_name},' - ',${home_market}) ;;
  }

  dimension: rep_and_current_location {
    type: string
    sql: concat(${sp_name},' - ',${current_home_location}) ;;
  }

  measure: district_oec_rank {
    type: sum
    sql: ${daily_rank_oec_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: district_na_rank {
    type: sum
    sql: ${monthly_rank_na_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: district_rev_rank {
    type: sum
    sql: ${monthly_rank_total_rev_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: district_oec_rank_for_labels {
    type: sum
    sql: ${daily_rank_oec_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: district_na_rank_for_labels {
    type: sum
    sql: ${monthly_rank_na_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: district_rev_rank_for_labels {
    type: sum
    sql: ${monthly_rank_total_rev_district} ;;
    filters: [ranking_type: "history"]
  }

  measure: current_es_oec_rank {
    type: sum
    sql: ${daily_rank_oec_es} ;;
    filters: [ranking_type: "current"]
  }

  measure: current_es_na_rank {
    type: sum
    sql: ${monthly_rank_na_es} ;;
    filters: [ranking_type: "current"]
  }

  measure: current_es_rev_rank {
    type: sum
    sql: ${monthly_rank_total_rev_es} ;;
    filters: [ranking_type: "current"]
  }

  measure: current_district_oec_rank {
    type: sum
    sql: ${daily_rank_oec_district} ;;
    filters: [ranking_type: "current"]
  }

  measure: current_district_na_rank {
    type: sum
    sql: ${monthly_rank_na_district} ;;
    filters: [ranking_type: "current"]
  }

  measure: current_district_rev_rank {
    type: sum
    sql: ${monthly_rank_total_rev_district} ;;
    filters: [ranking_type: "current"]
  }

  dimension: month_year {
    group_label: "HTML Formatted Date"
    label: "Month Year"
    type: date
    sql: ${date_month_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  measure: ranking_cards {
    group_label: "Ranking Card"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Current Month Rep Rankings</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Revenue District Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=District&Rep={{sp_name._filterable_value | url_encode}}" target="_blank">{{ current_district_rev_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Revenue ES Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=Overall&Rep={{sp_name._filterable_value | url_encode}}" target="_blank">{{ current_es_rev_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>OEC District Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=District&Rep={{sp_name._filterable_value | url_encode}}" target="_blank">{{ current_district_oec_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>OEC ES Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=Overall&Rep={{sp_name._filterable_value | url_encode}}" target="_blank">{{ current_es_oec_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>New Accounts District Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=District&Rep={{sp_name._filterable_value | url_encode}}" target="_blank">{{ current_district_na_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>New Accounts ES Ranking: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1487?Ranking+Scope=Overall&Rep={{sp_name._filterable_value | url_encode}}&Market=&District=&Market+Type=&Region=" target="_blank">{{ current_es_na_rank._rendered_value }} ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      </table>
      ;;
  }

  set: detail {
    fields: [
        ranking_type,
  date_month_date,
  sp_user_id,
  sp_name,
  home_market,
  monthly_rank_na_es,
  monthly_rank_na_district,
  tot_na_monthly,
  monthly_rank_total_rev_es,
  monthly_rank_total_rev_district,
  total_rev,
  daily_rank_oec_es,
  daily_rank_oec_district,
  daily_oec_on_rent
    ]
  }
}
