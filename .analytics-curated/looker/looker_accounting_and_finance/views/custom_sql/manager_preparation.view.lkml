view: manager_preparation {


  derived_table: {
    sql:
WITH AR_CTE AS (
SELECT
INVOICE_NO,
CUSTOMER_ID,
BRANCH_ID,
'2026-Q1' AS QUARTER,
DUE_DATE,
SUM(CASE WHEN MONTH_ IN ('2026-01-31','2026-02-28','2026-03-31') THEN MTD_REVENUE ELSE 0 END) AS TOTAL_REVENUE,
SUM(CASE WHEN MONTH_ = '2026-02-28' THEN CURRENT_AR ELSE 0 END) AS CURRENT_BALANCE,
SUM(CASE WHEN MONTH_ = '2026-02-28' THEN PAST_DUE_AR_NON_LEGAL ELSE 0 END) AS PAST_DUE_NON_LEGAL_BALANCE
FROM ANALYTICS.TREASURY.COLLECTIONS_TARGET_ACTUALS_ALL
WHERE MONTH_ IN ('2026-01-31','2026-02-28','2026-03-31')
GROUP BY ALL),
-- Step 2: Compute Total Balance & Days Past Due
AR_FINAL AS (
    SELECT
        INVOICE_NO,
        CUSTOMER_ID,
        BRANCH_ID,
        QUARTER,
        CURRENT_BALANCE,
        PAST_DUE_NON_LEGAL_BALANCE,
        (CURRENT_BALANCE + PAST_DUE_NON_LEGAL_BALANCE) AS TOTAL_BALANCE,
        TOTAL_REVENUE,
        IFF(CURRENT_BALANCE + PAST_DUE_NON_LEGAL_BALANCE = 0,0,DATEDIFF(DAY, DUE_DATE, CURRENT_DATE)) AS DAYS_PAST_DUE
    FROM AR_CTE
),
-- Step 3: Add dispute status
DISPUTE_CTE AS (
    SELECT
        INVOICE_ID,
        MIN(DATE_CREATED) AS FIRST_DATE_CREATED,  -- Earliest dispute record
        MAX(DATE_RESOLVED) AS LAST_DATE_RESOLVED  -- Latest resolution
    FROM ES_WAREHOUSE.PUBLIC.DISPUTES
    GROUP BY INVOICE_ID
),
REMAINING_CREDIT_CTE AS (
SELECT  I.INVOICE_NO,SUM(CN.REMAINING_CREDIT_AMOUNT) AS REMAINING_CREDIT_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.CREDIT_NOTES AS CN
LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I ON CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
GROUP BY I.INVOICE_NO
HAVING SUM(CN.REMAINING_CREDIT_AMOUNT) > 0
)
SELECT
'2026-Q1' AS QUARTER,
AR.INVOICE_NO AS INVOICE_NO,
AR.CUSTOMER_ID AS CUSTOMER_ID,
AR.BRANCH_ID AS BRANCH_ID,
MKT.NAME AS BRANCH_NAME,
C.NAME AS CUSTOMER_NAME,
    SUM(COALESCE(AR.TOTAL_REVENUE,0))            AS TOTAL_REVENUE,
    COALESCE(AR.CURRENT_BALANCE,0)  AS CURRENT_BALANCE,
    COALESCE(AR.PAST_DUE_NON_LEGAL_BALANCE,0) AS PAST_DUE_NON_LEGAL_BALANCE,
    COALESCE(AR.DAYS_PAST_DUE, 0) AS DAYS_PAST_DUE,
    COALESCE(AR.TOTAL_BALANCE,0)            AS TOTAL_BALANCE,
    COALESCE(RCC.REMAINING_CREDIT_AMOUNT,0) AS REMAINING_CREDIT_AMOUNT,
    CASE
        WHEN D.INVOICE_ID IS NOT NULL
             AND D.FIRST_DATE_CREATED <= '2026-03-31'
             AND D.LAST_DATE_RESOLVED IS NULL THEN 1
        ELSE 0
    END AS IN_DISPUTE
FROM AR_FINAL AS AR
LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I ON AR.INVOICE_NO = I.INVOICE_NO
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS   AS MKT ON AR.BRANCH_ID = MKT.MARKET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C   ON AR.CUSTOMER_ID = C.COMPANY_ID
LEFT JOIN DISPUTE_CTE AS D ON I.INVOICE_ID = D.INVOICE_ID
LEFT JOIN REMAINING_CREDIT_CTE AS RCC ON AR.INVOICE_NO = RCC.INVOICE_NO
GROUP BY ALL
      ;;
  }

######### DIMENSIONS #########

  # You want to reference the raw columns from the derived table in dimension fields:

  dimension: raw_current_balance {
    type: number
    sql: ${TABLE}.CURRENT_BALANCE ;;
  }

  dimension: raw_past_due_non_legal_balance {
    type: number
    sql: ${TABLE}.PAST_DUE_NON_LEGAL_BALANCE ;;
  }

  dimension: raw_total_balance {
    type: number
    sql: ${TABLE}.TOTAL_BALANCE ;;
  }

  #dimension: raw_total_collections {
  #  type: number
  #  sql: ${TABLE}.TOTAL_COLLECTIONS ;;
  #}

  dimension: raw_total_revenue {
    type: number
    sql: ${TABLE}.TOTAL_REVENUE ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${TABLE}.DAYS_PAST_DUE ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}.QUARTER ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.INVOICE_NO ;;
  }

  dimension: customer_id {
    type: string
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ manager_preparation.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.BRANCH_NAME ;;
  }

  dimension: days_in_quarter {
    type: number
    sql: CASE
      WHEN ${quarter} = '2024-Q1' THEN 91
      WHEN ${quarter} = '2024-Q2' THEN 91
      WHEN ${quarter} = '2024-Q3' THEN 92
      WHEN ${quarter} = '2024-Q4' THEN 92
      WHEN ${quarter} = '2025-Q1' THEN 92
      WHEN ${quarter} = '2025-Q2' THEN 91
      WHEN ${quarter} = '2025-Q3' THEN 92
      WHEN ${quarter} = '2025-Q4' THEN 92
      WHEN ${quarter} = '2026-Q1' THEN DATEDIFF(DAY, '2025-12-31'::date, CURRENT_DATE)
      ELSE 0
    END ;;
  }

  dimension: aging_buckets {
    type: string
    sql: CASE
      WHEN ${days_past_due} < 1                  THEN 'Not Due Yet'
      WHEN ${days_past_due} BETWEEN 1 AND 30     THEN '1 - 30 Days Past Due'
      WHEN ${days_past_due} BETWEEN 31 AND 60    THEN '31 - 60 Days Past Due'
      WHEN ${days_past_due} BETWEEN 61 AND 90    THEN '61 - 90 Days Past Due'
      WHEN ${days_past_due} BETWEEN 91 AND 120   THEN '91 - 120 Days Past Due'
      WHEN ${days_past_due} >= 121               THEN '120+ Days Past Due'
      ELSE 'Research'
    END ;;
  }

  dimension: in_dispute {
    type: number
    sql:  ${TABLE}.IN_DISPUTE ;;
  }

 ######### PRIMARY KEY #########
  dimension: key {
    type:  string
    primary_key: yes
    sql: ${invoice_no} || '-' || ${quarter}  ;;
}

  ######### MEASURES #########

  #measure: total_collections {
  #  type: sum
  #  value_format_name: usd
  #  sql: ${collector_targets.actual_collections} ;;
  #  drill_fields: [trx_details*]
  #}

  measure: total_revenue {
    type: sum
    value_format_name: usd
    sql: ${raw_total_revenue} ;;
    drill_fields: [trx_details*]
  }

  measure: current_balance {
    type: sum
    value_format_name: usd
    sql: ${raw_current_balance} ;;

    drill_fields: [trx_details*]
  }

  measure: past_due_non_legal_balance {
    type: sum
    value_format_name: usd
    sql: ${raw_past_due_non_legal_balance} ;;
    drill_fields: [trx_details*]
  }

  measure: total_balance {
    type: sum
    value_format_name: usd
    sql: ${raw_total_balance} ;;
    drill_fields: [trx_details*]
  }

  measure: number_of_accounts {
    label: "# of Accounts"
    type: count_distinct
    sql: ${TABLE}.CUSTOMER_ID ;;
    drill_fields: [trx_details*]
  }

  measure: aging_current_days {
    label: "Current"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} < 1 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }


  measure: aging_1_30_days {
    label: "1 - 30 PD"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} BETWEEN 1 AND 30 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_31_60_days {
    label: "31 - 60 PD"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} BETWEEN 31 AND 60 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_61_90_days {
    label: "61 - 90 PD"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} BETWEEN 61 AND 90 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_91_120_days {
    label: "91 - 120 PD"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} BETWEEN 91 AND 120 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_120_plus_days {
    label: "120+ PD"
    value_format_name: usd
    type: sum
    sql: CASE
      WHEN ${days_past_due} >= 121 THEN ${raw_total_balance}
      ELSE 0
    END ;;
    drill_fields: [trx_details*]
  }


  measure: current_percent {
    label: "Current %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_current_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_1_30_days_percent {
    label: "1 - 30 Days %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_1_30_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_31_60_days_percent {
    label: "31 - 60 Days %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_31_60_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_61_90_days_percent {
    label: "61 - 90 Days %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_61_90_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_91_120_days_percent {
    label: "91 - 120 Days %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_91_120_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }

  measure: aging_120_plus_days_percent {
    label: "120+ Days %"
    value_format_name: percent_1
    type: number
    sql: CASE WHEN ${total_balance} = 0
              THEN 0
              ELSE ${aging_120_plus_days} / ${total_balance}
          END ;;
    drill_fields: [trx_details*]
  }


  measure: dso {
    label: "DSO"
    type: number
    value_format_name: decimal_1
    sql: CASE
      WHEN ${total_revenue} = 0 THEN 0
      ELSE ( ${total_balance} / ${total_revenue} ) * MAX(${days_in_quarter})
    END ;;
    drill_fields: [trx_details*]
  }

  measure: percent_in_dispute {
    type: number
    value_format_name: percent_2
    sql:  iff(count(${in_dispute})=0,0,sum(${in_dispute}) / count(${in_dispute}))  ;;
    drill_fields: [trx_details*]
  }

  measure: amount_to_be_collected  {
    type: number
    value_format_name: usd
    sql: iff(${collector_targets.actual_collections} >= ${collector_targets.goal},0,${collector_targets.goal}-${collector_targets.actual_collections}) ;;
    drill_fields: [trx_details*]
  }

  measure: cash_collected_percent {
    label: "Cash Collected %"
    type:  number
    value_format_name: percent_1
    sql: iff(${collector_targets.goal} = 0,0,${collector_targets.actual_collections}/${collector_targets.goal})   ;;
    drill_fields: [trx_details*]
  }

  measure: remaining_credit_amount  {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.REMAINING_CREDIT_AMOUNT ;;
  }





  ########### DRILL FIELDS ###########

  set: trx_details {
    fields: [collector_targets.collector,collector_targets.manager,customer_name,branch_name,
             collector_targets.actual_collections,total_balance,remaining_credit_amount,pre_over_payments.pre_over_payments,
            aging_current_days,current_percent,aging_1_30_days,aging_1_30_days_percent,
            aging_31_60_days,aging_31_60_days_percent,aging_61_90_days,aging_61_90_days_percent,aging_91_120_days,
            aging_91_120_days_percent,aging_120_plus_days,aging_120_plus_days_percent
      ]
  }



}
