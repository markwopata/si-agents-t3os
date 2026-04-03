view: intercom_section_history {
  derived_table: {
    sql: select * from
      ANALYTICS.INTERCOM.SECTION_HISTORY ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: updated_at {
    type: time
    sql: ${TABLE}."UPDATED_AT" ;;
  }

  dimension: parent_id {
    type: number
    sql: ${TABLE}."PARENT_ID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: workspace_id {
    type: string
    sql: ${TABLE}."WORKSPACE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  dimension: icon {
    type: string
    sql: ${TABLE}."ICON" ;;
  }

  dimension: default_locale {
    type: string
    sql: ${TABLE}."DEFAULT_LOCALE" ;;
  }

  dimension: order {
    type: number
    sql: ${TABLE}."ORDER" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension_group: _fivetran_start {
    type: time
    sql: ${TABLE}."_FIVETRAN_START" ;;
  }

  dimension_group: _fivetran_end {
    type: time
    sql: ${TABLE}."_FIVETRAN_END" ;;
  }

  dimension: _fivetran_active {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_ACTIVE" ;;
  }

  set: detail {
    fields: [
      id,
      updated_at_time,
      parent_id,
      type,
      workspace_id,
      name,
      created_at_time,
      url,
      icon,
      default_locale,
      order,
      _fivetran_synced_time,
      _fivetran_start_time,
      _fivetran_end_time,
      _fivetran_active
    ]
  }
}
