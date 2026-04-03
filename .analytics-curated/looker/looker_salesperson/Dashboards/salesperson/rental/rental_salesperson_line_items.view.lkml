view: rental_salesperson_line_items {
  derived_table: {
    sql: SELECT *
         FROM analytics.bi_ops.salesperson_line_items_current
         UNION
         SELECT *
         FROM analytics.bi_ops.salesperson_line_items_historic
         WHERE
            (
              ('salesperson' = {{ _user_attributes['department'] }} AND sp_email ILIKE '{{ _user_attributes['email'] }}')
             )
             OR
             (
              ('salesperson' != {{ _user_attributes['department'] }}
               AND
               ('developer' = {{ _user_attributes['department'] }}
                OR 'god view' = {{ _user_attributes['department'] }}
                OR 'managers' = {{ _user_attributes['department'] }}
                OR 'finance' = {{ _user_attributes['department'] }}
                OR 'collectors' = {{ _user_attributes['department'] }}
               )
              )
             );;
  }

  dimension: fk_rsg {
    type: string
    sql: CONCAT(${sp_user_id},'-',${rental_approved_date_year},'-',${rental_approved_date_month_num}) ;;
  }

  dimension_group: rental_approved_date {
    type: time
    timeframes: [date, month_num, year]
    datatype: timestamp
    sql: ${TABLE}."RENTAL_APPROVED_DATE";;
  }

  dimension: rental_approved_date_Mmm_YYYY {
    type: date
    sql: DATEFROMPARTS(${rental_approved_date_year}, ${rental_approved_date_month_num}, 1);;
    html: {{rendered_value | date: "%b %Y"}} ;;
  }

  dimension: rental_region {
    type: string
    sql: ${TABLE}."RENTAL_REGION";;
  }

  dimension: rental_district {
    type: string
    sql: ${TABLE}."RENTAL_DISTRICT";;
  }

  dimension: rental_market_id {
    type: number
    sql: ${TABLE}."RENTAL_MARKET_ID";;
  }

  dimension: rental_market {
    type: string
    sql: ${TABLE}."RENTAL_MARKET";;
  }

  dimension: rental_company_id {
    type: number
    sql: ${TABLE}."RENTAL_COMPANY_ID";;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY";;
  }

  dimension: rental_company_w_id {
    type: string
    sql: CONCAT(${rental_company}, ' - ', ${rental_company_id}) ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ rental_company._filterable_value | url_encode }}&Company%20ID="
    }
    label: "Has dynamic url to company dashboard."
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE";;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SP_USER_ID";;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON";;
  }

  dimension: salesperson_name_user_id {
    type: string
    sql: CONCAT(${salesperson}, ' - ', ${sp_user_id}) ;;
  }

  dimension: sp_jurisdiction {
    type: string
    sql: ${TABLE}."SP_JURISDICTION";;
  }

  dimension: sp_region {
    type: string
    sql: ${TABLE}."SP_REGION";;
  }

  dimension: sp_district {
    type: string
    sql: ${TABLE}."SP_DISTRICT";;
  }

  dimension: sp_market_id {
    type: number
    sql: ${TABLE}."SP_MARKET_ID";;
  }

  dimension: sp_market {
    type: string
    sql: ${TABLE}."SP_MARKET";;
  }

  dimension: direct_manager_user_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID";;
  }

  measure: rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${rental_revenue} ;;
  }

  dimension: in_market_flag {
    type: yesno
    sql: ${rental_market_id} = ${sp_market_id} ;;
  }

  measure: in_market_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [in_market_flag: "yes"]
  }

  measure: out_market_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [in_market_flag: "no"]
  }

  dimension: in_district_flag {
    type: yesno
    sql: ${rental_district} = ${sp_district} ;;
  }

  measure: in_district_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [in_district_flag: "yes"]
  }

  measure: out_district_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [in_district_flag: "no"]
  }

  dimension: current_month_flag {
    type: yesno
    hidden: yes
    sql: date_trunc('month', ${rental_approved_date_date}) =  DATE_TRUNC("Month", CURRENT_DATE("America/Chicago")) ;;
  }

  measure: MTD_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [current_month_flag: "yes"]
  }

  dimension: last_month_to_date_flag {
    type: yesno
    hidden: yes
    sql: ${rental_approved_date_date} >= DATE_TRUNC("Month", (CURRENT_DATE("America/Chicago") - INTERVAL "1 Month"))
        AND ${rental_approved_date_date} <= (CURRENT_DATE("America/Chicago") - INTERVAL "1 Month") ;;
  }

  measure: last_MTD_rental_revenue_sum {
    type: sum
    value_format_name: usd_0
    sql: ${rental_revenue} ;;
    filters: [last_month_to_date_flag: "yes"]
  }

  measure: difference_current_last_mtd_rental_revenue_K {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    value_format: "$0.00,\" K\""
    sql: ${MTD_rental_revenue_sum} - ${last_MTD_rental_revenue_sum} ;;
  }

  measure: difference_current_last_mtd_rental_revenue_M {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    value_format: "$0.00,,\" M\""
    sql: ${MTD_rental_revenue_sum} - ${last_MTD_rental_revenue_sum} ;;
  }

  measure: difference_current_last_mtd_rental_revenue {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    sql: ${MTD_rental_revenue_sum} - ${last_MTD_rental_revenue_sum} ;;
    required_fields: [difference_current_last_mtd_rental_revenue_M,difference_current_last_mtd_rental_revenue_K]
    html: <div style="border-radius: 5px;">
            <p style="font-size: 1.25rem;">Current vs Last MTD Rental Revenue</p>
            <p style="font-size: 2rem;">
              {% if value >= 1000000 %}
                <font color="#00CB86">
                <strong>↑{{difference_current_last_mtd_rental_revenue_M._rendered_value}}</strong></font>
              {% elsif value >= 1000 %}
                <font color="#00CB86">
                <strong>↑{{difference_current_last_mtd_rental_revenue_K._rendered_value}}</strong></font>
              {% elsif value >= 0 %}
                <font color="#00CB86">
                <strong>↑{{rendered_value}}</strong></font>
              {% elsif value <= -1000000 %}
                <font color="#DA344D">
                <strong>↓{{difference_current_last_mtd_rental_revenue_M._rendered_value}}</strong></font>
              {% elsif value <= -1000 %}
                <font color="#DA344D">
                <strong>↓{{difference_current_last_mtd_rental_revenue_K._rendered_value}}</strong></font>
              {% else %}
                <font color="#DA344D">
                <strong>↓{{rendered_value}}</strong></font>
              {% endif %}
            </p>
        </div> ;;
  }

  measure: rental_revenue_by_company_month_drilldown {
    type: string
    sql: 'second layer drilldown data must be downloaded separately' ;;
    drill_fields: [month_detail*]
    html: <a href="#drillmenu" target="_self"><img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>;;
  }

  set: company_detail {
    fields: [
      salesperson,
      rental_company,
      rental_revenue_sum
    ]
  }

  set: market_detail {
    fields: [
      salesperson,
      rental_market,
      rental_revenue_sum
    ]
  }

  set: month_detail {
    fields: [
      rental_approved_date_Mmm_YYYY,
      salesperson,
      rental_company,
      rental_revenue_sum
    ]
  }

}
