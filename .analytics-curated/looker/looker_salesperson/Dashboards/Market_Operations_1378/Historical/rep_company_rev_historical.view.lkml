
view: rep_company_rev_historical {
  derived_table: {
    sql:
    select * from analytics.bi_ops.rev_by_rep_company_historical
    UNION select * from analytics.bi_ops.rev_by_rep_company_current ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_month {
    type: time
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: sp_user_id {
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: rep {
    type:  string
    sql:concat(${sp_name}, ' - ', ${current_home_market}) ;;
  }

  dimension: sp_market_id_dated {
    type: string
    sql: ${TABLE}."SP_MARKET_ID_DATED" ;;
  }

  dimension: sp_market_dated {
    type: string
    sql: ${TABLE}."SP_MARKET_DATED" ;;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: rental_company_id {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
  }

  dimension: rental_market {
    type: string
    sql: ${TABLE}."RENTAL_MARKET" ;;
  }

  dimension: rental_market_id {
    type: string
    sql: ${TABLE}."RENTAL_MARKET_ID" ;;
  }

  dimension: in_market_rev {
    type: number
    sql: ${TABLE}."IN_MARKET_REV" ;;
  }

  measure: in_market_rev_sum {
    type: sum
    sql:  ${in_market_rev} ;;
    value_format_name: usd_0
  }

  dimension: out_of_market_rev {
    type: number
    sql: ${TABLE}."OUT_OF_MARKET_REV" ;;
  }

  measure: out_of_market_rev_sum {
    type: sum
    sql:  ${out_of_market_rev} ;;
    value_format_name: usd_0
  }

  dimension: gen_rental_rev {
    type: number
    sql: ${TABLE}."GEN_RENTAL_REV" ;;
  }

  measure: gen_rental_rev_sum {
    type: sum
    sql:  ${gen_rental_rev} ;;
    value_format_name: usd_0
  }

  dimension: adv_rentals_rev {
    type: number
    sql: ${TABLE}."ADV_RENTALS_REV" ;;
  }

  measure: adv_rentals_rev_sum {
    type: sum
    sql:  ${adv_rentals_rev} ;;
    value_format_name: usd_0
  }

  dimension: itl_rental_rev {
    type: number
    sql: ${TABLE}."ITL_RENTAL_REV" ;;
  }

  measure: itl_rental_rev_sum {
    type: sum
    sql:  ${itl_rental_rev} ;;
    value_format_name: usd_0
  }

  dimension: no_class_rental_rev {
    type: number
    sql: ${TABLE}."NO_CLASS_RENTAL_REV" ;;
  }

  measure: no_class_rental_rev_sum {
    type: sum
    sql:  ${no_class_rental_rev} ;;
    value_format_name: usd_0
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  measure: totsl_rev_sum {
    type: sum
    sql:  COALESCE(${total_rev}, 0) ;;
    value_format_name: usd_0

  }

  dimension: current_home_market_id {
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET_ID" ;;
  }

  dimension: current_home_market {
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET" ;;
  }

  dimension: total_monthly_rev_per_rep_company {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_REV_PER_REP_COMPANY" ;;
  }

 measure: last_three_months_co_rev {
    type: sum
    sql: CASE WHEN ${date_month_date} >= date_trunc(month, dateadd(month, '-2', current_date)) THEN (${total_rev}) ELSE NULL END  ;;
    value_format_name: usd_0
  }

  measure: total_monthly_rev_per_rep_company_max {
    type: max
    sql: ${total_monthly_rev_per_rep_company};;
    }

  dimension: total_monthly_rev_per_rep {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_REV_PER_REP" ;;
  }

  measure: total_monthly_rev_per_rep_max {
    type: max
    sql: ${total_monthly_rev_per_rep};;
  }

  dimension: prct_rep_co_rev {
    type: number
    sql: DIV0NULL(${total_monthly_rev_per_rep_company}, ${total_monthly_rev_per_rep} );;
    value_format_name: percent_1
  }


  measure: sp_nav_card_rev {
    group_label: "Salesperson Nav Card - Revenue"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Salesperson Navigation</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>

      <td>Home: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1462?Current%20Status=Active&Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


    <td>Rentals: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1404?Salesperson={{sp_name._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Customers: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Accounts Receivable: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1406?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: sp_nav_card_home {
    group_label: "Salesperson Nav Card - Home"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Salesperson Navigation</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>

      <td>Revenue: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1403?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Rentals: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1404?Salesperson={{sp_name._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Customers: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Accounts Receivable: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1406?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: sp_nav_card_rentals {
    group_label: "Salesperson Nav Card - Rentals"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Salesperson Navigation</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
      <td>Home: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1462?Current%20Status=Active&Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Revenue: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1403?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Customers: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Accounts Receivable: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1406?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: sp_nav_card_customers {
    group_label: "Salesperson Nav Card - Customers"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Salesperson Navigation</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>

      <td>Home: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1462?Current%20Status=Active&Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Revenue: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1403?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Rentals: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1404?Salesperson={{sp_name._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Accounts Receivable: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1406?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: sp_nav_card_ar {
    group_label: "Salesperson Nav Card - AR"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Salesperson Navigation</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>

      <td>Home: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1462?Current%20Status=Active&Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Revenue: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1403?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Rentals: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1404?Salesperson={{sp_name._filterable_value | url_encode}}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Customers: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Rep={{rep._filterable_value | url_encode}}" target="_blank"> ➔</a>
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
        date_month_month,
  sp_user_id,
  sp_name,
  sp_market_id_dated,
  sp_market_dated,
  rental_company,
  rental_company_id,
  rental_market,
  rental_market_id,
  in_market_rev,
  out_of_market_rev,
  gen_rental_rev,
  adv_rentals_rev,
  itl_rental_rev,
  no_class_rental_rev,
  total_rev,
  current_home_market_id,
  current_home_market,
  total_monthly_rev_per_rep_company,
  total_monthly_rev_per_rep
    ]
  }
}
