view: warranty_reversals_by_user {
  derived_table: {
    sql:
      SELECT
          gle.RECORDNO,
          gle.ENTRY_DATE,
          LAST_DAY(gle.ENTRY_DATE) AS MONTH_ENDING,
          gle.ACCOUNTNO,
          gle.DEPARTMENT,
          gle.TR_TYPE,
          gle.BATCHTITLE,
          CASE
            WHEN glr.AMOUNT != 0 THEN glr.AMOUNT * gle.TR_TYPE
            ELSE 0
          END AS NET_AMOUNT,
          apr.RECORDID AS BILL_NUMBER,
          DATEDIFF(DAY,ENTRY_DATE,CURRENT_DATE)                                                           AS DAYS,
          CASE
            WHEN apr.DOCNUMBER LIKE 'WTY_%' THEN RIGHT(apr.DOCNUMBER, LEN(apr.DOCNUMBER) - 11)
          END AS PAYMENT_ID,
          apr.VENDORID AS AP_VEND_ID,
          apr.VENDORNAME AS AP_VEND_NAME,
          apr.DOCNUMBER,
          apr.state,
          apr.createdby,
          apr.modifiedby,
          ui.description
      FROM ANALYTICS.INTACCT.GLENTRY gle
      LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE glr ON gle.RECORDNO = glr.GLENTRYKEY
      LEFT JOIN ANALYTICS.INTACCT.APRECORD apr ON glr.PRRECORDKEY = apr.RECORDNO
      LEFT JOIN ANALYTICS.INTACCT.USERINFO ui ON apr.modifiedby = ui.recordno
      WHERE gle.ACCOUNTNO = '2303'
        AND apr.state ILIKE 'Reversal'
    ;;
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}.recordno ;;
    primary_key: yes
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}.entry_date ;;
  }

  dimension: month_ending {
    type: date
    sql: ${TABLE}.month_ending ;;
  }

  dimension: accountno {
    type: string
    sql: ${TABLE}.accountno ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: tr_type {
    type: number
    sql: ${TABLE}.tr_type ;;
  }

  dimension: batchtitle {
    type: string
    sql: ${TABLE}.batchtitle ;;
  }

  dimension: net_amount {
    type: number
    sql: ${TABLE}.net_amount ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}.bill_number ;;
  }

  dimension: payment_id {
    type: string
    sql: ${TABLE}."PAYMENT_ID" ;;
    html: <a href='https://admin.equipmentshare.com/#/home/payments/{{ payment_id._value }}' target='_blank' style='color: blue;'>{{ payment_id._value | escape }}</a> ;;}

  dimension: ap_vend_id {
    type: string
    sql: ${TABLE}.ap_vend_id ;;
  }

  dimension: ap_vend_name {
    type: string
    sql: ${TABLE}.ap_vend_name ;;
  }

  dimension: docnumber {
    type: string
    sql: ${TABLE}.docnumber ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  measure: days {
    type: max
    sql: ${TABLE}."DAYS" ;;}

  dimension: createdby {
    type: string
    sql: ${TABLE}.createdby ;;
  }

  dimension: modifiedby {
    type: string
    sql: ${TABLE}.modifiedby ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}.description ;;
  }
}
