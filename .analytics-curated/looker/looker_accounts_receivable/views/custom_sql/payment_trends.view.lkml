view: payment_trends {
  derived_table: {
    sql: SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    INVOICE_PAID_DATE,
    SUM(AMOUNT)                                        AS AMOUNT,
    DAYS_SINCE_DUE                                     AS TOTAL_DAYS_SINCE_DUE,
    AVG(DAYS_SINCE_DUE)                                AS AVG_DAYS_SINCE_DUE,
    IS_OUTSTANDING,
    SUM(WAD_FACTOR)                                    AS WAD_FACTOR,
    COLLECTOR,
    TAM
   FROM
   (SELECT
         ARH.CUSTOMERID                                          AS CUSTOMER_ID,
         ARH.CUSTOMERNAME                                        AS CUSTOMER_NAME,
         ARH.RECORDID                                            AS INVOICE_NUMBER,
         ARH.WHENCREATED                                         AS INVOICE_DATE,
         ARH.WHENDUE                                             AS DUE_DATE,
         ARH.WHENPAID                                            AS INVOICE_PAID_DATE,
         LAST_DAY(COALESCE(ARH.WHENPAID, CURRENT_DATE))          AS LAST_DAY_OF_MONTH_PAID,
         COALESCE(ARH.WHENPAID, CURRENT_DATE) - ARH.WHENCREATED  AS DAYS_UNTIL_PAID,
         COALESCE(ARH.WHENPAID, CURRENT_DATE) - ARH.WHENDUE      AS DAYS_SINCE_DUE,
         CASE WHEN ARH.WHENPAID IS NULL THEN TRUE ELSE FALSE END AS IS_OUTSTANDING,
         SUM(ARD.AMOUNT)                                         AS AMOUNT,
         SUM(ARD.AMOUNT * DAYS_SINCE_DUE)                        AS WAD_FACTOR,
         CCA.FINAL_COLLECTOR                                     AS COLLECTOR,
         CONCAT(TRIM(ESU.first_name), ' ',TRIM(ESU.last_name))       AS TAM
     FROM
         ANALYTICS.INTACCT.ARRECORD ARH
             LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
             LEFT JOIN ANALYTICS.INTACCT.CUSTOMER C ON ARD.RECORDNO = C.RECORDNO
             LEFT JOIN ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA ON ARH.CUSTOMERID = CCA.COMPANY_ID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS ESU ON ARH.CUSTOMERID = ESU.COMPANY_ID
     WHERE
         ARH.RECORDTYPE = 'arinvoice'
     GROUP BY ALL)
  GROUP BY ALL
  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
    }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
    }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: tam {
    type: string
    sql: ${TABLE}."TAM" ;;
  }

  dimension: due_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
    }

  dimension: invoice_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_paid_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."INVOICE_PAID_DATE" ;;
    }

  dimension: last_day_of_month_paid {
    convert_tz: no
    type: date
    sql: ${TABLE}."LAST_DAY_OF_MONTH_PAID" ;;
    }

  measure: days_until_paid {
    type: sum
    sql: ${TABLE}."DAYS_UNTIL_PAID" ;;
    }

  measure: avg_days_since_due {
    type: sum
    sql: ${TABLE}."AVG_DAYS_SINCE_DUE" ;;
  }

  measure: total_days_since_due {
    type: sum
    sql: ${TABLE}."TOTAL_DAYS_SINCE_DUE" ;;
  }

  dimension: is_outstanding {
    type: string
    sql: ${TABLE}."IS_OUTSTANDING" ;;
    }

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: wad_factor {
    type: sum
    sql: ${TABLE}."WAD_FACTOR" ;;
  }

  dimension_group: period {
    type: time
    view_label: "Period"
    timeframes: [
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.INVOICE_PAID_DATE ;;
    convert_tz: no
  }

  set: detail {
    fields: [
     customer_id,
     customer_name,
     invoice_number,
     invoice_date,
     due_date,
     invoice_paid_date,
     last_day_of_month_paid,
     days_until_paid,
     avg_days_since_due,
     total_days_since_due,
     is_outstanding,
     amount,
     wad_factor,
     collector,
     tam,
    ]
  }
}
