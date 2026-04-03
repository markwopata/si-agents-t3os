view: branch_earnings_dds {
  sql_table_name: "PUBLIC"."BRANCH_EARNINGS_DDS"
    ;;

  dimension: acctno {
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: amt {
    type: number
    sql: ${TABLE}."AMT" ;;
  }

  dimension: ar_type {
    type: string
    sql: ${TABLE}."AR_TYPE" ;;
  }

  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
  }

  dimension: dept {
    type: string
    sql: ${TABLE}."DEPT" ;;
  }

  dimension: descr {
    type: string
    sql: ${TABLE}."DESCR" ;;
  }

  dimension: doc_no {
    type: string
    sql: ${TABLE}."DOC_NO" ;;
  }

  dimension: gl_acct {
    type: string
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension_group: gl {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: mkt_id {
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: mkt_name {
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
  }

  dimension: pk {
    type: string
    sql: ${TABLE}."PK" ;;
  }

  dimension: pr_type {
    type: string
    sql: ${TABLE}."PR_TYPE" ;;
  }

  dimension: revexp {
    type: string
    sql: ${TABLE}."REVEXP" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: url_sage {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
  }

  dimension: url_yooz {
    type: string
    sql: ${TABLE}."URL_YOOZ" ;;
  }

  dimension: url_track {
    type:  string
    sql:  ${TABLE}."URL_TRACK" ;;
  }

  measure: count {
    type: count
    drill_fields: [mkt_name]
  }
}
