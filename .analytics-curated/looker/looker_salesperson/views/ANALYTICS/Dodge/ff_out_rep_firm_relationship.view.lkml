view: ff_out_rep_firm_relationship {
  sql_table_name: "DODGE"."FF_OUT_REP_FIRM_RELATIONSHIP"
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

  dimension: bid_amt {
    type: number
    sql: ${TABLE}."BID_AMT" ;;
  }

  dimension: bid_award_ind {
    type: string
    sql: ${TABLE}."BID_AWARD_IND" ;;
  }

  dimension: bid_create_date {
    type: number
    sql: ${TABLE}."BID_CREATE_DATE" ;;
  }

  dimension: bid_rank {
    type: number
    sql: ${TABLE}."BID_RANK" ;;
  }

  dimension: bid_withdraw_ind {
    type: string
    sql: ${TABLE}."BID_WITHDRAW_IND" ;;
  }

  dimension: bidders_list {
    type: string
    sql: ${TABLE}."BIDDERS_LIST" ;;
  }

  dimension: contact_role {
    type: string
    sql: ${TABLE}."CONTACT_ROLE" ;;
  }

  dimension: contact_role_code {
    type: string
    sql: ${TABLE}."CONTACT_ROLE_CODE" ;;
  }

  dimension: dcis_factor_cntct_code {
    type: string
    sql: ${TABLE}."DCIS_FACTOR_CNTCT_CODE" ;;
  }

  dimension: dcis_factor_code {
    type: string
    sql: ${TABLE}."DCIS_FACTOR_CODE" ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}."DR_NBR" ;;
  }

  dimension: dr_ver {
    type: number
    sql: ${TABLE}."DR_VER" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
