
view: regional_manager_direct_reports {
  derived_table: {
    sql: with direct_reports as (
      select
          case
          when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
          else
          concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,
          employee_title,
          location as employee_location,
          u.user_id as employee_user_id,
          mn.manager_name,
          IFF(manager_email = 'josh.helmstetler@equipmentshare.com',TRUE,FALSE) as direct_report,
          mrx.district
      from
          analytics.payroll.pa_employee_access ca
          join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
          join
          (
          select
            distinct EMPLOYEE_ID as manager_id,
              case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
                   else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
              direct_manager_employee_id,
              work_email as manager_email
          from
            analytics.PAYROLL.COMPANY_DIRECTORY
          where
            employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
          ) mn on mn.manager_id = cd.direct_manager_employee_id
          join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)
          left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id
      where
          employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
          (
          (contains(ca.manager_access_emails,'josh.helmstetler@equipmentshare.com'))
          )
          AND employee_title = 'District Sales Manager'
      )
      select
      listagg(rep, ', ') as manager_list
      from
      direct_reports ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: manager_list {
    type: string
    sql: ${TABLE}."MANAGER_LIST" ;;
  }

  measure: tam_performance_links {
    group_label: "TAM Performance Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">TAM Performance Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Personalized TAM Insights: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1614" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Sales Manager Dashboard: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1472?Direct%20Manager={{ manager_list._value }}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>View TAM Individual Performance: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1409?Rep=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>New Accounts History: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1602?Direct+Manager={{ manager_list._value }}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Quotes Dashboard: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/994" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Set TAM Metric Goals: </td>
      <td>
      <a href="https://equipmentshare.retool-hosted.com/apps/64df94f4-7f36-11ee-b9e5-ebd6931f6d5a/DSM%20Sales%20Rep%20Goals/DSM%20Sales%20Rep%20Goal%20Entry" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: market_performance_links {
    group_label: "Market Performance Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Market Performance Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Personalized Market Insights: </td>
      <td>
      <a href="#" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Regional Rankings: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1298" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Region-District Rankings: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1321" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>District-Markets Rankings: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1322" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Markets Dashboard: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1328" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: finance_performance_links {
    group_label: "Financials Performance Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Financial Performance Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Branch Earnings: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/180" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>High Level Financials Overview: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/524" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Trending Branch Earnings: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1423" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Manager Profit Sharing Statement: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/560" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Executive Summary: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1031" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: asset_performance_links {
    group_label: "Asset Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Asset Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Class Count by Locations: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/180" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Benchmark and Online Rates by Class and Market: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/183" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Inventory Information: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/27" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Equipment Sales Quote Request: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/479" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Part Lookup: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/558" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Parts Transactions: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/540" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: customer_information_links {
    group_label: "Customer Information Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Customer Information Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Customer Dashboard: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/28" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Rentals by Customer: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1500" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table>
      ;;
  }

  measure: tool_links {
    group_label: "Tool Links"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Tools</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>Company Directory: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/342" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>Individual Credit Cards: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/524" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Manager Credit Cards: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/141" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>Cycle Report: </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/353" target="_blank"> ➔</a>
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
        manager_list
    ]
  }
}
