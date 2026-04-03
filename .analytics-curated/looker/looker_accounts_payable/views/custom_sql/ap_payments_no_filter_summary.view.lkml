view: ap_payments_no_filter_summary {
  derived_table: {
    sql:



SELECT
    ACCOUNTNO,
    TITLE,
    SUM(TOTAL_AMOUNT) AS total,
    SUM(TOTAL_AMOUNT) / 52 AS AVERAGE_WEEKLY,
    SUM(TOTAL_AMOUNT) / 12 AS AVERAGE_MONTHLY,
    SUM(TOTAL_AMOUNT) / 4 AS AVERAGE_QUARTER,
    CURRENT_WEEK_AMOUNT as current_week
FROM (
    SELECT
        ACCOUNTNO,
        TITLE,
        COUNT(DISTINCT WEEK_START) AS TOTAL_WEEKS,
        SUM(CASE WHEN WEEK_START = CURRENT_WEEK_START THEN AMOUNT ELSE 0 END) AS CURRENT_WEEK_AMOUNT,
        SUM(AMOUNT) AS TOTAL_AMOUNT
    FROM (
        SELECT coa.TITLE,
            APRD.ACCOUNTNO AS ACCOUNTNO,
            APBPMT.AMOUNT,
            DATE_TRUNC('week', APBPMT.PAYMENTDATE) AS WEEK_START,
            DATE_TRUNC('week', CURRENT_DATE()) AS CURRENT_WEEK_START
        FROM
            "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
        LEFT JOIN
            "ANALYTICS"."INTACCT"."APRECORD" APRH ON APBPMT.RECORDKEY = APRH.RECORDNO AND APRH.RECORDTYPE IN ('apbill', 'apadjustment')
        LEFT JOIN
            "ANALYTICS"."INTACCT"."APDETAIL" APRD ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
        LEFT JOIN
            "ANALYTICS"."INTACCT"."VENDOR" VEND ON APRH.VENDORID = VEND.VENDORID
        LEFT JOIN
            "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON APRD.ACCOUNTNO = COA.ACCOUNTNO
        LEFT JOIN
            "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
        WHERE
            APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT
            AND APRHPAY.RECORDTYPE = 'appayment'
            AND APBPMT.PAYMENTDATE >= DATEADD('year', -1, CURRENT_DATE()) -- Filter data for the last year
    ) subquery
    GROUP BY ACCOUNTNO, CURRENT_WEEK_START, TITLE
) weekly_spending
GROUP BY ACCOUNTNO, CURRENT_WEEK_AMOUNT, TITLE
ORDER BY ACCOUNTNO;;
  }

  # measure: count {
  #   type: count
  #   drill_fields: [detail*]
  # }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNTNO";;
  }




  dimension: title {
    type: number
    sql: ${TABLE}."TITLE" ;;
  }

  measure: total {
    type: number
    sql: ${TABLE}."total" ;;
  }

  measure: average_weekly {
    type: number
    sql: ${TABLE}."AVERAGE_WEEKLY" ;;
  }

  measure: average_monthly {
    type: number
    sql: ${TABLE}."AVERAGE_MONTHLY" ;;
  }

  measure: average_quarter {
    type: number
    sql: ${TABLE}."AVERAGE_QUARTER" ;;
  }

  measure: current_week {
    type: number
    sql: ${TABLE}."current_week" ;;
  }

  # dimension: payment_date {
  #   convert_tz: no
  #   type: date
  #   sql: ${TABLE}."PAYMENTDATE" ;;
  # }

#   dimension_group: week {
#   type: time
#   timeframes: [
#     raw,
#     week
#   ]
#   sql: ${TABLE}."PAYMENTDATE";;

# }

  # dimension_group: submit_date {
  #   type: time

  #   sql: ${TABLE}."PAYMENTDATE" ;;
  # }



  # dimension: current_week {
  #   type: string
  #   sql: ${TABLE}."current_week" ;;
  # }

  # dimension: account {
  #   type: string
  #   sql: ${TABLE}."ACCOUNTNO" ;;
  # }

  # dimension: account_name {
  #   type: string
  #   sql: ${TABLE}."TITLE" ;;
  # }



  # measure: amount {
  #   type: sum
  #   value_format: "#,##0.00"
  #   sql: ${TABLE}."Amount" ;;
  # }

  # measure: amount {
  #   type: number
  #   value_format: "#,##0.00"
  #   sql: ${TABLE}."AMOUNT" ;;
  # }

  # measure: amount {
  #   type: number
  #   sql: ${TABLE}."AMOUNT" ;;
  # }

  # measure: amount {
  #   type: sum
  #   sql: ${TABLE}."AMOUNT"  ;;
  # }


  # measure: avg_spend_per_account_monthly {
  #   type: average
  #   sql: ${TABLE}."AMOUNT"
  #         sql_always_where: ${TABLE}."ACCOUNTNO" >= (current_date - INTERVAL '12' MONTH)
  #         timeframes: [month];;
  # }


  set: detail {
    fields: [
      account,
      title,
      total,
      average_weekly,
      average_monthly,
      average_quarter,
      current_week
    ]
  }

#   filter: date_filter {
#     convert_tz: no
#     type: date
#   }
}
