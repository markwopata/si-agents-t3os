
view: current_month_rev_by_company {
  sql_table_name: analytics.bi_ops.current_month_rev_by_company ;;


  dimension: total_monthly_rev {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_REV"  ;;
  }
  measure: total_monthly_rev_m {
    type: max
    sql:  ${total_monthly_rev} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date_month {
    type: date
    sql: ${TABLE}."DATE_MONTH" ;;
    html: {{ rendered_value | date: "%B %Y" }};;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_name {
    label: "Rep Name"
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;

  }

  dimension: rental_company_id {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  measure: total_rev_sum {
    type: sum
    label: "Total Revenue"
    sql: ${TABLE}."TOTAL_REV"  ;;
    value_format_name: usd_0
  }

  dimension: in_market_rev {
    type: number
    sql: ${TABLE}."IN_MARKET_REV" ;;
  }

  measure: in_market_rev_sum {
    type: sum
    label: "In Market Revenue"
    sql: ${TABLE}."IN_MARKET_REV" ;;
    value_format_name: usd_0
  }

  dimension: out_market_rev {
    type: number
    sql: ${TABLE}."OUT_OF_MARKET_REV" ;;
  }

  measure: out_market_rev_sum {
    type: sum
    label: "Out of Market Revenue"
    sql: ${TABLE}."OUT_OF_MARKET_REV" ;;
    value_format_name: usd_0
  }


  measure: perc_total {
    type: number
    sql: DIV0NULL(${total_rev_sum}, ${total_monthly_rev_m});;
    value_format_name: percent_2
    label: "% of Individual's Total Monthly Revenue Total"
  }

  measure: in_market_perc_total {
    type: number
    sql: DIV0NULL(${in_market_rev_sum}, ${total_monthly_rev_m});;
    value_format_name: percent_2
    label: "% of Individual's Total Monthly Revenue"
  }

  measure: out_market_perc_total {
    type: number
    sql: DIV0NULL(${out_market_rev_sum}, ${total_monthly_rev_m});;
    value_format_name: percent_2
    label: "% of Individual's Total Monthly Revenue"
  }


  measure: perc_of_total_fmt{
    type: number
    sql: ${perc_total} ;;
    html: <font color="#000000">
    Total % of Revenue: {{rendered_value}}
   </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">In Market % of Total: {{in_market_perc_total._rendered_value}} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Out of Market % of Total: {{out_market_perc_total._rendered_value}} </font>;;
    value_format_name: percent_2
    label: "Breakdown of % of Revenue"
  }

  dimension: home_market_id {
    type:  string
    sql:  ${TABLE}."HOME_MARKET_ID"  ;;
  }

  dimension: one_flag{
  type: number
  sql:  ${TABLE}."ONE_FLAG" ;;
  }

  dimension: current_rev_dash_link {
    type: string
    sql:${salesperson_permissions.rep_home_market};;
    html:
    <div style="text-align: center;">
      <a href="https://equipmentshare.looker.com/dashboards/2558?Rep=%22{{ salesperson_permissions.rep_home_market._value| url_encode }}%22&Home+Market="
         target="_blank">
        View Current Month Revenue By Company Dashboard
      </a>
    </div> ;;
  }

  set: detail {
    fields: [
        date_month,
  sp_user_id,
  sp_name,
  rental_company,
  total_rev
    ]
  }
}
