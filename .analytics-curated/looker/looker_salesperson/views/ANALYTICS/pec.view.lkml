view: pec {
  sql_table_name: "PEC"."PEC"
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

  dimension: activity_desc {
    type: string
    sql: ${TABLE}."ACTIVITY_DESC" ;;
  }

  dimension: afe_yearmo {
    type: number
    sql: ${TABLE}."AFE_YEARMO" ;;
  }

  dimension: bid_yearmo {
    type: number
    sql: ${TABLE}."BID_YEARMO" ;;
  }

  dimension: completion {
    type: number
    sql: ${TABLE}."COMPLETION" ;;
  }

  dimension: copyright {
    type: string
    sql: ${TABLE}."COPYRIGHT" ;;
  }

  dimension: county_des {
    type: string
    sql: ${TABLE}."COUNTY_DES" ;;
  }

  dimension: county_id {
    type: string
    sql: ${TABLE}."COUNTY_ID" ;;
  }

  dimension: engr_yearmo {
    type: number
    sql: ${TABLE}."ENGR_YEARMO" ;;
  }

  dimension: ind_desc {
    type: string
    sql: ${TABLE}."IND_DESC" ;;
  }

  dimension: kickoff {
    type: number
    sql: ${TABLE}."KICKOFF" ;;
  }

  dimension: live_date {
    type: string
    sql: ${TABLE}."LIVE_DATE" ;;
  }

  dimension: long_lead {
    type: number
    sql: ${TABLE}."LONG_LEAD" ;;
  }

  dimension: owner_id {
    type: number
    sql: ${TABLE}."OWNER_ID" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: pec_timing {
    type: string
    sql: ${TABLE}."PEC_TIMING" ;;
  }



  dimension: pecweb_url {
    type: string
    html:<font color="blue "><u><a href={{ pecweb_url._value }} target="_blank">Link to PEC Project</a></font></u> ;;
    sql: ${TABLE}."PECWEB_URL" ;;
  }

  dimension: pfuel_desc {
    type: string
    sql: ${TABLE}."PFUEL_DESC" ;;
  }

  dimension: pl_country {
    type: string
    sql: ${TABLE}."PL_COUNTRY" ;;
  }

  dimension: pl_phone {
    type: string
    sql: ${TABLE}."PL_PHONE" ;;
  }

  dimension: plant_addr {
    type: string
    sql: ${TABLE}."PLANT_ADDR" ;;
  }

  dimension: plant_city {
    type: string
    sql: ${TABLE}."PLANT_CITY" ;;
  }

  dimension: plant_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PLANT_ID" ;;
  }

  dimension: plant_name {
    type: string
    sql: ${TABLE}."PLANT_NAME" ;;
  }

  dimension: plant_st {
    type: string
    sql: ${TABLE}."PLANT_ST" ;;
  }

  dimension: plant_zip {
    type: string
    sql: ${TABLE}."PLANT_ZIP" ;;
  }



  dimension: proj_name {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/318?Proj%20Name={{ proj_name._value | url_encode }}" target="_blank">{{ proj_name._value }}</a></font></u>
        ;;
    sql: ${TABLE}."PROJ_NAME" ;;
  }

  dimension: proj_tiv {
    value_format_name: usd_0
    type: number
    sql: ${TABLE}."PROJ_TIV" ;;
  }

  dimension: project_id {
    type: number
    sql: ${TABLE}."PROJECT_ID" ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: release {
    type: string
    sql: ${TABLE}."RELEASE" ;;
  }

  dimension: rfq_yearmo {
    type: number
    sql: ${TABLE}."RFQ_YEARMO" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      plant_name,
      proj_name,
      owner_name,
      plant.p_st_name,
      plant.owner_name,
      plant.plant_name,
      plant.plant_id
    ]
  }
}
