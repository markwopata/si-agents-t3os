view: asset_nbv {
  derived_table: {
    sql:
       with nbv_all_owners as(
  SELECT
    *
    FROM ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS
    WHERE COMPANY_ID in (1854,1855)
    )
  ,operating_leases as(
  select
a2.asset_id
,d.financing_facility_type
,1 as op_lease_ind
from ES_WAREHOUSE.public.assets a2
left join ES_WAREHOUSE.public.asset_purchase_history aph
  on a2.asset_id = aph.asset_id
left join analytics.DEBT.phoenix_id_types pit
  on aph.financial_schedule_id  = pit.financial_schedule_id
left join (select  distinct phoenix_id, financing_facility_type
      from analytics.DEBT.tv6_xml_debt_table_current
      where current_version = 'Yes') d
   on pit.phoenix_id  = d.phoenix_id
where d.financing_facility_type = 'Operating'
)
 ,add_asset_inventory_status as(
select
askv.asset_id
,askv.name
,askv.value as rpo_status
from  ES_WAREHOUSE.PUBLIC.asset_status_key_values askv
where name = 'asset_inventory_status'
order by asset_id
)
, remove_financed_lenders as(
select aph.asset_id, coalesce(a.serial_number, a.vin) as serial_vin,
fs.financial_schedule_id, fs.current_schedule_number,
fs.originating_lender_id, fl.name as lender_name, a.company_id, aph.finance_status
,1 as remove_financed_lenders_ind
from ES_WAREHOUSE.public.asset_purchase_history as aph
left join ES_WAREHOUSE.public.assets as a
on aph.asset_id = a.asset_id
left join ES_WAREHOUSE.public.financial_schedules as fs
on aph.financial_schedule_id = fs.financial_schedule_id
left join ES_WAREHOUSE.public.financial_lenders as fl
on fs.originating_lender_id = fl.financial_lender_id
where fs.originating_lender_id in (482,305,436)
)
    select
  ap.*
  ,aais.rpo_status
  from nbv_all_owners ap
  left join operating_leases ol
  on ap.asset_id=ol.asset_id
  left join add_asset_inventory_status aais
  on ap.asset_id = aais.asset_id
  left join remove_financed_lenders rfl
  on ap.asset_id=rfl.asset_id
 where
    ol.op_lease_ind is null
 and ap.name is not null
 and aais.rpo_status not like '%RPO%'
 and remove_financed_lenders_ind is null
    ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_invoice_url {
    type: string
    sql: ${TABLE}."ASSET_INVOICE_URL" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: curr_bal {
    type: number
    sql: ${TABLE}."CURR_BAL" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }

  dimension_group: first_rental {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: greensill_ind {
    type: string
    sql: ${TABLE}."GREENSILL_IND" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: nbv {
    type: number
    sql: COALESCE(${TABLE}."NBV",0) ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: orig_bal {
    type: number
    sql: ${TABLE}."ORIG_BAL" ;;
  }

  dimension: paid_in_cash_ind {
    type: number
    sql: ${TABLE}."PAID_IN_CASH_IND" ;;
  }

  dimension: payoff_amount {
    type: number
    sql: COALESCE(${TABLE}."PAYOFF_AMT",0) ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension_group: purchase {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: serial_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }


  measure: asset_replacement_value {
    type: sum
    sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 1.26)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.26)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.26)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.26)
              ELSE 0 END ;;
  }

  measure: price_floor {
    type: sum
    sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 0.08) + ${TABLE}.nbv
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 0.08) + ${payoff_amount}
              ELSE 0 END ;;
  }

  measure: asset_replacement_value_sales_reps {
    type: sum
    sql: CASE WHEN ${greensill_ind} = 'greensill' THEN (${nbv} * 1.22)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY500%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY50%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY35%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY135%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY95%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY215%' THEN (${nbv} * 1.25)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 120%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 100%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 125%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 150%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 135%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 180%' THEN (${nbv} * 1.30)
              WHEN ${paid_in_cash_ind} = 1 THEN (${nbv} * 1.22)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.22)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.22)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.22)
              ELSE 0 END ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count
    drill_fields: [market_name, company_name]
  }
}
