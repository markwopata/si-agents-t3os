view: pec_contact {
  sql_table_name: "PEC"."PEC_CONTACT"
    ;;

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

  dimension: cmp_addr_1 {
    type: string
    sql: ${TABLE}."CMP_ADDR_1" ;;
  }

  dimension: cmp_addr_2 {
    type: string
    sql: ${TABLE}."CMP_ADDR_2" ;;
  }

  dimension: cmp_city {
    type: string
    sql: ${TABLE}."CMP_CITY" ;;
  }

  dimension: cmp_cntry {
    type: string
    sql: ${TABLE}."CMP_CNTRY" ;;
  }

  dimension: cmp_id {
    type: number
    sql: ${TABLE}."CMP_ID" ;;
  }

  dimension: cmp_name {
    type: string
    sql: ${TABLE}."CMP_NAME" ;;
  }

  dimension: cmp_state {
    type: string
    sql: ${TABLE}."CMP_STATE" ;;
  }

  dimension: cmp_zip {
    type: string
    sql: ${TABLE}."CMP_ZIP" ;;
  }

  dimension: cont_email {
    type: string
    sql: ${TABLE}."CONT_EMAIL" ;;
  }

  dimension: cont_fname {
    type: string
    sql: ${TABLE}."CONT_FNAME" ;;
  }

  dimension: cont_id {
    type: number
    sql: ${TABLE}."CONT_ID" ;;
  }

  dimension: cont_lname {
    type: string
    sql: ${TABLE}."CONT_LNAME" ;;
  }

  dimension: cont_phone {
    type: string
    sql: ${TABLE}."CONT_PHONE" ;;
  }

  dimension: cont_title {
    type: string
    sql: ${TABLE}."CONT_TITLE" ;;
  }

  dimension: contact_mobile {
    type: number
    sql: ${TABLE}."CONTACT_MOBILE" ;;
  }

  dimension: linkedin {
    type: string
    sql: ${TABLE}."LINKEDIN" ;;
  }

  dimension: mv_order {
    type: number
    sql: ${TABLE}."MV_ORDER" ;;
  }

  dimension: plant_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PLANT_ID" ;;
  }

  dimension: proj_id {
    type: string
    sql: ${TABLE}."PROJ_ID" ;;
  }

  dimension: proj_name {
    type: string
    sql: ${TABLE}."PROJ_NAME" ;;
  }

  dimension: proj_resp {
    type: string
    sql: ${TABLE}."PROJ_RESP" ;;
  }

  dimension: vendor {
    type: number
    sql: ${TABLE}."VENDOR" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      proj_name,
      cont_fname,
      cmp_name,
      cont_lname,
      plant.p_st_name,
      plant.owner_name,
      plant.plant_name,
      plant.plant_id
    ]
  }
}
