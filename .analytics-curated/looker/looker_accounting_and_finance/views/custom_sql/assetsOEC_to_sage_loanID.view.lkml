view: assetsoec_to_sage_loanid {
  parameter: first_date {
    type: date
  }
  parameter: second_date {
    type: date
  }
  parameter: sageLoanID_filter {
    type: string
  }
  derived_table: {
    sql:select
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
    DT.COMMENCEMENT_DATE,
    dt.financing_facility_type,
    dt.customType,
    round(dt.principal::numeric ,2) AS principal,
    dt.balance
  from ES_WAREHOUSE."PUBLIC".ASSETS as a
    left join ES_WAREHOUSE."PUBLIC".asset_purchase_history as aph
      on a.asset_id = aph.asset_id
    left join ANALYTICS.DEBT.phoenix_id_types as pit
      on aph.financial_schedule_id = pit.financial_schedule_id
    left join ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT as dt
      on dt.phoenix_id = pit.phoenix_id
  where dt.entity = 'ES'
    and dt.customType = 'MonthTotal'
    AND dt.GAAP_NON_GAAP = 'Non-GAAP'
    AND DT.CURRENT_VERSION = 'Yes'
    AND DT.DATE = (date_trunc('month', {% parameter second_date %}::date) + interval '1 month' - interval '1 day')::date
    and ((DT.commencement_date::date between {% parameter first_date %}
    and {% parameter second_date %}) OR pit.sage_loan_id = {% parameter sageLoanID_filter %})
  ORDER BY PIT.SAGE_LOAN_ID
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
  dimension: balance {
    type: number
    sql: ${TABLE}.balance ;;
  }
}
