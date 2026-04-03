view: amortization_schedules_hist {
derived_table: {
  sql:select FS.CURRENT_SCHEDULE_NUMBER,
       LAT.FINANCIAL_SCHEDULE_ID,
       LAT.VERSION,
       LAM.EVENT,
       LAM.DATE,
       LAM.POSITIVECF,
       LAM.NEGATIVECF,
       LAM.INTEREST,
       LAM.PRINCIPAL,
       LAM.BALANCE,
       LAM.MEMO,
       LAT.PMT_SCHEDULE_ID,
       LAT.GAAP,
       LAT.ENTITY,
       LAT.FINANCING_FACILITY_TYPE,
       LAT.NOMINAL_RATE,
       LAT.APR,
       LAT.TVAL_FOLDER,
       LAT.PENDING,
       LAT.UPDATED_BY,
       LAT.APPROVED_BY,
       LAT.RECORD_START_DATE,
       LAT.RECORD_STOP_DATE
from ANALYTICS.DEBT.LOAN_ATTRIBUTES LAT
LEFT JOIN ANALYTICS.DEBT.LOAN_AMORTIZATION LAM
ON LAT.PMT_SCHEDULE_ID = LAM.PMT_SCHEDULE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES FS
ON LAT.FINANCIAL_SCHEDULE_ID = FS.FINANCIAL_SCHEDULE_ID
WHERE NOT LAT.PENDING
ORDER BY LAT.FINANCIAL_SCHEDULE_ID, LAT.VERSION, LAT.PMT_SCHEDULE_ID, LAM.DATE, LAM.EVENT;;
}

  dimension: tval_loan_name {
    type: string
    sql: ${TABLE}.current_schedule_number ;;
  }
dimension: FINANCIAL_SCHEDULE_ID {
  type: number
  sql: ${TABLE}.FINANCIAL_SCHEDULE_ID ;;
}
dimension: version {
  type: number
  sql: ${TABLE}.version ;;
}
dimension: event {
  type: string
  sql: ${TABLE}.event ;;
}
  dimension: date {
    type: date
    sql: ${TABLE}.date;;
  }



dimension: positivecf {
  type: number
  sql: ${TABLE}.positivecf ;;
}
  dimension: negativecf {
    type: number
    sql: ${TABLE}.negativecf ;;
  }
  dimension: interest {
    type: number
    sql: ${TABLE}.interest ;;
  }
dimension: principal {
  type: number
  sql: ${TABLE}.principal ;;
}

dimension: balance {
  type: number
  sql: ${TABLE}.balance ;;
}
dimension: memo {
  type: string
  sql: ${TABLE}.memo;;
}
  dimension: pmt_SCHEDULE_ID {
    type: number
    sql: ${TABLE}.pmt_SCHEDULE_ID ;;
  }
  dimension: gaap {
    type: string
    sql: ${TABLE}.gaap;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}.entity;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}.financing_facility_type;;
  }
  dimension: nominal_rate {
    type: number
    sql: ${TABLE}.nominal_rate;;
  }
  dimension: apr {
    type: number
    sql: ${TABLE}.apr;;
  }
  dimension: tval_folder {
    type: string
    sql: ${TABLE}.tval_folder;;
  }
  dimension: pending {
    type: string
    sql: ${TABLE}.pending;;
  }
  dimension: updated_by {
    type: string
    sql: ${TABLE}.updated_by;;
  }
  dimension: approved_by {
    type: string
    sql: ${TABLE}.approved_by;;
  }
  dimension: record_start_date {
    type: date_time
    sql: ${TABLE}.record_start_date ;;
  }
  dimension: record_stop_date {
    type: date_time
    sql: ${TABLE}.record_stop_date ;;
  }
}
