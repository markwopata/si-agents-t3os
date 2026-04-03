view: plant {
  sql_table_name: "PEC"."PLANT"
    ;;
  drill_fields: [plant_id]

  dimension: plant_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PLANT_ID" ;;
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
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
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: ind_code {
    type: string
    sql: ${TABLE}."IND_CODE" ;;
  }

  dimension: ind_desc {
    type: string
    sql: ${TABLE}."IND_DESC" ;;
  }

  dimension: owner_id_1 {
    type: number
    value_format_name: id
    sql: ${TABLE}."OWNER_ID_1" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: p_country {
    type: string
    sql: ${TABLE}."P_COUNTRY" ;;
  }

  dimension: p_st_name {
    type: string
    sql: ${TABLE}."P_ST_NAME" ;;
  }

  dimension: pecweb_url {
    type: string
    sql: ${TABLE}."PECWEB_URL" ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE" ;;
  }

  dimension: phys_addr {
    type: string
    sql: ${TABLE}."PHYS_ADDR" ;;
  }

  dimension: phys_addr_2 {
    type: string
    sql: ${TABLE}."PHYS_ADDR_2" ;;
  }

  dimension: phys_city {
    type: string
    sql: ${TABLE}."PHYS_CITY" ;;
  }

  dimension: phys_state {
    type: string
    sql: ${TABLE}."PHYS_STATE" ;;
  }

  dimension: phys_zip {
    type: string
    sql: ${TABLE}."PHYS_ZIP" ;;
  }

  dimension: plant_name {
    type: string
    sql: ${TABLE}."PLANT_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      plant_id,
      p_st_name,
      owner_name,
      plant_name,
      pec.count,
      pec_contact.count,
      plant_contact.count
    ]
  }
}
