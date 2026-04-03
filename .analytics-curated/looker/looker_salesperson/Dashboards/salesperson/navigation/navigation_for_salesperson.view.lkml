
view: navigation_for_salesperson {
  derived_table: {
    sql: select
          concat(first_name,' ',last_name) as user_name,
          user_id,
          concat(first_name,' ',last_name,' - ',user_id) as user_name_with_user_id,
          email_address,
          employee_id,
          concat(first_name,' ',last_name,' - ',employee_id) as user_name_with_employee_id,
      from
          es_warehouse.public.users
      where
          email_address = '{{ _user_attributes['email'] }}' ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_name_with_user_id {
    type: string
    sql: ${TABLE}."USER_NAME_WITH_USER_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: user_name_with_employee_id {
    type: string
    sql: ${TABLE}."USER_NAME_WITH_EMPLOYEE_ID" ;;
  }

  dimension: upper_user_name_with_employee_id {
    type: string
    sql: UPPER(${user_name_with_employee_id}) ;;
  }

  measure: quick_links {
    group_label: "Quick Links Card"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Quick Links</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td><a href="https://quotes.estrack.com/new" target="_blank">Create New Quote:</a> </td>
      <td>
      <a href="https://quotes.estrack.com/new" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


    <td><a href="https://equipmentshare.looker.com/dashboards/183?District=&Region+Name=&Market=&Equipment+Class=&Equipment+Category=&Equipment+Parent+Category=&Business+Segment=&Active+Deal+Rate=" target="_blank">View Rates:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/183?District=&Region+Name=&Market=&Equipment+Class=&Equipment+Category=&Equipment+Parent+Category=&Business+Segment=&Active+Deal+Rate=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td><a href="https://equipmentshare.looker.com/dashboards/27?Parent+Category=&Equipment+Class=&Inventory+Status=&District=&Region=&Market=&Asset+ID=&Model=&Serial+Number=&Sub+Category=&Make=&Rapid+Rent=&Last+Off+Rent+Date=&Description=&Market+Type=" target="_blank">View Inventory:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/27?Parent+Category=&Equipment+Class=&Inventory+Status=&District=&Region=&Market=&Asset+ID=&Model=&Serial+Number=&Sub+Category=&Make=&Rapid+Rent=&Last+Off+Rent+Date=&Description=&Market+Type=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td><a href="https://equipmentshare.looker.com/dashboards/470?Company+Name=&Full+Name+with+ID={{ user_name_with_user_id._filterable_value | url_encode }}" target="_blank">View Commission Statement:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/470?Company+Name=&Full+Name+with+ID={{ user_name_with_user_id._filterable_value | url_encode }}" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td><a href="https://equipmentshare.looker.com/dashboards/135?Cardholder%20Name={{ upper_user_name_with_employee_id._filterable_value | url_encode }}&Cardholder%20Email=" target="_blank">View Credit Card Transactions:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/135?Cardholder%20Name={{ upper_user_name_with_employee_id._filterable_value | url_encode }}&Cardholder%20Email=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td><a href="https://equipmentshare.looker.com/dashboards/1481?Company+ID+and+Name=" target="_blank">Customers T3 Account:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1481?Company+ID+and+Name=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td><a href="https://equipmentshare.looker.com/dashboards/342?Manager%20Name=&Work%20Phone=&Market%20Name=&Job%20Title=&Employee%20Name=&Work%20Email=&Sales%20Front%20Email=&District=&Region%20Name=&State=&Market%20Type=&Cost%20Centers=&Market%20Zip%20Code=" target="_blank"> Company Directory:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/342?Manager%20Name=&Work%20Phone=&Market%20Name=&Job%20Title=&Employee%20Name=&Work%20Email=&Sales%20Front%20Email=&District=&Region%20Name=&State=&Market%20Type=&Cost%20Centers=&Market%20Zip%20Code=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td><a href="https://equipmentshare.looker.com/dashboards/479?Asset%20Type=&Asset%20ID=&Model=&Market=&Equipment%20Class=&Description=&Make=&Category=&Year=&Hours=&District=&Region=&Serial%20Number=&Fleet=" target="_blank">Sales Quote Request:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/479?Asset%20Type=&Asset%20ID=&Model=&Market=&Equipment%20Class=&Description=&Make=&Category=&Year=&Hours=&District=&Region=&Serial%20Number=&Fleet=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td><a href="https://equipmentshare.looker.com/dashboards/24?Market=&Sales%20Rep=&Region=&District=" target="_blank">Leaderboard:</a> </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/24?Market=&Sales%20Rep=&Region=&District=" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td><a href="https://tools.equipmentshare.com/vehicle-tracker?utm_source=salesperson" target="_blank">Vehicle Mileage Reporting:</a> </td>
      <td>
      <a href="https://tools.equipmentshare.com/vehicle-tracker?utm_source=salesperson" target="_blank"> ➔</a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>




      </table>
      ;;
  }

}
