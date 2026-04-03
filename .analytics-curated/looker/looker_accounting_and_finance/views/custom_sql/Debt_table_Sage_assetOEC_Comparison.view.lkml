view: debt_table_sage_assetoec_comparison {
  parameter: date_FILTER {
    type: date
  }
    derived_table: {
      sql: WITH SAGE_BAL AS (
select
  a.sage_id,
  round(sum(a.princ_amt),2) as SAGE_BALANCE
from(
    SELECT *,ul.name as sage_id, (cast(glt.tr_type as integer)*-1)*cast(glt.amount as decimal) as princ_amt
    FROM
      ANALYTICS.INTACCT.UD_LOAN UL
    LEFT JOIN
      ANALYTICS.INTACCT.VENDOR VD
      ON cast(vd.recordno as text) = ul.rvendor
    LEFT JOIN
      ANALYTICS.INTACCT.GLENTRY GLT
      ON UL.ID = cast(glt.gldimud_loan as text)
    WHERE
    glt.state = 'Posted'
    AND
    glt.accountno = '2500'
    and glt.entry_date::date <= {% parameter date_FILTER %}) A
group by a.sage_id
)
--SELECT * FROM sage_bal WHERE sage_id = '2500-00230'
,SAGE_TXN_DT AS (
  SELECT
    UL.NAME AS SAGE_ID,
    MAX(GLT.ENTRY_DATE) AS LATEST_SAGE_TXNDT
  FROM
    ANALYTICS.INTACCT.UD_LOAN UL
  LEFT JOIN
    ANALYTICS.INTACCT.GLENTRY GLT
    ON UL.ID = cast(glt.gldimud_loan as TEXT)
  WHERE
    GLT.ENTRY_DATE::date <= {% parameter date_FILTER %}
  GROUP BY UL.NAME
)
,closest_dt as (
  select
    phoenix_id,
    max(date) as closest_dt
  from
    ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT TXDT
  where
      txdt.gaap_non_gaap = 'Non-GAAP'
    and txdt.CUSTOMTYPE in ('MonthTotal')
    and current_version = 'Yes'
    --AND FINANCING_FACILITY_TYPE NOT IN ('Operating','Synthetic')
      and date <= {% parameter date_FILTER %}
      group by phoenix_id
)
,get_cur_bal as (
   select
      b.phoenix_id,
      b.balance,
      b.COMMENCEMENT_DATE
   from
      closest_dt a
   left join
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT b
    on
      a.phoenix_id = b.phoenix_id
      and
      a.closest_dt = b.date
    where
          b.gaap_non_gaap = 'Non-GAAP'
    and b.CUSTOMTYPE in ('MonthTotal')
    and b.current_version = 'Yes'
)
,add_slid as (
  select
    a.*,
    b.sage_loan_id,
    b.sage_account_number
  from
    get_cur_bal a
  left join
    ANALYTICS.DEBT.PHOENIX_ID_TYPES b
  on a.phoenix_id = b.phoenix_id
)
,FINAL_DT_BAL AS (
  select
    sage_loan_id as SAGE_ID,
    sage_account_number ,
    sum(balance) AS DT_BALANCE
  from
    add_slid
  group by sage_loan_id, sage_account_number
)
,DT_TXN_DT AS (
  SELECT
    B.*,
    C.SAGE_LOAN_ID
  FROM
    (SELECT
      A.PHOENIX_ID,
      MAX(A.DATE) AS LATEST_DT_TXNDT
    FROM
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT A
    WHERE
      DATE::date <= {% parameter date_FILTER %}
      AND CUSTOMTYPE IN ('Loan','Payment')
      AND CURRENT_VERSION = 'Yes'
      AND GAAP_NON_GAAP = 'Non-GAAP'
    GROUP BY A.PHOENIX_ID) B
  LEFT JOIN
    ANALYTICS.DEBT.PHOENIX_ID_TYPES C
  ON B.PHOENIX_ID = C.PHOENIX_ID
)
,GET_CDT AS (
  SELECT DISTINCT
    B.SAGE_LOAN_ID,
    A.COMMENCEMENT_DATE,
    A.FINANCING_FACILITY_TYPE
  FROM
    (SELECT DISTINCT
      PHOENIX_ID,
      COMMENCEMENT_DATE,
      FINANCING_FACILITY_TYPE
    FROM
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT
    WHERE
      CURRENT_VERSION = 'Yes'
      AND GAAP_NON_GAAP = 'Non-GAAP') A
    LEFT JOIN
      ANALYTICS.DEBT.PHOENIX_ID_TYPES B
    ON
      A.PHOENIX_ID = B.PHOENIX_ID
)
,GET_DT_OEC AS (
  SELECT DISTINCT
    PHOENIX_ID,
    OEC
  FROM
    ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT
  WHERE
    CURRENT_VERSION = 'Yes'
    AND GAAP_NON_GAAP = 'Non-GAAP'
)
,ADD_DT_SID AS (
  SELECT
    A.*,
    B.SAGE_LOAN_ID
  FROM
    GET_DT_OEC A
  LEFT JOIN
    ANALYTICS.DEBT.PHOENIX_ID_TYPES B
  ON A.PHOENIX_ID = B.PHOENIX_ID
)
,SUM_BY_DTSLID AS (
  SELECT
    SAGE_LOAN_ID,
    SUM(OEC) AS DT_ORIG_BAL
  FROM
    ADD_DT_SID
  GROUP BY SAGE_LOAN_ID
)
,SUM_APH_OEC AS (
  SELECT
    FINANCIAL_SCHEDULE_ID ,
    SUM(COALESCE(PURCHASE_PRICE, OEC)) AS ASSET_OEC
  FROM
    ES_WAREHOUSE."PUBLIC".ASSET_PURCHASE_HISTORY
  GROUP BY FINANCIAL_SCHEDULE_ID
)
,ADD_SAGE_ID AS (
  SELECT
    A.*,
    B.SAGE_LOAN_ID
  FROM
    SUM_APH_OEC A
  LEFT JOIN
    ANALYTICS.DEBT.PHOENIX_ID_TYPES B
  ON A.FINANCIAL_SCHEDULE_ID = B.FINANCIAL_SCHEDULE_ID
)
,SUM_BY_SLID AS (
  SELECT
    SAGE_LOAN_ID,
    SUM(ASSET_OEC) AS ASSET_OEC_SUM
  FROM
    ADD_SAGE_ID
  GROUP BY SAGE_LOAN_ID
)
,JOIN_ALL AS (
  SELECT
    A.SAGE_ID,
    B.SAGE_BALANCE,
    A.DT_BALANCE,
    ABS(COALESCE(A.DT_BALANCE,0) - B.SAGE_BALANCE) AS VARIANCE,
    C.LATEST_SAGE_TXNDT,
    D.LATEST_DT_TXNDT,
    E.COMMENCEMENT_DATE,
    F.DT_ORIG_BAL,
    G.ASSET_OEC_SUM,
    E.FINANCING_FACILITY_TYPE
  FROM
    FINAL_DT_BAL A
  LEFT JOIN
    SAGE_TXN_DT C
    ON A.SAGE_ID = C.SAGE_ID
  LEFT JOIN
    DT_TXN_DT D
    ON A.SAGE_ID = D.SAGE_LOAN_ID
  LEFT JOIN
    GET_CDT E
    ON A.SAGE_ID = E.SAGE_LOAN_ID
  LEFT JOIN
    SUM_BY_DTSLID F
    ON A.SAGE_ID = F.SAGE_LOAN_ID
  LEFT JOIN
    SUM_BY_SLID G
    ON A.SAGE_ID = G.SAGE_LOAN_ID
  LEFT JOIN
    SAGE_BAL B
    ON A.SAGE_ID = B.SAGE_ID
  ORDER BY VARIANCE DESC
)
,RMV_NULL_OEC_SUM AS (
  SELECT
    SAGE_ID,
    round(SAGE_BALANCE) AS SAGE_BALANCE,
    CASE
      WHEN DT_BALANCE IS NULL
      THEN 0
      ELSE round(DT_BALANCE)
    END DT_BALANCE,
    round(VARIANCE) AS CURR_BAL_VARIANCE,
    LATEST_SAGE_TXNDT,
    LATEST_DT_TXNDT,
    COMMENCEMENT_DATE,
    round(DT_ORIG_BAL) AS DT_ORIG_BAL,
    CASE
      WHEN ASSET_OEC_SUM IS NULL
      THEN 0
      ELSE round(ASSET_OEC_SUM )
    END ASSET_OEC_SUM,
    FINANCING_FACILITY_TYPE
  FROM
    JOIN_ALL
)
SELECT DISTINCT *, ROUND(ABS(DT_ORIG_BAL - ASSET_OEC_SUM)) AS ORIG_BAL_VARIANCE
FROM
  RMV_NULL_OEC_SUM;;
    }
  dimension: sage_id {
    type: string
    sql: ${TABLE}.sage_id ;;
  }

  dimension: sage_balance {
    label: "Current balance in Sage"
    type: number
    description: "Current balance in Sage as of the 'End of Accounting Period' date used in your filter"
    sql: ${TABLE}.sage_balance ;;
  }

  dimension: dt_balance {
    label: "Current balance on the Debt Table"
    type: number
    description: "Current balance in the Debt Table as of the 'End of Accounting Period' date used in your filter"
    sql: ${TABLE}.dt_balance ;;
  }

  dimension: curr_bal_variance {
    type: number
    label: "Variance in current balances"
    description: "This is the difference between the current balance in Sage and the current balance in the
    Debt Table as of the 'End of Accounting Period' date used in your filter"
    sql: ${TABLE}.curr_bal_variance ;;
  }

  dimension: latest_sage_txndt {
    label: "Latest Sage Transaction Date"
    description: "This is the date of the most recent transaction posted in Sage that is less than
    or equal to the 'End of Accounting Period' date used in your filter"
    type: date
    sql: ${TABLE}.latest_sage_txndt ;;
  }

  dimension: latest_dt_txndt {
    label: "Latest Debt Table Transaction Date"
    description: "This is the date of the most recent transaction on the Debt Table that is less than
    or equal to the 'End of Accounting Period' date used in your filter"
    type: date
    sql: ${TABLE}.latest_dt_txndt ;;
  }

  dimension: commencement_date {
    type: date
    sql: ${TABLE}.commencement_date ;;
  }

  dimension: dt_orig_bal {
    label: "Original balance on Debt Table"
    type: number
    sql: ${TABLE}.dt_orig_bal ;;
  }

  dimension: asset_oec_sum {
    description: "This is the sum of the OEC/purchase prices of all assets tied to this loan"
    type: number
    sql: ${TABLE}.asset_oec_sum ;;
  }

  dimension: orig_bal_variance {
    description: "Variance between original debt table balance and sum of assets' OEC."
    type: number
    sql: ${TABLE}.orig_bal_variance ;;
  }

  dimension: FINANCING_FACILITY_TYPE {
    type: string
    sql: ${TABLE}.FINANCING_FACILITY_TYPE ;;
  }


}
