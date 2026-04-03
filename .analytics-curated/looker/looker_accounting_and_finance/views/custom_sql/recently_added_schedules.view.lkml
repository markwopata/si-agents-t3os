view: recently_added_schedules {
  parameter: end_date {
    type: date
  }
  derived_table: {
    sql:
 WITH GET_MIN_DT AS (
SELECT DISTINCT PHOENIX_ID, MIN(DATE) AS COMMENCEMENT_DATE
FROM ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT
WHERE
    entity != 'IES2'
    AND "CUSTOMTYPE" = 'Loan'
    AND CURRENT_VERSION = 'Yes'
    AND GAAP_NON_GAAP = 'Non-GAAP'
GROUP BY PHOENIX_ID)
--SELECT * FROM GET_MIN_DT WHERE PHOENIX_ID = 974
,TB2 AS (
select
    a.asset_id,
    a.market_id,
    a."YEAR",
    a.make,
    a.model,
    a.serial_number,
    aph.financial_schedule_id,
    coalesce (aph.oec, aph.purchase_price) as OEC,
    pit.sage_loan_id,
    pit.schedule,
    pit.lender,
    dt.phoenix_id,
    GMD.COMMENCEMENT_DATE AS COMMENCEMENT_DATE,
    dt.financing_facility_type,
    dt."CUSTOMTYPE",
    round(dt.principal::numeric ,2) AS principal,
    dt.balance
  from ES_WAREHOUSE."PUBLIC".ASSETS as a
    left join ES_WAREHOUSE."PUBLIC".asset_purchase_history as aph
      on a.asset_id = aph.asset_id
    left join ANALYTICS.DEBT.phoenix_id_types as pit
      on aph.financial_schedule_id = pit.financial_schedule_id
    left join ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT as dt
      on dt.phoenix_id = pit.phoenix_id
    LEFT JOIN GET_MIN_DT AS GMD
      ON DT.PHOENIX_ID = GMD.PHOENIX_ID AND DT.DATE = GMD.COMMENCEMENT_DATE
  where dt.entity != 'IES2'
    and dt."CUSTOMTYPE" = 'Loan'
    AND dt.GAAP_NON_GAAP = 'Non-GAAP'
    and ((GMD.commencement_date::date >= '01/01/2022'
    and GMD.commencement_date::date <= {% parameter end_date %}))
 )
 SELECT * FROM TB2
 ORDER BY sage_loan_id
      ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: oec {
    type: number
    sql: ${TABLE}.oec ;;
  }
  dimension: sage_loan_id {
    type: string
    sql: ${TABLE}.sage_loan_id ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: phoenix_id {
    type: number
    sql: ${TABLE}.phoenix_id ;;
  }
  dimension: commencement_date {
    type: date
    sql: ${TABLE}.commencement_date ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}.financing_facility_type ;;
  }
  dimension: principal {
    type: number
    sql: ${TABLE}.principal ;;
  }
  dimension: balance {
    type: number
    sql: ${TABLE}.balance ;;
  }
}
