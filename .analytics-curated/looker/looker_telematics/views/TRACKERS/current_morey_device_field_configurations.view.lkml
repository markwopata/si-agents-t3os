view: current_morey_device_field_configurations {
  sql_table_name: "ES_WAREHOUSE"."TRACKERS"."CURRENT_MOREY_DEVICE_FIELD_CONFIGURATIONS" ;;
  drill_fields: [current_morey_device_field_configuration_id]

  dimension: current_morey_device_field_configuration_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CURRENT_MOREY_DEVICE_FIELD_CONFIGURATION_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: array_field_type {
    type: string
    sql: ${TABLE}."ARRAY_FIELD_TYPE" ;;
  }
  dimension: configuration_eid {
    type: string
    sql: ${TABLE}."CONFIGURATION_EID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: field_type {
    type: string
    sql: ${TABLE}."FIELD_TYPE" ;;
  }
  dimension: field_value {
    type: string
    sql: ${TABLE}."FIELD_VALUE" ;;
  }
  dimension: is_error {
    type: yesno
    sql: ${TABLE}."IS_ERROR" ;;
  }
  dimension: morey_field_configuration_log_id {
    type: number
    sql: ${TABLE}."MOREY_FIELD_CONFIGURATION_LOG_ID" ;;
  }
  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }
  dimension: ip_address_check {
    type: string
    sql: CASE WHEN ${TABLE}.configuration_eid = '41a' and ${TABLE}.field_value <> 'morey.tracking.equipmentshare.com:9874'
                  THEN 'Check IP Address'
              WHEN ${TABLE}.configuration_eid = '41a' and ${TABLE}.field_value =  'morey.tracking.equipmentshare.com:9874'
                  THEN 'IP Address OK'
         ELSE 'N/A'
         END;;
  }
  dimension: application_update_server_check {
    type: string
    sql: CASE WHEN ${TABLE}.configuration_eid = '41d' and ${TABLE}.field_value <> 'morey-ota.tracking.equipmentshare.com:9878'
                  THEN 'Check Application Server Address'
              WHEN ${TABLE}.configuration_eid = '41d' and ${TABLE}.field_value =  'morey-ota.tracking.equipmentshare.com:9878'
                  THEN 'Application Server Address OK'
         ELSE 'N/A'
         END;;
  }
  dimension: vbus_check {
    type: string
    sql:  -- field value 13 is 3 wire install and needs excluded. Also field values 16 and 17 are MC5 compatible only but are ok values
          CASE WHEN ${TABLE}.configuration_eid = '44d' and (${TABLE}.field_value <= '1' or ${TABLE}.field_value >= '17') and ${TABLE}.field_value <> '13'
                  THEN 'Check VBUS'
              WHEN ${TABLE}.configuration_eid = '44d' and (${TABLE}.field_value >  '1' or ${TABLE}.field_value <  '17') and ${TABLE}.field_value <> '13'
                  THEN 'VBUS OK'
         ELSE 'N/A'
         END;;
  }

  dimension: Current_VBUS {
    type: string
    sql:
          CASE WHEN ${TABLE}.configuration_eid = '44d' THEN
            CASE ${TABLE}.field_value
               WHEN '0'  THEN 'OFF'
               WHEN '1'  THEN 'Active Scan'
               WHEN '2'  THEN 'CAN 250 11-bit'
               WHEN '3'  THEN 'CAN 250 29-bit'
               WHEN '4'  THEN 'KWP2000'
               WHEN '5'  THEN 'GMLAN'
               WHEN '6'  THEN 'FORD J1850'
               WHEN '7'  THEN 'CAN 500 11-bit'
               WHEN '8'  THEN 'CAN 500 29-bit'
               WHEN '9'  THEN 'J1708'
               WHEN '10' THEN 'CAN 250 J1939'
               WHEN '11' THEN 'ISO9141'
               WHEN '12' THEN 'CAN 500 J1939'
               WHEN '13' THEN '3-wire Install'
               WHEN '14' THEN 'CAN Open'
               ELSE 'Unknown VBUS value: ' || field_value
            END
         ELSE 'N/A'
         END;;
  }

  measure: count {
    type: count
    drill_fields: [current_morey_device_field_configuration_id]
  }
}
