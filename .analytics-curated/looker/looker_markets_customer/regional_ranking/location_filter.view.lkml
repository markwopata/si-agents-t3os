
view: location_filter {
  derived_table: {
    sql:
      select
        mrx.region_name as region,
        mrx.district,
        mrx.market_name as market,
        mrx.market_type,
        mrx.market_id,
        mrx.is_open_over_12_months
       -- vmt.is_current_months_open_greater_than_twelve
      from
        analytics.public.market_region_xwalk mrx
     -- left join analytics.public.v_market_t3_analytics vmt on vmt.market_id = mrx.market_id
      WHERE {% condition region_name_filter_mapping %} mrx.region_name {% endcondition %}
            and {% condition district_filter_mapping %} mrx.district {% endcondition %}
            and {% condition market_name_filter_mapping %} mrx.market_name {% endcondition %}
            AND {% condition market_type_filter_mapping %} mrx.market_type {% endcondition %}
      ;;
  }


  filter: region_name_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: market_name_filter_mapping {
    type: string
  }

  filter: market_type_filter_mapping {
    type: string
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

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

  dimension: region_district_navigation {
    group_label: "Navigation Grouping"
    label: "View Region District Breakdowns"
    type: string
    sql: ${region} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1321?Region={{ region._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} District Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets  </tr> </button>
     ;;
  }

  dimension: district_market_navigation {
    group_label: "Navigation Grouping"
    label: "View District Market Breakdowns"
    type: string
    sql: ${district} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1322?District={{ district._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} Market Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets </tr> </button>
     ;;
  }

  dimension: market_navigation {
    group_label: "Navigation Grouping"
    label: "View Market Breakdowns"
    type: string
    sql: ${market} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1328?Market={{ market._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u></button>
     ;;
  }

  dimension: market_navigation_permissioned {
    group_label: "Navigation Grouping"
    label: "View Market Breakdowns"
    type: string
    sql: ${market} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1328?Market={{ market._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u></button>
     ;;
  }

  measure: quick_links {
    group_label: "Quick Links Card"
    label: " "
    type: sum
    sql: 1 ;;
    html:
    {% assign f_region   = _filters['location_filter.region_name_filter_mapping']  | default: '' | url_encode %}
    {% assign f_district = _filters['location_filter.district_filter_mapping']     | default: '' | url_encode %}
    {% assign f_market   = _filters['location_filter.market_name_filter_mapping']  | default: '' | url_encode %}
    {% assign f_type     = _filters['location_filter.market_type_filter_mapping']  | default: '' | url_encode %}


    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="4" style="font-size: 20px;">Quick Links</td>
  </tr>
  <tr>
    <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
  </tr>
  <tr>
    <td>
    <a href="https://equipmentshare.looker.com/dashboards/1367?Market={{ f_market }}&amp;District={{ f_district }}&amp;Region={{ f_region }}&amp;Market%20Type=" target="_blank">
    Future Market Goals:
    </a>
    </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1367?Market={{ f_market }}&amp;District={{ f_district }}&amp;Region={{ f_region }}&amp;Market%20Type=" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>
  <a href="https://equipmentshare.looker.com/dashboards/342?Manager+Name=&amp;Work+Phone=&amp;Market+Name={{ f_market }}&amp;Job+Title=&amp;Employee+Name=&amp;Work+Email=&amp;Sales+Front+Email=&amp;District={{ f_district }}&amp;State=&amp;Market+Type=&amp;Cost+Centers=&amp;Region={{ f_region }}&amp;Market+Zip+Code=" target="_blank">
      Market Employee List:
      </a>
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/342?Manager+Name=&amp;Work+Phone=&amp;Market+Name={{ f_market }}&amp;Job+Title=&amp;Employee+Name=&amp;Work+Email=&amp;Sales+Front+Email=&amp;District={{ f_district }}&amp;State=&amp;Market+Type=&amp;Cost+Centers=&amp;Region={{ f_region }}&amp;Market+Zip+Code=" target="_blank">

      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>
      <a href="https://equipmentshare.looker.com/dashboards/180?Market+Name={{ f_market }}&amp;Period=&amp;District+Number={{ f_district }}&amp;Region+Name={{ f_region }}&amp;Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29=&amp;Market+Type={{ f_type }}" target="_blank">

      Latest Branch Earnings:
      </a>
      </td>
      <td>
  <a href="https://equipmentshare.looker.com/dashboards/180?Market+Name={{ f_market }}&amp;Period=&amp;District+Number={{ f_district }}&amp;Region+Name={{ f_region }}&amp;Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29=&amp;Market+Type={{ f_type }}" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>
      <a href="https://equipmentshare.looker.com/dashboards/49?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}&amp;Market%20Type={{ f_type }}&amp;Make=&amp;Class=" target="_blank">
      Service Dashboard:
      </a>
      </td>
      <td>
            <a href="https://equipmentshare.looker.com/dashboards/49?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}&amp;Market%20Type={{ f_type }}&amp;Make=&amp;Class=" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>
      <td>

     <a href="https://equipmentshare.looker.com/dashboards/183?District={{ f_district }}&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Equipment+Class=&amp;Equipment+Category=&amp;Equipment+Parent+Category=&amp;Business+Segment=&amp;Active+Deal+Rate=&amp;Rentable=Yes" target="_blank">
      Benchmark and Online Rates:
      </a>
      </td>
      <td>
     <a href="https://equipmentshare.looker.com/dashboards/183?District={{ f_district }}&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Equipment+Class=&amp;Equipment+Category=&amp;Equipment+Parent+Category=&amp;Business+Segment=&amp;Active+Deal+Rate=&amp;Rentable=Yes" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>
      <td>
     <a href="https://equipmentshare.looker.com/dashboards/62?Parent+Category=&amp;Equipment+Class=&amp;Inventory+Status=&amp;District={{ f_district }}&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Asset+ID=&amp;Sub+Category=&amp;Business+Segment=&amp;Make=&amp;Model=&amp;Transfer+Status=" target="_blank">
      Class Count By Locations:
      </a>
      </td>
      <td>
     <a href="https://equipmentshare.looker.com/dashboards/62?Parent+Category=&amp;Equipment+Class=&amp;Inventory+Status=&amp;District={{ f_district }}&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Asset+ID=&amp;Sub+Category=&amp;Business+Segment=&amp;Make=&amp;Model=&amp;Transfer+Status=" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1139?District={{ f_district }}&amp;Topic+Type=Weekly&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Market+Type={{ f_type }}&amp;Employee+Type=Non-Sales&amp;Employee+Name+With+ID=" target="_blank">
      Safety Meeting Attendance:
      </a>
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1139?District={{ f_district }}&amp;Topic+Type=Weekly&amp;Region={{ f_region }}&amp;Market={{ f_market }}&amp;Market+Type={{ f_type }}&amp;Employee+Type=Non-Sales&amp;Employee+Name+With+ID=" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>




      <td>
<a href="https://equipmentshare.looker.com/dashboards/579?Asset+Class=&amp;Model=&amp;Keypad+Install+Status=&amp;Make=&amp;Asset+Inventory+Status=Assigned%2CHard+Down%2CNeeds+Inspection%2CPre-Delivered%2CPending+Return%2COn+Rent%2CReady+To+Rent%2CSoft+Down&amp;Ownership=ES%2COWN%2CRETAIL&amp;Tracker+Firmware+Version=&amp;Camera+Req=&amp;Ecm+Hardware=&amp;Market+Name={{ f_market }}&amp;Camera+Install+Status=&amp;Last+Checkin+Timestamp+Date=&amp;Camera+Vendor=&amp;Asset+Health+Status=&amp;Test+Status=&amp;Asset+ID=&amp;District={{ f_district }}&amp;Category=&amp;Region={{ f_region }}&amp;Tracker+Req+Type=MCX%2FLMU%2CSLAP+N+TRACK%2CMC4%2F5+ONLY%2CMC4%2F5+OR+FJ&amp;Owning+Company+Name=&amp;Tracker+Serial=&amp;Has+Can=&amp;Telematics+Region=&amp;Installed+Tracker+Type=&amp;Tracker+Model+Installed=&amp;Asset+Health+Detail=&amp;Service%2FRetail+Branch=&amp;Custom+Name=" target="_blank">
      Tracker Mothership:
      </a>
      </td>
      <td>
<a href="https://equipmentshare.looker.com/dashboards/579?Asset+Class=&amp;Model=&amp;Keypad+Install+Status=&amp;Make=&amp;Asset+Inventory+Status=Assigned%2CHard+Down%2CNeeds+Inspection%2CPre-Delivered%2CPending+Return%2COn+Rent%2CReady+To+Rent%2CSoft+Down&amp;Ownership=ES%2COWN%2CRETAIL&amp;Tracker+Firmware+Version=&amp;Camera+Req=&amp;Ecm+Hardware=&amp;Market+Name={{ f_market }}&amp;Camera+Install+Status=&amp;Last+Checkin+Timestamp+Date=&amp;Camera+Vendor=&amp;Asset+Health+Status=&amp;Test+Status=&amp;Asset+ID=&amp;District={{ f_district }}&amp;Category=&amp;Region={{ f_region }}&amp;Tracker+Req+Type=MCX%2FLMU%2CSLAP+N+TRACK%2CMC4%2F5+ONLY%2CMC4%2F5+OR+FJ&amp;Owning+Company+Name=&amp;Tracker+Serial=&amp;Has+Can=&amp;Telematics+Region=&amp;Installed+Tracker+Type=&amp;Tracker+Model+Installed=&amp;Asset+Health+Detail=&amp;Service%2FRetail+Branch=&amp;Custom+Name=" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>
      <a href="https://equipmentshare.looker.com/dashboards/303?Rental%20Start%20Date=5%20day&amp;Region%20Name={{ f_region }}&amp;Market={{ f_market }}&amp;Class%20Requested=&amp;Rental%20Status=On%20Rent&amp;District={{ f_district }}&amp;Salesperson=&amp;Class%20On%20Rent=&amp;Renting%20Company="target="_blank">
      Substitution Report:
      </a>
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/303?Rental%20Start%20Date=5%20day&amp;Region%20Name={{ f_region }}&amp;Market={{ f_market }}&amp;Class%20Requested=&amp;Rental%20Status=On%20Rent&amp;District={{ f_district }}&amp;Salesperson=&amp;Class%20On%20Rent=&amp;Renting%20Company="target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

       <td>
      <a href="https://equipmentshare.looker.com/dashboards/745?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}"target="_blank">
      Assets with Overage Hours:
      </a>
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/745?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}"target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

       <td>
      <a href="https://equipmentshare.looker.com/looks/1185?f[market_region_xwalk.market_name]={{ f_market }}&amp;f[market_region_xwalk.district]={{ f_district }}&amp;f[market_region_xwalk.region_name]={{ f_region }}&amp;toggle=det"target="_blank">
      Market Rental Revenue by Primary Sales Rep:
      </a>
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/looks/1185?f[market_region_xwalk.market_name]={{ f_market }}&amp;f[market_region_xwalk.district]={{ f_district }}&amp;f[market_region_xwalk.region_name]={{ f_region }}&amp;toggle=det"target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1784?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}" target="_blank">
      Outside Hauling POs with Invoice but No Matching Delivery:
      </a>
      </td>
      <td>

      <a href="https://equipmentshare.looker.com/dashboards/1784?Market={{ f_market }}&amp;Region={{ f_region }}&amp;District={{ f_district }}" target="_blank">
      ➔
      </a>
      </td>
      </tr>
      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>




      </table>
      ;;
  }

  measure: dashboard_info_icon {
    type: sum
    sql: 0 ;;
    drill_fields: [dashboard_info]
    html:
    <a href="#drillmenu" target="_self">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 2em; height: 2em; padding 1.4em 0.7em 0.5em 0.5em">
    </a>
    ;;
  }


  measure: dashboard_info {
    type: string
    sql: DISTINCT ' ' ;;
    html:
    <div style= "
    display: border-box;
    vertical-align: top;
    border: 1px solid #D6D6D6;
    height: 50vh;
    width: 98%;
    border_radius: 4px;
    background-color: #F4F4F4;
    text-align: center;
    font-size: 18px;
    font-family: PT Sans;
    margin: 20px auto;
    padding: 10px;
    box-shadown: rgba(0, 0, 0, 0.35) 0px 5px 15px;
    overflow: auto;
    ">
    <div style="font-weight: 600">Metric Information:</div>
    <div style="">
    Testing a new way to communicate to users around dashboard or metric information!
    </div>
    <br />
    <div style="font-weight: 600">New Metric Line With Image:</div>
    <div style="padding: 1.4em;">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 4.6em; height: 4.8em; padding 1.4em 0.7em 0.5em 0.5em">
    <span>Positive feedback can be sent to Mark Wopata :)</span>
    </div>
    <div style="padding: 1.4em;">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 4.6em; height: 4.8em; padding 1.4em 0.7em 0.5em 0.5em">
    <span>
    <font color="blue "><u><a href="https://equipmentshare-university.docebosaas.com/lms/index.php?r=course/deeplink&course_id=324&generated_by=13028&hash=a6cfed6b934a8427cd9cee1d3c9ae3111610979e" target="_blank">Testing a link to a Looker video</a></font></u>
    </span>
    </div>
    <div style="padding: 1.4em;">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 4.6em; height: 4.8em; padding 1.4em 0.7em 0.5em 0.5em">
    <span>
    <font color="blue "><u><a href="https://equipmentshare.slack.com/archives/CSMH54ZNG" target="_blank">Testing linking a user to the #help-looker channel</a></font></u>
    </span>
    </div>
    </div>
    ;;
  }

  set: detail {
    fields: [
        region,
  district,
  market,
  market_type
    ]
  }
}
