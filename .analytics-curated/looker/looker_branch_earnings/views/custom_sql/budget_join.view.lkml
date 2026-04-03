view: budget_join {
  derived_table: {
    sql: select
          RECORD_ID,
          iff(MARKET_ID=15967,33163,MARKET_ID) MARKET_ID,
          BUDGET_DATE,
          ACCTNO,
          B."GROUP",
          --M.SAGE_NAME,
          case
              when upper(ACCTNO) regexp '^[A-Z]+$'    then -BUDGET_AMOUNT
              when B."GROUP" like 'EXP%'              then -BUDGET_AMOUNT
              else BUDGET_AMOUNT                      end b_amt
      from ANALYTICS.PUBLIC.BRANCH_EARNINGS_BUDGETS   B
      --join ANALYTICS.GS.PLEXI_BUCKET_MAPPING          M
      --    on B.ACCTNO = M.SAGE_GL
      --where ACCTNO != 'BFAA'
       ;;
  }

  measure: count {
    type: count
  }

  measure: sum {
    label: "Budget"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${b_amt} ;;
  }

  measure: sum2 {
    label: "Budget no rounding"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${b_amt} ;;
  }

  dimension: record_ID {
    type: string
    sql: ${TABLE}."RECORD_ID";;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: budget_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."BUDGET_DATE" ;;
  }

  dimension: acctno {
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  # dimension: acctname {
  #   type: string
  #   sql: ${TABLE}."SAGE_NAME" ;;
  # }

  dimension: group {
    type: string
    sql: ${TABLE}."GROUP" ;;
  }

  dimension: b_amt {
    type: number
    sql: ${TABLE}."B_AMT" ;;
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql: concat(${TABLE}."MARKET_ID",${TABLE}."ACCTNO",to_varchar(${TABLE}."BUDGET_DATE",'MM/YYYY')) ;;
  }

}
