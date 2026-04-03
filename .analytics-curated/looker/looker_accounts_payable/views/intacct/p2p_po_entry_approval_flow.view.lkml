view: p2p_po_entry_approval_flow {
    derived_table: {
      sql:
WITH converted_data AS (

SELECT
S:CUSTVENDID::VARCHAR                         AS VENDORID,
S:CUSTVENDNAME::VARCHAR                         AS CUSTVENDNAME,
S:TOTAL::VARCHAR                         AS TOTAL,
S:TERM_NAME::VARCHAR                         AS TERM_NAME,
    S:USERID::VARCHAR                         AS USERID,
    S:WHENCREATED::VARCHAR                    AS WHENCREATED,
    S:WHENDUE::VARCHAR                        AS WHENDUE,
    S:DOCPARID::VARCHAR             AS DOCPARID,
    S:DOCNO::VARCHAR                AS DOCNO,
    S:STATE::VARCHAR                AS STATE,
    S:WHENMODIFIED::VARCHAR         AS WHENMODIFIED,
    S:_ES_UPDATE_TIMESTAMP::VARCHAR AS _ES_UPDATE_TIMESTAMP,
    CONVERT_TIMEZONE('America/Chicago', TO_TIMESTAMP(whenmodified)) AS whenmodified_chicago,

TO_TIMESTAMP(whenmodified_chicago) AS whenmodified_chicago_ts


from
    ANALYTICS.ETL.INTACCTVAULT_INTACCT_PODOCUMENT
WHERE
      DOCPARID = 'Purchase Order Entry'
  --AND DOCNO = 'E102610'
)


SELECT
    userid,
    whencreated,
    whendue,

  docno,
  state,


 WHENMODIFIED_CHICAGO_TS,
  CASE
    WHEN LAG(state) OVER (PARTITION BY docno ORDER BY whenmodified_chicago_ts) IS NOT NULL
      THEN DATEDIFF('hour', LAG(whenmodified_chicago_ts) OVER (PARTITION BY docno ORDER BY whenmodified_chicago_ts), whenmodified_chicago_ts)
  END AS hours_to_change_state,

    CASE
    WHEN LAG(state) OVER (PARTITION BY docno ORDER BY whenmodified_chicago_ts) IS NOT NULL
      THEN DATEDIFF('days', LAG(whenmodified_chicago_ts) OVER (PARTITION BY docno ORDER BY whenmodified_chicago_ts), whenmodified_chicago_ts)
  END AS days_to_change_state,


   total, vendorid, term_name,



case when total > 49999 then TRUE else FALSE end as Required_Exec_Approval

  FROM converted_data

order by docno, state desc


        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }
    dimension: userid {
      type: string
      sql: ${TABLE}."USERID" ;;
    }
    dimension: whencreated {
      type: date
      sql: ${TABLE}."WHENCREATED" ;;
    }


  dimension: timewhencreated {
    type: date_time_of_day
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENCREATED" ;;
  }


  dimension: whenmodified {
    type: string
    sql: ${TABLE}."WHENMODIFIED_CHICAGO_TS" ;;
  }



    dimension: whendue {
      type: date
      sql: ${TABLE}."WHENDUE" ;;
    }

    dimension: docno {
      type: string
      sql: ${TABLE}."DOCNO" ;;
    }

    dimension: state {
      type: string
      sql: ${TABLE}."STATE" ;;
    }

    dimension: total {
      type: number
      sql: ${TABLE}."TOTAL" ;;
    }

    dimension: vendorid {
      type: string
      sql: ${TABLE}."VENDORID" ;;
    }
    dimension: term_name {
      type: string
      sql: ${TABLE}."TERM_NAME" ;;
    }


  dimension: hours_to_change_state {
    type: string
    sql: ${TABLE}."HOURS_TO_CHANGE_STATE" ;;
  }

  dimension: days_to_change_state {
    type: string
    sql: ${TABLE}."DAYS_TO_CHANGE_STATE" ;;
  }
  dimension: required_exec_approval {
    type: string
    sql: ${TABLE}."REQUIRED_EXEC_APPROVAL" ;;
  }
    # dimension_group: monthyear {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."MONTH_YEAR" ;;
    # }
    # measure: total_processed_invoices_count {
    #   type: number
    #   sql: ${TABLE}."PROCESSED_INVOICES_COUNT" ;;
    # }

    # measure: total_invoices_received_count {
    #   type: number
    #   sql: ${TABLE}."INVOICES_RECEIVED_COUNT" ;;
    # }

    # measure: total_system_concur_processed_invoices_count {
    #   type: number
    #   sql: ${TABLE}."SYSTEM_CONCUR_PROCESSED_INVOICES_COUNT" ;;
    # }

    # measure: total_adjusted_invoices_received_count {
    #   type: number
    #   sql: ${TABLE}."ADJUSTED_INVOICES_RECEIVED_COUNT" ;;
    # }
    # dimension: intacct_total {
    #   type: number
    #   sql: ${TABLE}."INT_TOTAL" ;;
    # }

    # dimension: intacct_state {
    #   type: string
    #   sql: ${TABLE}."INT_STATE" ;;
    # }

    # dimension: modified_by_id {
    #   type: string
    #   sql: ${TABLE}."MODIFIED_BY_ID" ;;
    # }

    # dimension: modified_by_login {
    #   type: string
    #   sql: ${TABLE}."MODIFIED_BY_LOGIN" ;;
    # }

    # dimension: po_number {
    #   type: string
    #   sql: ${TABLE}."PO_NUMBER" ;;
    # }

    # dimension: receipt_number {
    #   type: string
    #   sql: ${TABLE}."RECEIPT_NUMBER" ;;
    # }

    # dimension: date_received {
    #   type: date
    #   sql: ${TABLE}."DATE_RECEIVED" ;;
    # }

    # dimension: month {
    #   type: string
    #   label: "Month"
    #   sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
    # }

    # dimension: payed_amount {
    #   type: number
    #   sql: ${TABLE}."ACCEPT_QTY" ;;
    # }

    # dimension: payed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."REJECT_QTY" ;;
    # }

    # dimension: billed_amount {
    #   type: number
    #   sql: ${TABLE}."RECEIPT_QTY" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."UNIT_PRICE" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."EXT_COST" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."RECEIPT_CREATED" ;;
    # }


    # measure: paid {
    #   label: "Paid Amount"
    #   type: sum
    #   value_format: "#,##0;(#,##0);-"
    #   sql: ${payed_amount} ;;
    # }

    # measure: paid_count_by_gl {
    #   label: "Paid Count by GL"
    #   type: sum
    #   sql: ${payed_count_by_gl} ;;
    # }

    # measure: billed {
    #   label: "Billed Amount"
    #   type: sum
    #   value_format: "#,##0;(#,##0);-"
    #   sql: ${billed_amount} ;;
    # }

    # measure: billed_count {
    #   label: "Billed Count by GL"
    #   type: sum
    #   sql: ${billed_count_by_gl} ;;
    # }

    set: detail {
      fields: [
        userid,
        whencreated,
        whendue,
        docno,
        state,
        total,
        term_name,
        required_exec_approval

      ]
    }
 }
