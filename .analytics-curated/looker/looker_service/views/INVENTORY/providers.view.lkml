view: providers {
  derived_table: {
    sql: select pr._es_update_timestamp
              , pr.date_created
              , pr.date_updated
              , pr.provider_id
              , pr.name
              , pr.verified
              , pr.company_id
              , pr.date_archived
              , pr.verified_globally
              , pr.sku_field
              , pr.verified_for_company
              , api.provider_id as attachment_flag
         from ES_WAREHOUSE.INVENTORY.PROVIDERS pr
          left join ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS api
            on pr.provider_id = api.provider_id;;
  }

  drill_fields: [provider_id]

  dimension: provider_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: name {
    type: string
    label: "Provider"
    sql: ${TABLE}."NAME" ;;
  }

  dimension: verified {
    type: yesno
    sql: ${TABLE}."VERIFIED" ;;
  }

  dimension: is_bulk {
    type: yesno
    sql: ${TABLE}."NAME" ilike 'bulk -%';;
  }

  dimension: is_attachment {
    type: yesno
    sql: ${TABLE}."ATTACHMENT_FLAG" is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [provider_id, name]
  }
}
