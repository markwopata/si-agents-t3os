view: churn_tickets {
  derived_table: {
    sql: select
              t.id as ticket_id
          ,   try_cast(t.property_es_admin_id as int) as company_id
          ,   t.property_closed_date as closed_date
          ,   t.property_churn_type as churn_type
          ,   t.property_assets_lost as assets_lost
          ,   t.property_devices_lost as devices_lost
          ,   round(cast(replace(t.property_arrev_lost, '$', '') as int), 2) as arr_lost
          ,   t.property_deact_churn_summary_type_ as churn_summary_type
          ,   t.property_reason_for_churn_notes as reason_for_churn_notes
       from analytics.hubspot_customer_success.ticket t
       where property_churn_type = 'Company Churn'
       and t.property_closed_date >= dateadd(month, -13, dateadd(day, 1, last_day(getdate(), month)))
       and try_cast(t.property_es_admin_id as int) is not null ;;
  }

  dimension: ticket_id {
    type: number
    sql: ${TABLE}."TICKET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: closed_date {
    type: time
    sql: ${TABLE}."CLOSED_DATE" ;;
  }

  dimension: closed_day_formatted {
    group_label: "HTML Formatted Day"
    label: "Closed Date"
    type: date
    sql: ${TABLE}."CLOSED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: churn_type {
    type: string
    sql: ${TABLE}."CHURN_TYPE" ;;
  }

  dimension: assets_lost {
    type: number
    sql: ${TABLE}."ASSETS_LOST" ;;
  }

  dimension: devices_lost {
    type: number
    sql: ${TABLE}."DEVICES_LOST" ;;
  }

  dimension: arr_lost {
    type: number
    label: "ARR Lost"
    value_format_name: "usd_0"
    sql: ${TABLE}."ARR_LOST" ;;
  }

  dimension: churn_summary_type {
    type: string
    sql: ${TABLE}."CHURN_SUMMARY_TYPE" ;;
  }

  dimension: reason_for_churn_notes {
    type: string
    sql: ${TABLE}."REASON_FOR_CHURN_NOTES" ;;
  }

  measure: company_count {
    type: count_distinct
    sql: ${TABLE}.company_id ;;
  }

  measure: asset_count {
    type: sum
    sql: ${assets_lost} ;;
    drill_fields: [company_name, assets_lost]
  }

  measure: devices_count {
    type: sum
    sql: ${devices_lost} ;;
    drill_fields: [company_name, devices_lost]
  }

  measure: arr_lost_sum {
    type: sum
    value_format_name: "usd_0"
    sql: ${arr_lost} ;;
    drill_fields: [company_name, arr_lost]
  }

  dimension: company_name {
    sql: ${churn_company.company_name} ;;
  }

  set: detail {
    fields: [
      ticket_id,
      company_id,
      churn_type,
      assets_lost,
      devices_lost,
      arr_lost,
      churn_summary_type,
      reason_for_churn_notes
    ]
  }
}
