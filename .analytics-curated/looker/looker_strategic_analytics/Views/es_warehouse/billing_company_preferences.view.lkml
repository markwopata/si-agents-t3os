
view: billing_company_preferences {
  sql_table_name:es_warehouse.public.billing_company_preferences;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: billing_company_preferences_id {
    type: string
    sql: ${TABLE}."BILLING_COMPANY_PREFERENCES_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }

  dimension: prefs {
    type: string
    sql: ${TABLE}."PREFS" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        billing_company_preferences_id,
  company_id,
  date_created_time,
  date_updated_time,
  rental_billing_cycle_strategy,
  prefs,
  _es_update_timestamp_time
    ]
  }
}
