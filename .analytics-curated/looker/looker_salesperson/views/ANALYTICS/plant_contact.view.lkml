view: plant_contact {
  sql_table_name: "PEC"."PLANT_CONTACT"
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

  dimension: actual_title {
    type: string
    sql: ${TABLE}."ACTUAL_TITLE" ;;
  }

  dimension: cont_fnme {
    type: string
    sql: ${TABLE}."CONT_FNME" ;;
  }

  dimension: cont_id {
    type: number
    sql: ${TABLE}."CONT_ID" ;;
  }

  dimension: cont_lnme {
    type: string
    sql: ${TABLE}."CONT_LNME" ;;
  }

  dimension: contact_mobile {
    type: string
    sql: ${TABLE}."CONTACT_MOBILE" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: functional_title {
    type: string
    sql: ${TABLE}."FUNCTIONAL_TITLE" ;;
  }

  dimension: linkedin {
    type: string
    sql: ${TABLE}."LINKEDIN" ;;
  }

  dimension: on_site {
    type: string
    sql: ${TABLE}."ON_SITE" ;;
  }

  dimension: plant_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PLANT_ID" ;;
  }

  dimension: qc_date {
    type: number
    sql: ${TABLE}."QC_DATE" ;;
  }

  dimension: telephone {
    type: string
    sql: ${TABLE}."TELEPHONE" ;;
  }

  measure: count {
    type: count
    drill_fields: [plant.p_st_name, plant.owner_name, plant.plant_name, plant.plant_id]
  }
}
