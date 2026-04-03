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
 and remove_financed_lenders_ind is null  ;;
}


dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension: serial_number {
  type: string
  sql: ${TABLE}."SERIAL_NUMBER" ;;
}

dimension: asset_type_id {
  type: string
  sql: ${TABLE}."ASSET_TYPE_ID" ;;
}
dimension: asset_type {
  type: string
  sql: ${TABLE}."ASSET_TYPE" ;;
}

dimension: market_id {
  type: number
  sql: ${TABLE}."MARKET_ID" ;;
}

dimension: market_name {
  type: string
  sql: ${TABLE}."NAME" ;;
}

dimension: make {
  type: string
  sql: ${TABLE}."MAKE" ;;
}

dimension: model {
  type: string
  sql: ${TABLE}."MODEL" ;;
}

dimension: equipment_class {
  type: string
  sql: ${TABLE}."ASSET_CLASS" ;;
}

dimension: description {
  type: string
  sql: ${TABLE}."DESCRIPTION" ;;
}

dimension: rental_status {
  type: string
  sql: ${TABLE}."RENTAL_STATUS" ;;
}

dimension: finance_status {
  type: string
  sql: ${TABLE}."FINANCE_STATUS" ;;
}

dimension: hours {
  type: number
  sql: ${TABLE}."HOURS" ;;
}

dimension: oec{
  type: number
  sql: ${TABLE}."OEC" ;;
}

dimension: schedule {
  type: string
  sql: ${TABLE}."SCHEDULE" ;;
}

dimension: orig_bal{
  type: number
  sql: ${TABLE}."ORIG_BAL" ;;
}

dimension: curr_bal{
  type: number
  sql: ${TABLE}."CURR_BAL" ;;
}

dimension_group: first_rental {
  type: time
  timeframes: [date, week, month, year]
  sql: ${TABLE}."FIRST_RENTAL" ;;
}

dimension: payoff_amount{
  type: number
  sql: ${TABLE}."PAYOFF_AMT" ;;
}

dimension: nbv{
  type: number
  sql: ${TABLE}."NBV" ;;
}

dimension: paid_in_cash_ind{
  type: yesno
  sql: ${TABLE}."PAID_IN_CASH_IND" ;;
}

measure: asset_replacement_value {
  type: sum
  sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 1.20)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.20)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.20)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.20)
              ELSE 0 END ;;
}

measure: price_floor {
  type: sum
  sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 0.08) + ${payoff_amount}
              ELSE 0 END ;;
}

dimension: date_created{
  type: date
  sql: ${TABLE}."DATE_CREATED" ;;
}

dimension: purchase_date{
  type: date
  sql: ${TABLE}."PURCHASE_DATE" ;;
}

}
