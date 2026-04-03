view: arinvoicepayment_sum {
  # derived_table: {
  #   sql:
  #   SELECT
  #       recordkey,
  #       SUM(amount) AS total_amount_paid
  #     FROM ANALYTICS.INTACCT.ARINVOICEPAYMENT
  #     GROUP BY recordkey ;;

  # }
  derived_table: {
    sql:
      WITH main AS (
        SELECT
          recordkey,
          amount,
          paymentdate,
          CONCAT(recordkey, amount, paymentdate) AS dis_key
        FROM ANALYTICS.INTACCT.ARINVOICEPAYMENT
        WHERE parentpymt <> recordkey -- possible filter for reversals

      UNION ALL

      SELECT
      recordno AS recordkey,
      trx_totalentered AS amount,
      NULL AS paymentdate,
      CONCAT(trx_totalentered, whencreated, recordno) AS dis_key
      FROM ANALYTICS.INTACCT.ARRECORD
      WHERE trx_totalentered < 0
      AND trx_totalentered IS NOT NULL
      AND recordtype = 'arinvoice'
      -- AND UPPER(docnumber) NOT LIKE '%CREDIT%' -- consider adding if needed
      ),
      r_numbers AS (
      SELECT
      ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS unique_id,
      main.*
      FROM main
      )

      SELECT
      r_numbers.recordkey,
      SUM(r_numbers.amount) AS total_amount_paid
      FROM r_numbers
      WHERE recordkey NOT IN ('8565520', '9193091')
      GROUP BY r_numbers.recordkey ;;
  }

  dimension: recordkey {
    primary_key: yes
    type: string
    sql: ${TABLE}.recordkey ;;

  }

  # measure:total_paid {
  #   type: number
  #   sql: ${TABLE}.total_amount_paid ;;
  # }

  dimension:total_paid {
    type: number
    sql: ${TABLE}.total_amount_paid ;;
  }
}





#   dimension:sum_paid{
#     type: number
#   sql: ${TABLE}.total_amount_paid ;;
# }




  # dimension: billto_email1 {
  #   type: string
  #   sql: ${TABLE}."BILLTO_EMAIL1" ;;
  # }
