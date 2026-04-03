
view: project_poptart_performance {
  derived_table: {
    sql: with tam_cte as (
      select distinct l.objectid, l.property_company_id, l.property_company_name, l.property_first_name, l.property_last_name, l.property_phone, l.property_tam_full_name tam_name, t.property_tracker_id, t.property_tracker_serial_number, t.property_tracker_type_name, t.property_status, t.property_hs_lastmodifieddate::DATE pipeline_stage_last_updated

      from HUBSPOT.V2_LIVE.OBJECTS_POP_TART_LEADS l

      left join HUBSPOT.V2_LIVE.ASSOCIATIONS_POP_TART_LEADS_TO_POP_TART_TRACKERS lt
      on l.objectid = lt.pop_tart_leads_objectid

      left join HUBSPOT.V2_LIVE.OBJECTS_POP_TART_TRACKERS t
      on lt.pop_tart_trackers_objectid = t.objectid

      )
      select distinct tam_name, property_company_id customer_company_id, property_company_name company_name, concat(property_first_name,' ', property_last_name) customer_name, property_phone customer_phone_number, property_tracker_id tracker_id, property_tracker_type_name tracker_type, property_status pipeline_stage, pipeline_stage_last_updated
      from tam_cte
      where tracker_id is not null and company_name is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: tam_name {
    type: string
    sql: ${TABLE}."TAM_NAME" ;;
  }

  dimension: customer_company_id {
    type: number
    sql: ${TABLE}."CUSTOMER_COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_phone_number {
    type: string
    sql: ${TABLE}."CUSTOMER_PHONE_NUMBER" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }

  dimension: pipeline_stage {
    type: string
    sql: ${TABLE}."PIPELINE_STAGE" ;;
  }

  dimension: pipeline_stage_last_updated {
    type: date
    sql: ${TABLE}."PIPELINE_STAGE_LAST_UPDATED" ;;
  }

  set: detail {
    fields: [
      tam_name,
      customer_company_id,
      company_name,
      customer_name,
      customer_phone_number,
      tracker_id,
      tracker_type,
      pipeline_stage,
      pipeline_stage_last_updated
    ]
  }
}
