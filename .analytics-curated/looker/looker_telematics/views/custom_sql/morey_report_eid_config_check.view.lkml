
view: morey_report_eid_config_check {
  derived_table: {
    sql: select A.ASSET_ID,
             A.TRACKER_ID                                                                   AS ESDB_TRACKER_ID,
             MDRC.TRACKER_ID,
             MDRC.EVENT_EID,
             ETT.DEVICE_SERIAL                                                              AS TRACKER_SERIAL,
             IFF(ARRAY_SORT(MDRC.FIELD_EIDS) = ARRAY_SORT(strtok_to_array(LOWER(MERD.FIELD_VALUE), ', ')), 'MATCH',
                 'NEEDS ATTENTION')                                                         AS FIELD_EIDS_NEED_ATTENTION,
             ARRAY_SORT(ARRAY_INTERSECTION(MDRC.FIELD_EIDS,
                                           strtok_to_array(LOWER(MERD.FIELD_VALUE), ', '))) AS MATCHING_CURRENT_EIDS,
             ARRAY_SORT(ARRAY_EXCEPT(strtok_to_array(LOWER(MERD.FIELD_VALUE), ', '),
                                     MDRC.FIELD_EIDS))                                      AS MISSING_CURRENT_EIDS,
             ARRAY_SIZE(MISSING_CURRENT_EIDS)                                               AS COUNT_OF_MISSING_REPORT_EIDS,
             IFF(ARRAY_SIZE(MISSING_CURRENT_EIDS) < 1, 'MEETS MINIMUM', 'NEEDS ATTENTION')  AS MINIMUM_EXPECTED_EIDS_INCLUDED,
             ARRAY_SORT(MDRC.FIELD_EIDS)                                                    AS CURRENT_DEVICE_REPORT_CONFIG_EIDS,
             ARRAY_SORT(strtok_to_array(LOWER(MERD.FIELD_VALUE), ', '))                     AS ES_EXPECTED_CONFIGURATION_EIDS
      from ES_WAREHOUSE.TRACKERS.MOREY_DEVICE_REPORT_CONFIGURATIONS MDRC
               left join ANALYTICS.BI_OPS.MOREY_ES_REPORT_DEFINITIONS MERD
                         on MDRC.EVENT_EID ILIKE '0' || MERD.EVENT_EID
               left join ES_WAREHOUSE.TRACKERS.TRACKERS ETT
                         on MDRC.TRACKER_ID = ETT.TRACKER_ID
               left join ES_WAREHOUSE.PUBLIC.TRACKERS_MAPPING TM
                         on MDRC.TRACKER_ID = TM.TRACKER_TRACKER_ID
               Left join ES_WAREHOUSE.PUBLIC.ASSETS A
                         on TM.ESDB_TRACKER_ID = A.TRACKER_ID ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_distinct_asset_id {
    type: count_distinct
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [detail*]
  }

  measure: count_distinct_tracker_id {
    type: count_distinct
    sql: ${TABLE}."TRACKER_ID" ;;
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: esdb_tracker_id {
    type: number
    sql: ${TABLE}."ESDB_TRACKER_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: event_eid {
    type: string
    sql: ${TABLE}."EVENT_EID" ;;
  }

  dimension: tracker_serial {
    type: string
    sql: ${TABLE}."TRACKER_SERIAL" ;;
  }

  dimension: field_eids_need_attention {
    type: string
    sql: ${TABLE}."FIELD_EIDS_NEED_ATTENTION" ;;
  }

  dimension: matching_current_eids {
    type: string
    sql: ${TABLE}."MATCHING_CURRENT_EIDS" ;;
  }

  dimension: missing_current_eids {
    type: string
    sql: ${TABLE}."MISSING_CURRENT_EIDS" ;;
  }

  dimension: count_of_missing_report_eids {
    type: number
    sql: ${TABLE}."COUNT_OF_MISSING_REPORT_EIDS" ;;
  }

  dimension: minimum_expected_eids_included {
    type: string
    sql: ${TABLE}."MINIMUM_EXPECTED_EIDS_INCLUDED" ;;
  }

  dimension: current_device_report_config_eids {
    type: string
    sql: ${TABLE}."CURRENT_DEVICE_REPORT_CONFIG_EIDS" ;;
  }

  dimension: es_expected_configuration_eids {
    type: string
    sql: ${TABLE}."ES_EXPECTED_CONFIGURATION_EIDS" ;;
  }

  dimension: attached_to_asset {
    type: string
    sql: IFF(${TABLE}."ASSET_ID" IS NULL, 'NO', 'YES') ;;
  }

  dimension: serial_with_trackers_manager_link {
    type: string
    sql: ${TABLE}."TRACKER_SERIAL" ;;
    link: {
      label: "Trackers Manager"
      url: "https://tracker-manager.equipmentshare.com/#/trackers/search?trackers={{ value | url_encode }}"
    }
    description: "This links out to the Trackers Manager Platform"
  }

  set: detail {
    fields: [
        asset_id,
  esdb_tracker_id,
  tracker_id,
  event_eid,
  serial_with_trackers_manager_link,
  field_eids_need_attention,
  matching_current_eids,
  missing_current_eids,
  count_of_missing_report_eids,
  minimum_expected_eids_included,
  current_device_report_config_eids,
  es_expected_configuration_eids,
    ]
  }
}
