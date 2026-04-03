view: gs_p_2_p_receipt_log
 {
  derived_table: {
    sql: select *, CASE
        WHEN Date = '' THEN NULL
        WHEN Date = '(blank)' THEN NULL
        ELSE TO_DATE(Date, 'MM/DD/YYYY')
    END AS converted_date,

    CURRENT_DATE - converted_date AS DAYS_OLD,
    LAST_DAY(CURRENT_DATE, 'MONTH') AS LAST_DAY_OF_CURRENT_MONTH,
    LAST_DAY_OF_CURRENT_MONTH - converted_date AS AGE_ON_LAST_DAY_OF_CURRENT_MONTH,
    LAST_DAY(DATEADD(MONTH, -1, CURRENT_DATE)) AS LAST_DAY_OF_PREVIOUS_MONTH,
    LAST_DAY_OF_PREVIOUS_MONTH - converted_date AS AGE_ON_LAST_DAY_OF_PREVIOUS_MONTH,
    CASE
        WHEN AGE_ON_LAST_DAY_OF_CURRENT_MONTH <= 15 THEN '0-15'
        WHEN AGE_ON_LAST_DAY_OF_CURRENT_MONTH <= 30 THEN '16-30'
        WHEN AGE_ON_LAST_DAY_OF_CURRENT_MONTH <= 45 THEN '31-45'
        WHEN AGE_ON_LAST_DAY_OF_CURRENT_MONTH <= 60 THEN '46-60'
        ELSE '60 and over'
    END AS FLAG

    from ANALYTICS.PROCURE_2_PAY.GS_P_2_P_RECEIPT_LOG ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: reason_code {
    type: string
    sql: ${TABLE}."REASON_CODE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: sage_status {
    type: string
    sql: ${TABLE}."SAGE_STATUS" ;;
  }

  dimension: disposition {
    type: string
    sql: ${TABLE}."DISPOSITION" ;;
  }

  dimension: sum_of_ext_price {
    type: string
    sql: ${TABLE}."SUM_OF_EXT_PRICE" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: date {
    type: string
    sql: ${TABLE}."DATE" ;;
  }

  dimension: sage_date {
  type: date
  sql: ${TABLE}."converted_date" ;;
  }

  dimension: ap_rep {
    type: string
    sql: ${TABLE}."AP_REP" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }


  dimension: DAYS_OLD {
    type: string
    sql: ${TABLE}."DAYS_OLD" ;;
  }


  dimension: LAST_DAY_OF_CURRENT_MONTH {
    type: date
    sql: ${TABLE}."LAST_DAY_OF_CURRENT_MONTH" ;;
  }



  dimension: AGE_ON_LAST_DAY_OF_CURRENT_MONTH {
    type: string
    sql: ${TABLE}."AGE_ON_LAST_DAY_OF_CURRENT_MONTH" ;;
  }


  dimension: FLAG {
    type: string
    sql: ${TABLE}."FLAG" ;;
  }


  set: detail {
    fields: [
      _row,
      reason_code,
      vendor_id,
      sage_status,
      disposition,
      sum_of_ext_price,
      vendor_name,
      po_number,
      date,
      ap_rep,
      _fivetran_synced_time
    ]
  }
}
