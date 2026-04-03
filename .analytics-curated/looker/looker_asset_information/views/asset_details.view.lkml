view: asset_details {
  derived_table: {
    sql:
      WITH pivot_data AS (
        SELECT
          asset_id,
          MAX(CASE WHEN name = 'location'
                   THEN ST_Y(TO_GEOGRAPHY(value)) END) AS asset_lat,
          MAX(CASE WHEN name = 'location'
                   THEN ST_X(TO_GEOGRAPHY(value)) END) AS asset_lon,
          MAX(CASE WHEN name = 'hours'
                   THEN TRY_TO_NUMBER(value) END) AS hours,
          MAX(updated) AS updated
        FROM ES_WAREHOUSE.PUBLIC.asset_status_key_values
        WHERE {% condition asset_id_filter %} asset_id {% endcondition %}
        GROUP BY asset_id
      )
      SELECT
        a.asset_id,
        a.make,
        a.model,
        a.description,
        a.rental_branch_id,
        a.inventory_branch_id,
        a.rental_branch_name,
        a.last_rental_date,
        a.inventory_branch_name,
        a.inventory_transit_status,
        tm.asset_health_status,
        tm.asset_health_detail AS asset_status_tracker,
        tm.tracker_vendor,
        tm.last_checkin_timestamp,
        tm.last_location,
        tm.tracker_model,
        tm.tracker_install_status,
        pivot_data.asset_lat,
        pivot_data.asset_lon,
        pivot_data.hours,
        pivot_data.updated
      FROM analytics.assets.int_assets a
      LEFT JOIN pivot_data
        ON a.asset_id = pivot_data.asset_id
      LEFT JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__TELEMATICS_HEALTH tm
        ON a.asset_id = tm.asset_id
      WHERE {% condition asset_id_filter %} a.asset_id {% endcondition %}
    ;;
  }

  filter: asset_id_filter {
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_class {
    type: number
    sql: ${TABLE}.asset_class ;;
  }

  dimension: make {
    type: number
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: number
    sql: ${TABLE}.model ;;
  }

  dimension: latest_updated {
    type: date
    sql: MAX(${TABLE}.updated) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: end_date {
    type: date
    sql: CAST(${TABLE}.end_date AS DATE) ;;
  }

  dimension: asset_status {
    type: string
    sql: ${TABLE}.value ;;
  }

  dimension: inventory_transit_status {
    type: string
    sql: ${TABLE}.inventory_transit_status ;;
  }

  dimension: asset_health_status {
    type: string
    sql: ${TABLE}.asset_health_status ;;
  }

  dimension: asset_status_tracker {
    type: string
    sql: ${TABLE}.asset_status_tracker ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}.tracker_vendor ;;
  }

  dimension: tracker_model {
    type: string
    sql: ${TABLE}.tracker_model ;;
  }

  dimension: tracker_install_status {
    type: string
    sql: ${TABLE}.tracker_install_status ;;
  }

  dimension: asset_lat {
    type: number
    sql: ${TABLE}."ASSET_LAT" ;;
  }

  dimension: asset_lon {
    type: number
    sql: ${TABLE}."ASSET_LON" ;;
  }

  dimension: asset_location {
    type: location
    sql_latitude: ${asset_lat} ;;
    sql_longitude: ${asset_lon} ;;
  }

  dimension: oec_adjusted {
    type: number
    sql: ${TABLE}."OEC_ADJUSTED" ;;
  }

  dimension: annualized_revenue {
    type: number
    sql: ${TABLE}."ANNUALIZED_REVENUE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: hours {
    type: string
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: rental_market_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }

  dimension: inventory_market_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }

  dimension: make_model {
    type: string
    sql: concat(${TABLE}."MAKE", ' - ', ${TABLE}."MODEL") ;;
  }

  measure: last_rental {
    type: date
    sql: max(case when ${TABLE}.last_rental_date = '9999-12-31' then CURRENT_DATE() else ${TABLE}.last_rental_date end);;
    html: {{ rendered_value | date: "%m/%d/%Y" }} ;;
  }

  measure: last_checkin_timestamp {
    type: date
    sql: max(${TABLE}.last_checkin_timestamp);;
    html: {{ rendered_value | date: "%m/%d/%Y" }} ;;
  }

  measure: days_since_last_status_update {
    type: number
    sql: DATEDIFF(DAY, ${latest_updated}, CURRENT_TIMESTAMP()) ;;
    description: "Time in days since the asset status was last updated"
    drill_fields: [customer_activity_feed.timestamp_for_activity_date]
  }

  measure: asset_info_card {
    group_label: "Asset Info Card"
    type: string
    label: " "
    sql: 'Asset Info' ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
      <!-- Asset Info Section -->
      <tr>
        <td colspan="2" style="text-align: left; font-weight: bold; padding-top: 5px; font-size: 17px;">Asset Info</td>
      </tr>
      <tr>
        <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 10px 0;"></td>
      </tr>
      <tr>
        <td style="width: 50%; text-align: left; height: 25px;">Asset ID:</td>
        <td style="text-align: right;">{{ asset_id._value }}</td>
      </tr>
      <tr>
        <td style="width: 50%; text-align: left; height: 25px;">Ownership:</td>
        <td style="text-align: right;">{{ companies.name._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Make:</td>
        <td style="text-align: right;">{{ assets.make._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Model:</td>
        <td style="text-align: right;">{{ assets.model._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Class:</td>
        <td style="text-align: right;">{{ assets.asset_class._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Year:</td>
        <td style="text-align: right;">{{ assets.year._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Serial Number:</td>
        <td style="text-align: right;">{{ assets.serial_number._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Hours:</td>
        <td style="text-align: right;">{{ hours._value | round }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px; vertical-align: top;">Description:</td>
        <td style="text-align: right; vertical-align: top;">{{ description._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Rental Branch:</td>
        <td style="text-align: right;">{{ rental_market_name._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Inventory Branch:</td>
        <td style="text-align: right;">{{ inventory_market_name._value }}</td>
      </tr>
      <!-- Asset Status Section -->
      <tr>
        <td colspan="2" style="text-align: left; font-weight: bold; padding-top: 5px; font-size: 17px;">Asset Status</td>
      </tr>
      <tr>
        <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 10px 0;"></td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Inventory Status:</td>
        <td style="text-align: right;">
          {% assign status = inventory_transit_status._value %}
          {% if status == 'Ready To Rent' %}
            <span style="color: #4CAF50; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status == 'On Rent' %}
            <span style="color: #4CAF50; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status == 'Hard Down' or status == 'Soft Down' or status == 'Soft Down - In Transit' %}
            <span style="color: #D32F2F; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status == 'Make Ready' %}
            <span style="color: #BDBDBD; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status == 'Needs Inspection'  or status == 'Ready To Rent - In Transit' %}
            <span style="color: #FBC02D; margin-right: 6px; vertical-align: middle;">◉</span>
          {% endif %}
          <span style="vertical-align: middle;">{{ status }}</span>
        </td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Days Since Last Inventory Status Update:</td>
        <td style="text-align: right;">{{ days_since_last_status_update._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Last Rental:</td>
        <td style="text-align: right;">{{ last_rental._value | date: "%m/%d/%Y" }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Transfer Status:</td>
        <td style="text-align: right;">{{ asset_transfer_status.status._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Last Transfer Status Update:</td>
        <td style="text-align: right;">{{ asset_transfer_status._es_update_timestamp._value | date: "%m/%d/%Y" }}</td>
      </tr>
      <!-- Tracker Info Section -->
      <tr>
        <td colspan="2" style="text-align: left; font-weight: bold; padding-top: 5px; font-size: 17px;">Tracker Info</td>
      </tr>
      <tr>
        <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 10px 0;"></td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Asset Health Status:</td>
        <td style="text-align: right;">
          {% assign status_2 = asset_health_status._value %}
          {% if status_2 == 'HEALTHY' %}
            <span style="color: #4CAF50; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status_2 == 'NEEDS TELEMATICS ATTENTION' or status_2 == 'NO TRACKER INSTALLED' %}
            <span style="color: #D32F2F; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status_2 == 'UNSTABLE' %}
            <span style="color: #94fab6; margin-right: 6px; vertical-align: middle;">◉</span>
          {% elsif status_2 == 'NEEDS SERVICE ATTENTION' %}
            <span style="color: #691a1e; margin-right: 6px; vertical-align: middle;">◉</span>
          {% endif %}
          <span style="vertical-align: middle;">{{ status_2 }}</span>
        </td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Asset Tracker Status:</td>
        <td style="text-align: right;">{{ asset_status_tracker._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Tracker Install Status:</td>
        <td style="text-align: right;">{{ tracker_install_status._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Tracker Vendor:</td>
        <td style="text-align: right;">{{ tracker_vendor._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Tracker Model:</td>
        <td style="text-align: right;">{{ tracker_model._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Last Check In:</td>
        <td style="text-align: right;">{{ last_checkin_timestamp._value | date: "%m/%d/%Y" }}</td>
      </tr>
    </table>
    ;;
  }
}
