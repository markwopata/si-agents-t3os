  view: ap_dpo {
    derived_table: {
      sql: WITH ap_dpo_a AS (
    SELECT
        VEND_HIST.VENDOR_ID AS VENDOR_ID,
        APH.RECORDNO AS BILL_NO,
        APH.WHENCREATED AS BILL_CREATED_DATE,
        APH.WHENPAID AS BILL_PAID_DATE,
        CASE
            WHEN APH.WHENPAID IS NULL THEN DATEDIFF(DAY, APH.WHENCREATED, CURRENT_DATE)
            ELSE DATEDIFF(DAY, APH.WHENCREATED, APH.WHENPAID)
        END AS DPO,
        APH.TERMNAME,
        APH.WHENDUE,
        CASE
            WHEN APH.TERMNAME = 'Net 45' THEN 45
            WHEN APH.TERMNAME = 'Net 90' THEN 90
            WHEN APH.TERMNAME = 'Net 120' THEN 120
            WHEN APH.TERMNAME = 'Net 25' THEN 25
            WHEN APH.TERMNAME = '5th of the Month' THEN DATEDIFF(DAY, APH.WHENCREATED, DATEADD(MONTH, 1, DATEADD(DAY, 4 - DAY(APH.WHENCREATED), APH.WHENCREATED))) + 1
            WHEN APH.TERMNAME = 'Net 20' THEN 20
            WHEN APH.TERMNAME = 'NET 15' THEN 15
            WHEN APH.TERMNAME = 'Net 60' THEN 60
            WHEN APH.TERMNAME = '2% Net 30' THEN 30
            WHEN APH.TERMNAME = 'Net 180' THEN 180
            WHEN APH.TERMNAME = 'NET 10' THEN 10
            WHEN APH.TERMNAME = 'Due Upon Receipt' THEN DATEDIFF(DAY, APH.WHENCREATED, APH.WHENDUE)
            WHEN APH.TERMNAME = '15th of Month' THEN DATEDIFF(DAY, APH.WHENCREATED, DATEADD(MONTH, 1, DATEADD(DAY, 14 - DAY(APH.WHENCREATED), APH.WHENCREATED))) + 1
            WHEN APH.TERMNAME = '3% Net 30' THEN 30
            WHEN APH.TERMNAME = 'Net 75' THEN 75
            WHEN APH.TERMNAME = '2% Net 10' THEN 10
            WHEN APH.TERMNAME = 'Net 30' THEN 30
            WHEN APH.TERMNAME IS NULL THEN DATEDIFF(DAY, APH.WHENCREATED, APH.WHENDUE)
        END AS NUMERIC_TERMS,
        CASE
            WHEN DPO <= NUMERIC_TERMS THEN 0
            ELSE DPO - NUMERIC_TERMS
        END AS DPO_OVER_TERMS,
        APH.TOTALPAID,
        APH.TOTALDUE
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
),
ap_dpo_terms_calc AS (
    SELECT
        VENDOR_ID,
        BILL_NO,
        MAX(BILL_CREATED_DATE) AS BILL_CREATED_DATE,
        MAX(BILL_PAID_DATE) AS BILL_PAID_DATE,
        DPO,
        TERMNAME,
        WHENDUE,
        NUMERIC_TERMS,
        DPO_OVER_TERMS,
        TOTALPAID,
        TOTALDUE,
        CASE
            WHEN DPO_OVER_TERMS < 1 THEN TOTALPAID
            ELSE 0
        END AS TOTAL_PAID_WITHIN_TERMS,
        CASE
            WHEN DPO_OVER_TERMS >= 1 THEN TOTALPAID
            ELSE 0
        END AS TOTAL_PAID_OUTSIDE_TERMS
    FROM
        ap_dpo_a
    GROUP BY
        VENDOR_ID,
        BILL_NO,
        DPO,
        TERMNAME,
        WHENDUE,
        NUMERIC_TERMS,
        DPO_OVER_TERMS,
        TOTALPAID,
        TOTALDUE
)
SELECT
    VENDOR_ID,
    BILL_NO,
    BILL_CREATED_DATE,
    BILL_PAID_DATE,
    DPO,
    TERMNAME,
    NUMERIC_TERMS,
    DPO_OVER_TERMS,
    SUM(TOTAL_PAID_WITHIN_TERMS) AS TOTAL_PAID_WITHIN_TERMS,
    SUM(TOTAL_PAID_OUTSIDE_TERMS) AS TOTAL_PAID_OUTSIDE_TERMS
FROM
    ap_dpo_terms_calc
GROUP BY
    VENDOR_ID,
    BILL_NO,
    BILL_CREATED_DATE,
    BILL_PAID_DATE,
    DPO,
    TERMNAME,
    NUMERIC_TERMS,
    DPO_OVER_TERMS
ORDER BY
    VENDOR_ID,
    BILL_NO
            ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: bill_no {
      type: string
      label: "Bill Number"
      primary_key: yes
      sql: ${TABLE}."BILL_NO" ;;
    }

    dimension: bill_created_date {
      type: date
      label: "Bill Created Date"
      sql: ${TABLE}."BILL_CREATED_DATE" ;;
    }

    dimension: bill_paid_date {
      type: date
      label: "Bill Paid Date"
      sql: ${TABLE}."BILL_PAID_DATE" ;;
    }

    dimension: dpo {
      type: number
      label: "DPO"
      sql: ${TABLE}."DPO" ;;
    }

    dimension: termname {
      type: string
      label: "Term Name"
      sql: ${TABLE}."TERMNAME" ;;
    }

    dimension: whendue {
      type: date
      label: "When Due"
      sql: ${TABLE}."WHENDUE" ;;
    }

    dimension: numeric_terms {
      type: number
      label: "Numeric Terms"
      sql: ${TABLE}."NUMERIC_TERMS" ;;
    }

    dimension: dpo_over_terms {
      type: number
      label: "DPO Over Terms"
      sql: ${TABLE}."DPO_OVER_TERMS" ;;
    }

    dimension: totalpaid {
      type: number
      label: "Total Paid"
      sql: ${TABLE}."TOTALPAID" ;;
    }

    dimension: totaldue {
      type: number
      label: "Total Due"
      sql: ${TABLE}."TOTALDUE" ;;
    }

    dimension: vendor_id {
      type: string
      label: "Vendor ID"
      sql: ${TABLE}."VENDOR_ID";;
    }

    set: detail {
      fields: [
        bill_no,
        bill_created_date,
        bill_paid_date,
        dpo,
        termname,
        whendue,
        numeric_terms,
        dpo_over_terms,
        totalpaid,
        totaldue,
        vendor_id
      ]
    }
}
