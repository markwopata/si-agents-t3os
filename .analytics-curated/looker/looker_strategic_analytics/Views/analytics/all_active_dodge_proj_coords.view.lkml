view: all_active_dodge_proj_coords {
  sql_table_name: "ANALYTICS"."MEGA_PROJECTS"."ALL_ACTIVE_DODGE_PROJ_COORDS" ;;

  dimension: drnumber {
    type: string
    sql: ${TABLE}."DRNUMBER" ;;
  }

  dimension: primaryprojecttype {
    type: string
    sql: ${TABLE}."PRIMARYPROJECTTYPE" ;;
  }

  dimension: ownershiptype {
    type: string
    sql: ${TABLE}."OWNERSHIPTYPE" ;;
  }

  dimension: typeofwork {
    type: string
    sql: ${TABLE}."TYPEOFWORK" ;;
  }

  dimension: marketsegment {
    type: string
    sql: ${TABLE}."MARKETSEGMENT" ;;
  }

  dimension: statustext {
    type: string
    sql: ${TABLE}."STATUSTEXT" ;;
  }

  dimension: primarystage {
    type: string
    sql: ${TABLE}."PRIMARYSTAGE" ;;
  }

  dimension: long {
    type: string
    sql: ${TABLE}."LONG" ;;
  }

  dimension: valuationestlow {
    type: string
    sql: ${TABLE}."VALUATIONESTLOW" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: projecttitle {
    type: string
    sql: ${TABLE}."PROJECTTITLE" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: lat {
    type: string
    sql: ${TABLE}."LAT" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension_group: reportdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."REPORTDATE" ;;
  }

  dimension_group: est_completion_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."EST_COMPLETION_DATE" ;;
  }

  dimension_group: kickoff_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."KICKOFF_DATE" ;;
  }

  set: detail_drill {
    fields: [drnumber, projecttitle, city, state, reportdate_date, kickoff_date_date]
  }

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }
}
