view: ap_dpo_terms_calc {
  derived_table: {
    sql: SELECT
    VENDOR_ID,
    MAX(NAME) AS NAME,
    SUM(CASE WHEN DPO_OVER_TERMS < 1 THEN TOTALPAID ELSE 0 END) AS TOTAL_PAID_WITHIN_TERMS,
    SUM(CASE WHEN DPO_OVER_TERMS >= 1 THEN TOTALPAID ELSE 0 END) AS TOTAL_PAID_OUTSIDE_TERMS
FROM
(
    SELECT
    VEND.VENDORID AS VENDOR_ID,
    APH.RECORDNO AS BILL_NO,
    VEND.NAME AS NAME,
    MAX(APH.WHENCREATED) AS BILL_CREATED_DATE,
    MAX(APH.WHENPAID) AS BILL_PAID_DATE,
    CASE
        WHEN MAX(APH.WHENPAID) IS NULL THEN DATEDIFF(DAY, MAX(APH.WHENCREATED), CURRENT_DATE)
        ELSE DATEDIFF(DAY, MAX(APH.WHENCREATED), MAX(APH.WHENPAID))
    END AS DPO,
    MAX(APH.TERMNAME) AS TERMNAME,
    MAX(APH.WHENDUE) AS WHENDUE,
   CASE
        WHEN MAX(APH.TERMNAME) = 'Net 45' THEN 45
        WHEN MAX(APH.TERMNAME) = 'Net 90' THEN 90
        WHEN MAX(APH.TERMNAME) = 'Net 120' THEN 120
        WHEN MAX(APH.TERMNAME) = 'Net 25' THEN 25
        WHEN MAX(APH.TERMNAME) = '5th of the Month' THEN DATEDIFF(DAY, MAX(APH.WHENCREATED), DATEADD(MONTH, 1, DATEADD(DAY, 4 - DAY(MAX(APH.WHENCREATED)), MAX(APH.WHENCREATED)))) + 1
        WHEN MAX(APH.TERMNAME) = 'Net 20' THEN 20
        WHEN MAX(APH.TERMNAME) = 'NET 15' THEN 15
        WHEN MAX(APH.TERMNAME) = 'Net 60' THEN 60
        WHEN MAX(APH.TERMNAME) = '2% Net 30' THEN 30
        WHEN MAX(APH.TERMNAME) = 'Net 180' THEN 180
        WHEN MAX(APH.TERMNAME) = 'NET 10' THEN 10
        WHEN MAX(APH.TERMNAME) = 'Due Upon Receipt' THEN DATEDIFF(DAY, MAX(APH.WHENCREATED), MAX(APH.WHENDUE))
        WHEN MAX(APH.TERMNAME) = '15th of Month' THEN DATEDIFF(DAY, MAX(APH.WHENCREATED), DATEADD(MONTH, 1, DATEADD(DAY, 14 - DAY(MAX(APH.WHENCREATED)), MAX(APH.WHENCREATED)))) + 1
        WHEN MAX(APH.TERMNAME) = '3% Net 30' THEN 30
        WHEN MAX(APH.TERMNAME) = 'Net 75' THEN 75
        WHEN MAX(APH.TERMNAME) = '2% Net 10' THEN 10
        WHEN MAX(APH.TERMNAME) = 'Net 30' THEN 30
        WHEN MAX(APH.TERMNAME) IS NULL THEN DATEDIFF(DAY, MAX(APH.WHENCREATED), MAX(APH.WHENDUE))
    END AS NUMERIC_TERMS,
    CASE
        WHEN DPO <= NUMERIC_TERMS THEN 0
        ELSE DPO - NUMERIC_TERMS
    END AS DPO_OVER_TERMS,
    MAX(APH.TOTALPAID) AS TOTALPAID,
    MAX(APH.TOTALDUE) AS TOTALDUE
FROM
    ANALYTICS.INTACCT.APRECORD APH
LEFT JOIN
    ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
LEFT JOIN
    ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
LEFT JOIN
    ANALYTICS.INTACCT.APPAYMETHOD PM ON VEND.PAYMETHODREC = PM.PAYMETHODREC
LEFT JOIN
    ANALYTICS.INTACCT.DEPARTMENT DEPT ON APD.DEPARTMENTID = DEPT.DEPARTMENTID
LEFT JOIN
    ANALYTICS.FINANCIAL_SYSTEMS.VENDOR_HISTORY VEND_HIST ON APH.vendorid = VEND_HIST.vendor_id
WHERE
    APH.RECORDTYPE = 'apbill'
AND APH.WHENCREATED >= DATEADD(MONTH, -12, CURRENT_DATE)
GROUP BY
    VEND.VENDORID,
    VEND.NAME,
    APH.RECORDNO
ORDER BY VENDOR_ID, BILL_NO
) AS subquery
GROUP BY
    VENDOR_ID
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_paid_within_terms {
    type: sum
    label: "Total Paid Within Terms"
    sql: ${TABLE}.TOTAL_PAID_WITHIN_TERMS ;;
  }

  measure: total_paid_outside_terms {
    type: sum
    label: "Total Paid Outside Terms"
    sql: ${TABLE}.TOTAL_PAID_OUTSIDE_TERMS ;;
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    primary_key: yes
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: bill_no {
    type: string
    label: "Bill Number"
    sql: ${TABLE}.BILL_NO ;;
  }

  dimension: name {
    type: string
    label: "Name"
    sql: ${TABLE}.NAME ;;
  }

  dimension: bill_created_date {
    type: date
    label: "Bill Created Date"
    sql: ${TABLE}.BILL_CREATED_DATE ;;
  }

  dimension: bill_paid_date {
    type: date
    label: "Bill Paid Date"
    sql: ${TABLE}.BILL_PAID_DATE ;;
  }

  dimension: dpo {
    type: number
    label: "DPO"
    sql: ${TABLE}.DPO ;;
  }

  dimension: termname {
    type: string
    label: "Term Name"
    sql: ${TABLE}.TERMNAME ;;
  }

  dimension: whendue {
    type: date
    label: "When Due"
    sql: ${TABLE}.WHENDUE ;;
  }

  dimension: numeric_terms {
    type: number
    label: "Numeric Terms"
    sql: ${TABLE}.NUMERIC_TERMS ;;
  }

  dimension: dpo_over_terms {
    type: number
    label: "DPO Over Terms"
    sql: ${TABLE}.DPO_OVER_TERMS ;;
  }

  dimension: totalpaid {
    type: number
    label: "Total Paid"
    sql: ${TABLE}.TOTALPAID ;;
  }

  dimension: totaldue {
    type: number
    label: "Total Due"
    sql: ${TABLE}.TOTALDUE ;;
  }

  set: detail {
    fields: [
      total_paid_within_terms,
      total_paid_outside_terms,
      vendor_id,
      bill_no,
      name,
      bill_created_date,
      bill_paid_date,
      dpo,
      termname,
      whendue,
      numeric_terms,
      dpo_over_terms,
      totalpaid,
      totaldue
    ]
  }
}
