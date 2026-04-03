view: asset_nbv_all_owners {
  derived_table: {
    sql: -- This code is used to get the data to calculate retail payoffs
      -- get asset id using serial number
with asset_statuses as(
select
askv.asset_id
,askv.value as asset_inventory_status
from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES askv
where askv.name = 'asset_inventory_status'
  order by askv.asset_id
)
, asset_hours as(
select
ash.asset_id
,ash.hours
,ROW_NUMBER() OVER (PARTITION BY ash.asset_id ORDER BY ash.date_start DESC) AS rn
from ES_WAREHOUSE.SCD.scd_asset_hours ash
order by ash.asset_id ,ash.date_start
)
,consolidate_hours as(
select
ah.asset_id
,hours
from asset_hours ah
where rn=1
)
, serial_to_asset as
(select distinct a.asset_id, a.serial_number,a.vin, a.market_id, a.make, a.model, a.asset_class,a.asset_type_id ,att.name as asset_type,a.company_id ,c.name as company_name,ah.hours, a.description , r.asset_inventory_status as rental_status, a.date_created::date as date_created
  from ES_WAREHOUSE.public.assets as a
  left join asset_statuses r
    on a.asset_id=r.asset_id
  left join consolidate_hours ah
    on a.asset_id=ah.asset_id
  left join ES_WAREHOUSE.PUBLIC.asset_types att
    on a.asset_type_id =att.asset_type_id
  left join ES_WAREHOUSE.PUBLIC.companies c
    on a.company_id =c.company_id
    where a.company_id not in (420,155)
)
-- get current purchase history id for ALL asset ids
,all_ph_id as
(select aph.asset_id, max(aph.purchase_history_id) as purchase_history_id, aph.loss_or_damage_remedies, aph.financial_schedule_id
  from ES_WAREHOUSE.public.asset_purchase_history aph
  group by aph.asset_id, aph.financial_schedule_id, aph.loss_or_damage_remedies )
--select asset ids and purch hist ids only for the serials selected
,asset_to_ph_id as
(select sta.asset_id, api.financial_schedule_id, sta.serial_number,sta.vin, sta.market_id, sta.make, sta.model, sta.asset_class,sta.asset_type_id, sta.asset_type,sta.company_id,sta.company_name,
  sta.hours, sta.description, sta.rental_status,sta.date_created, api.purchase_history_id, api.loss_or_damage_remedies
  from serial_to_asset sta
  left join
  all_ph_id api
  on
  sta.asset_id = api.asset_id)
--select * from asset_to_ph_id
--select first rental date
,add_first_rent_dt as
(select a.*, min(ea.start_date) as first_rental
  from
    asset_to_ph_id a
  left join
    ES_WAREHOUSE.public.equipment_assignments ea
  on
    a.asset_id = ea.asset_id
  group by a.asset_id, a.serial_number,a.vin, a.financial_schedule_id,  a.purchase_history_id, a.loss_or_damage_remedies, a.market_id,a.make,
  a.model, a.asset_class ,a.asset_type_id, a.asset_type,a.company_id,a.company_name, a.hours, a.description , a.rental_status, a.date_created )
--select * from add_first_rent_dt
-- get phoenix id
,add_phoenix_id as
(select a.*, coalesce(pt.phoenix_id,99005) as phoenix_id
  from
    add_first_rent_dt a
  left join
 --   analytics.asset_purchase_history_by_schedule b
 -- on a.asset_id = b.asset_id
    ES_WAREHOUSE.public.asset_purchase_history b
    on a.asset_id=b.asset_id
    left join analytics.DEBT.phoenix_id_types pt
    on b.financial_schedule_id = pt.financial_schedule_id)
--select * from add_phoenix_id
-- get loan name
,add_loan_nm as
(select a.*,
fsh.current_schedule_number as schedule
  from
    add_phoenix_id a
left join ES_WAREHOUSE.public.financial_schedules as fsh
on a.financial_schedule_id = fsh.financial_schedule_id)
--select * from add_loan_nm
--convert nulls to values in tv6 table
,no_nulls as
(select (case
      when date is NULL then
        current_timestamp
      else
        date
      end ) as date,
(case
  when version_tv is null then
'V1'
  else
    version_tv
  end) as version_tv,
    (case
      when gaap_non_gaap is null then
        'Non-GAAP'
      else
        gaap_non_gaap
      end) as gaap_non_gaap,
    (case
      when "customType" is null then
        'Payment'
      else
        "customType"
      end) as "customType",
    (case
      when oec is null then
        1
      else
        oec
      end) as oec,
    (case
      when balance is null then
        1
      else
        balance
      end) as balance,
    phoenix_id
from analytics.DEBT.tv6_xml_debt_table_current)
--select * from no_nulls
 ,bal1 as (
select distinct phoenix_id, oec as orig_bal, oec as cur_bal
from
  no_nulls
--analytics.tv6_xml_debt_table txdt
where
  "customType" = 'Loan' and version_tv = 'V1')
,bal2 as (
select distinct phoenix_id, oec as orig_bal, balance as cur_bal
from
  no_nulls txdt
  --analytics.tv6_xml_debt_table txdt
where
  txdt.date <= current_timestamp and txdt.version_tv = 'V1' and txdt.gaap_non_gaap = 'Non-GAAP'
  and txdt."customType" = 'Payment')
, bal1_bal2 as (
select
  a.*
from
  bal1 a
union
select b.*
from
  bal2 b)
,final_bal as (
select phoenix_id, orig_bal, min(cur_bal) as cur_bal from bal1_bal2 group by phoenix_id, orig_bal)
,add_balances as
(select a.*, orig_bal, cur_bal as curr_bal
 from
  add_loan_nm a
 left join
  final_bal txdt
 on a.phoenix_id = txdt.phoenix_id)
--get original balance and current balance
-- get purchase price
,add_purch_price as
(select a.*, aph.purchase_price,aph.oec,coalesce(aph.purchase_date ,aph.invoice_purchase_date )::date  as purchase_date ,coalesce(aph.asset_invoice_url,aph.invoice_number) as asset_invoice_url, aph.pending_schedule
  from
    add_balances a
  left join
    ES_WAREHOUSE.public.asset_purchase_history aph
  on
    a.asset_id = aph.asset_id
    )
,final2 as (
select asset_id, serial_number,vin, market_id, make, model, purchase_date, asset_class,date_created,asset_type_id, asset_type,company_id,company_name, description,loss_or_damage_remedies as finance_status,asset_invoice_url,pending_schedule,
    coalesce(oec,purchase_price) as oec,
    (case
      when schedule is not null then
      schedule
      else
      loss_or_damage_remedies
      end) as schedule,
     orig_bal, curr_bal, first_rental
from add_purch_price
)
,add_mkt as (
select a.*, m.name
from
  final2 a
left join
  ES_WAREHOUSE.public.markets m
on
  a.market_id = m.market_id
  )
--select * from add_mkt
,add_NBV as (
select a.*
  ,CASE WHEN a.asset_type_id = 2 THEN
    greatest(a.oec - ((current_timestamp::date - COALESCE(COALESCE(a.purchase_date::date,a.date_created::date),CURRENT_TIMESTAMP::date))::NUMERIC/2557.1)*
    (a.oec*.9),.1*a.oec)
    ELSE greatest(a.oec - ((current_timestamp::date - COALESCE(a.first_rental::date,CURRENT_TIMESTAMP::date))::NUMERIC/3653)*
    (a.oec*.8),.2*a.oec)
    END AS NBV
  --,a.oec-(date_part('day',current_timestamp()::DATE - coalesce(coalesce(a.purchase_date::DATE,a.date_created::DATE),current_timestamp()::DATE))/2557.1)*(a.oec*.9)
// , case when(a.asset_type_id = 2) then (greatest((a.oec-DATEDIFF('day',current_timestamp()::DATE - coalesce(coalesce(a.purchase_date::DATE,a.date_created::DATE),current_timestamp()::DATE))/2557.1)*(a.oec*.9),0.1*a.oec))
//   else (greatest(a.oec-(DATEDIFF('day',current_timestamp()::DATE - coalesce(a.first_rental,current_timestamp()::DATE))/3653)*(.8*a.oec),.2*a.oec))
//  end as NBV
from
  add_mkt a
 )
,add_payoff as(
select a.*,
  case
    when (a.schedule like '%Greensill%') or (a.schedule like '%Line of Credit%') then a.NBV
    else (a.oec/a.orig_bal)*a.curr_bal
    end as payoff_amt
from
 add_NBV a
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
,add_greensill_ind as(
 select
 ag.asset_id
 ,'greensill' as greensill_ind
 from ES_WAREHOUSE.PUBLIC.assets ag
left join ES_WAREHOUSE.PUBLIC.asset_purchase_history aphg
  on ag.asset_id = aphg.asset_id
left join analytics.debt.phoenix_id_types pitg
  on aphg.financial_schedule_id = pitg.financial_schedule_id
left join ES_WAREHOUSE.PUBLIC.financial_schedules fg
  on aphg.financial_schedule_id = fg.financial_schedule_id
left join ES_WAREHOUSE.PUBLIC.financial_lenders flg
  on fg.originating_lender_id  = flg.financial_lender_id
where flg.financial_lender_id = 533
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
  ,case when(schedule like '%paid in cash%') then 1 else 0 end as paid_in_cash_ind
  ,aais.rpo_status
  ,case when(agi.greensill_ind is null ) then 'non_greensill' else agi.greensill_ind end as greensill_ind
  from add_payoff ap
  left join operating_leases ol
  on ap.asset_id=ol.asset_id
  left join add_asset_inventory_status aais
  on ap.asset_id = aais.asset_id
  left join add_greensill_ind agi
  on ap.asset_id=agi.asset_id
  left join remove_financed_lenders rfl
  on ap.asset_id=rfl.asset_id
             ;;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }

  dimension: asset_type_id {
    type: string
    sql: ${TABLE}.asset_type_id ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}.asset_type ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}.finance_status ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}.hours ;;
  }

  dimension: oec{
    type: number
    sql: ${TABLE}.oec ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }

  dimension: orig_bal{
    type: number
    sql: ${TABLE}.orig_bal ;;
  }

  dimension: curr_bal{
    type: number
    sql: ${TABLE}.curr_bal ;;
  }

  dimension_group: first_rental {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_rental ;;
  }

  dimension: payoff_amount{
    type: number
    sql: ${TABLE}.payoff_amt ;;
  }

  dimension: nbv{
    type: number
    sql: ${TABLE}.nbv ;;
  }

  dimension: paid_in_cash_ind{
    type: yesno
    sql: ${TABLE}.paid_in_cash_ind ;;
  }

  measure: asset_replacement_value {
    type: sum
    sql: CASE WHEN ${TABLE}.paid_in_cash_ind=1 THEN (${TABLE}.nbv * 1.20)
              WHEN ${TABLE}.payoff_amt IS NULL THEN (${TABLE}.nbv * 1.20)
              WHEN ${TABLE}.nbv >= ${TABLE}.payoff_amt THEN (${TABLE}.nbv * 1.20)
              WHEN ${TABLE}.nbv < ${TABLE}.payoff_amt THEN (${TABLE}.payoff_amt * 1.20)
              ELSE 0 END ;;
  }

  measure: price_floor {
    type: sum
    sql: CASE WHEN ${TABLE}.paid_in_cash_ind=1 THEN (${TABLE}.nbv * 0.08) + ${TABLE}.nbv
              WHEN ${TABLE}.payoff_amt IS NULL THEN (${TABLE}.nbv * 0.08) + ${TABLE}.nbv
              WHEN ${TABLE}.nbv >= ${TABLE}.payoff_amt THEN (${TABLE}.nbv * 0.08) + ${TABLE}.nbv
              WHEN ${TABLE}.nbv < ${TABLE}.payoff_amt THEN (${TABLE}.payoff_amt * 0.08) + ${TABLE}.payoff_amt
              ELSE 0 END ;;
  }

  dimension: date_created{
    type: date
    sql: ${TABLE}.date_created ;;
  }

  dimension: purchase_date{
    type: date
    sql: ${TABLE}.purchase_date ;;
  }

}
