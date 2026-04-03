view: intacct_no_billno_update {
  derived_table: {
    sql: SELECT
          APR.RECORDID,
          APR.WHENCREATED,
          APR.WHENMODIFIED,
          APR.PRBATCH_OPEN AS "PERIOD_STATE",
          PR.PRIOR_RECORDID,
          PR.PRBATCH_OPEN AS "PRIOR_TO_EDIT_PERIOD_STATE"

      FROM"ANALYTICS"."INTACCT"."APRECORD" APR

      LEFT JOIN (select RECORDID AS "PRIOR_RECORDID", RECORDNO, PRBATCH_OPEN from "ANALYTICS"."INTACCT"."APRECORD" at (offset => -60*60*24)) AS PR

      ON APR.RECORDNO = PR.RECORDNO

      WHERE APR.RECORDID != PR.PRIOR_RECORDID
      AND APR.PRBATCH_OPEN = 'Closed'
      AND PR.PRBATCH_OPEN = 'Closed'
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordid {
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }

  dimension: whencreated {
    type: date
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension_group: whenmodified {
    type: time
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  dimension: period_state {
    type: string
    sql: ${TABLE}."PERIOD_STATE" ;;
  }

  dimension: prior_recordid {
    type: string
    sql: ${TABLE}."PRIOR_RECORDID" ;;
  }

  dimension: prior_to_edit_period_state {
    type: string
    sql: ${TABLE}."PRIOR_TO_EDIT_PERIOD_STATE" ;;
  }

  set: detail {
    fields: [recordid, whencreated, whenmodified_time, prior_recordid, period_state, prior_to_edit_period_state]
  }
}
