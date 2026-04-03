view: fact_safety_observation_details {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_SAFETY_OBSERVATION_DETAILS" ;;

  dimension: safety_observation_employee_key {
    type: string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_EMPLOYEE_KEY" ;;
  }

  dimension: safety_observation_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_KEY" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: safety_observation_market_key {
    type: string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_MARKET_KEY" ;;
  }

  dimension: safety_observation_observation_date_final_key {
    type: string
    sql: ${TABLE}."SAFETY_OBSERVATION_OBSERVATION_DATE_FINAL_KEY" ;;
  }

  dimension: safety_observation_observation_date_key {
    type: string
    sql: ${TABLE}."SAFETY_OBSERVATION_OBSERVATION_DATE_KEY" ;;
  }

  dimension: safety_observation_observation_time_final_key {
    type: string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_OBSERVATION_TIME_FINAL_KEY" ;;
  }

  dimension: safety_observation_observation_time_key {
    type: string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_OBSERVATION_TIME_KEY" ;;
  }

  dimension: safety_observation_submission_date_key {
    type: string
    sql: ${TABLE}."SAFETY_OBSERVATION_SUBMISSION_DATE_KEY" ;;
  }

  dimension: safety_observation_submission_time_key {
    type: string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_SUBMISSION_TIME_KEY" ;;
  }

  dimension: corrective_action {
    type: string
    sql: ${TABLE}."CORRECTIVE_ACTION";;
  }

  dimension: corrective_action_html {
    type: string
    group_label: "HTML Corrective Action & Observation"
    sql: ${TABLE}."CORRECTIVE_ACTION" ;;
    html: <font color="#000000">
          {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">{{corrective_action_type._rendered_value}}</font>
          </font> ;;
  }

  dimension: corrective_action_explanation {
    type: string
    sql: ${TABLE}."CORRECTIVE_ACTION_EXPLANATION";;
  }

  dimension: corrective_action_type {
    type: string
    sql: ${TABLE}."CORRECTIVE_ACTION_TYPE";;
  }

  dimension: has_uploaded_photos {
    type: yesno
    sql: ${TABLE}."HAS_UPLOADED_PHOTOS";;
  }

  dimension: has_uploaded_photos_html {
    type: yesno
    group_label: "HTML Corrective Action & Observation"
    sql: ${TABLE}."HAS_UPLOADED_PHOTOS";;
    html: {% if safety_observation.has_uploaded_photos._rendered_value == 'No' %}
          {% else %}
          <font color="#0000FF">
          <a href="https://equipmentshare.looker.com/dashboards/1746?Safety+Observation+Key={{safety_observation_key._filterable_value | url_encode}}" target="_blank">
          See Photos ➔
          </a></font>
          {% endif %};;
    suggest_persist_for: "1 minute"
  }

  dimension: observation_category {
    type: string
    sql: ${TABLE}."OBSERVATION_CATEGORY";;
  }

  dimension: observation_category_html {
    type: string
    group_label: "HTML Corrective Action & Observation"
    sql: ${TABLE}."OBSERVATION_CATEGORY" ;;
    html: <font color="#000000">
          {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">{{observation_type._rendered_value}}</font>
          </font> ;;
  }

  dimension: observation_date_html {
    type: string
    group_label: "HTML Corrective Action & Observation"
    sql: ${observation_date.date} ;;
    required_fields: [dim_times.time_12_hh_mm_ss_am_pm]
    html: <font color="#000000">
          {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">{{dim_times.time_12_hh_mm_ss_am_pm._rendered_value}}</font>
          </font> ;;
  }

  dimension: observation_description {
    type: string
    sql: ${TABLE}."OBSERVATION_DESCRIPTION";;
  }

  dimension: observation_description_summary {
    type: string
    sql: ${TABLE}."OBSERVATION_DESCRIPTION_SUMMARY";;
  }

  dimension: observation_location {
    type: string
    sql: ${TABLE}."OBSERVATION_LOCATION";;
  }

  dimension: observation_type {
    type: string
    sql: ${TABLE}."OBSERVATION_TYPE";;
  }

  dimension: requires_safety_manager_escalation {
    type: yesno
    sql: ${TABLE}."REQUIRES_SAFETY_MANAGER_ESCALATION";;
  }

  dimension: safety_observation_id {
    type: string
    sql: ${TABLE}."SAFETY_OBSERVATION_ID" ;;
  }

  dimension_group: _created_recordtimestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }

  measure: photo_info_card {
    group_label: "Photo Info Card"
    type: string
    label: " "
    sql: 'Photo Info' ;;
    html:
      <table border="0" style="font-family: Verdana; font-size: 12px; color: #323232; width: 100%;">
      <tr>
        <td colspan="2" style="text-align: left; font-weight: bold; padding-top: 5px; font-size: 17px;">Photo Info</td>
      </tr>
      <tr>
        <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 10px 0;"></td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Date:</td>
        <td style="text-align: right;">{{ observation_date_html._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Time:</td>
        <td style="text-align: right;">{{ dim_times.time_12_hh_mm_ss_am_pm._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Market:</td>
        <td style="text-align: right;">{{ dim_markets.market_name._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">District:</td>
        <td style="text-align: right;">{{ dim_markets.market_district._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Category:</td>
        <td style="text-align: right;">{{ observation_category._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Type:</td>
        <td style="text-align: right;">{{ observation_type._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Location:</td>
        <td style="text-align: right;">{{ observation_location._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Observation Description Summary:</td>
        <td style="text-align: right;">{{ observation_description_summary._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Corrective Action:</td>
        <td style="text-align: right;">{{ corrective_action._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Corrective Action Type:</td>
        <td style="text-align: right;">{{ corrective_action_type._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Requires Safety Manager Escalation:</td>
        <td style="text-align: right;">{{ requires_safety_manager_escalation._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Employee:</td>
        <td style="text-align: right; vertical-align: top;">{{ dim_employees_bi.nickname._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Employee Email:</td>
        <td style="text-align: right;">{{ dim_employees_bi.work_email._value }}</td>
      </tr>
      <tr>
        <td style="text-align: left; height: 25px;">Full Observation Description:</td>
        <td style="text-align: right;">{{ observation_description._value }}</td>
      </tr>

    </table>
    ;;
    required_access_grants: [safety_champion_exclusion]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_detail {
    label: "Observation Count"
    type: count
    drill_fields: [employee_detail*]
  }

  measure: near_miss_count {
    type: count
    filters: [observation_category: "Near-Miss"]
    drill_fields: [employee_detail*]
  }

  measure: unsafe_act_count {
    type: count
    filters: [observation_category: "Unsafe Act"]
    drill_fields: [employee_detail*]
  }

  measure: unspecified_count {
    type: count
    filters: [observation_category: "Unspecified"]
    drill_fields: [employee_detail*]
  }

  measure: positive_recognition_count {
    type: count
    filters: [observation_category: "Positive Recognition"]
    drill_fields: [employee_detail*]
  }

  measure: unsafe_condition_count {
    type: count
    filters: [observation_category: "Unsafe Condition"]
    drill_fields: [employee_detail*]
  }

  set: detail {
    fields: [
      dim_employees_bi.nickname,
      dim_markets.district,
      dim_employees_bi.location,
      observation_date_html,
      observation_location,
      observation_category,
      observation_type,
      observation_description_summary,
      has_uploaded_photos_html,
      corrective_action,
      corrective_action_type,
      requires_safety_manager_escalation
    ]
  }

  set: employee_detail {
    fields: [
      dim_employees_bi.nickname,
      dim_markets.district,
      dim_employees_bi.location,
      count
    ]
  }

  set: count_detail {
    fields: [
      dim_employees_bi.nickname,
      dim_markets.district,
      dim_employees_bi.location,
      count
    ]
  }

}
