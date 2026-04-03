view: ap_po_amt_remaining {
  derived_table: {
    sql:
WITH DEDUPLICATED_POH AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY PURCHASE_ORDER_NUMBER
            ORDER BY
                CASE
                    WHEN STATUS = 'OPEN' THEN 1
                    WHEN STATUS = 'NEEDS_APPROVAL' THEN 2
                    WHEN STATUS = 'CLOSED' THEN 3
                    WHEN STATUS = 'ARCHIVED' THEN 4
                    ELSE 5
                END
        ) as status_priority
    FROM procurement.public.purchase_orders
)
SELECT
    TO_VARCHAR(TO_VARIANT(POH.PURCHASE_ORDER_NUMBER)) AS po_number,
    POH.STATUS AS po_status,
    CAST(CONVERT_TIMEZONE('America/Chicago',POH.DATE_CREATED) AS DATE) AS Date,
    POH.amount_approved AS po_amount,
    ROUND(SUM(APD.AMOUNT), 2) AS total_billed,
    CASE
        WHEN (POH.amount_approved - COALESCE(ROUND(SUM(APD.AMOUNT), 2), 0)) <= 0 THEN 'Exhausted'
        ELSE CAST((POH.amount_approved - COALESCE(ROUND(SUM(APD.AMOUNT), 2), 0)) AS VARCHAR)
      END AS amt_remaining,
    LISTAGG(DISTINCT APH.recordid, ', ') AS invoice_no,
    poh.search AS Note

FROM DEDUPLICATED_POH AS POH
LEFT JOIN analytics.intacct.aprecord AS APH
    ON TO_VARCHAR(TO_VARIANT(POH.PURCHASE_ORDER_NUMBER)) = SPLIT_PART(TO_VARCHAR(TO_VARIANT(APH.DOCNUMBER)), '-', 1)
LEFT JOIN analytics.intacct.apdetail AS APD ON APH.RECORDNO = APD.RECORDKEY
LEFT JOIN analytics.intacct.podocument AS POD
    ON TO_VARCHAR(TO_VARIANT(POD.DOCNO)) = TO_VARCHAR(TO_VARIANT(POH.PURCHASE_ORDER_NUMBER))

WHERE
    status_priority = 1

GROUP BY
    po_number,
    Date,
    po_amount,
    po_status,
    poh.search
    ;;
    }

  dimension: po_number {
    type: string
    sql: ${TABLE}.po_number ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}.po_status ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: po_amount {
    type: number
    sql: ${TABLE}.po_amount ;;
  }

  dimension: total_billed {
    type: number
    sql: ${TABLE}.total_billed ;;
  }

  dimension: amt_remaining {
    type: string
    sql: ${TABLE}.amt_remaining ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
  }



    }
