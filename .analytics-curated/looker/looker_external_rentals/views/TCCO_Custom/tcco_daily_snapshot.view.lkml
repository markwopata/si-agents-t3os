view: tcco_daily_snapshot {
 derived_table: {
  sql: with companies_list as (
      SELECT distinct company_id
      FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
      where (parent_company_id = 18395
      or company_id = 18395)
      )
      , shift_id as
      (
      select distinct rental_id, shift_type_id
      from rentals r
      left join orders o on o.order_id = r.rental_id
      where o.company_id  in
      (select * from companies_list)
      )
      , billed_and_accrued as (
      select
        i.company_id
      , sum(i.billed_amount) as total_billed_overall_past_28
      , sum(i.tax_amount) as total_tax_amount_past_28
      from invoices i
      where
      i.company_id  in
      (select * from companies_list)
      and invoice_date >= dateadd(day, -28, current_date())
      group by i.company_id

      )

      select
        cv.rental_company_id
      , c.name as company_name
      , ai.category
      , ai.asset_class as sub_category
      , NULL as Trade_Type
      , div0(sum(baa.total_billed_overall_past_28) , count(ai.asset_class)) as total_billed_overall_past_28
      , NUll as total_accrued
      , count(distinct onr.asset_id) as pieces_on_rent
      , sum(case when market_id in (1,2,3,4) then 1 else 1 end) as total_pieces_in_yard
      , round(sum(div0(bdu.on_time_cst , 3600)), 2) as hours_on_rent
      --, NULL as count_items_over_50_percent_utilization_7_days
      --, NULL as count_items_over_20_percent_utilization_7_days
      , NULL as total_items_in_service
      --, NULL as items_within_20_percent_benchmark
      --, NULL as items_over_benchmark
      --, NULL as items_under_benchmark
      --, sh.shift_type_id
      from business_intelligence.triage.stg_t3__asset_info ai
      left join business_intelligence.triage.stg_t3__company_values cv on cv.asset_id = ai.asset_id
      left join es_warehouse.public.companies c on c.company_id = cv.rental_company_id
      left join business_intelligence.triage.stg_t3__on_rent onr on ai.asset_id = onr.asset_id
      left join business_intelligence.triage.stg_t3__by_day_utilization bdu on bdu.asset_id = ai.asset_id
      left join business_intelligence.triage.stg_t3__rental_status_info rsi on rsi.rental_id = cv.rental_id
      left join shift_id sh on sh.rental_id = rsi.rental_id
      left join billed_and_accrued baa on baa.company_id = cv.rental_company_id
      --and bdu.date >= cv.start_date and bdu.date <= cv.end_date
      left join business_intelligence.triage.stg_t3__asset_fuel_consumption afc on afc.asset_id = ai.asset_id
      --and afc.hau_start_date >= cv.start_date and afc.hau_end_date <= cv.end_date
      --left join business_intelligence.triage.stg_t3__
      where
      (
       cv.rental_company_id in (select * from companies_list)
      or ai.company_id in (select * from companies_list)
      )
      and bdu.date >= '2025-11-01'
      and afc.hau_end_date >= '2025-11-01'
      and (rsi.rental_end_date >= '2025-11-01' or rsi.rental_end_date >= '2025-11-01'
      or rsi.company_id in (select * from companies_list))

      GROUP BY
        cv.rental_company_id
      , c.name
      , ai.category
      , ai.asset_class  ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: rental_company_id {
  type: number
  sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
}

dimension: company_name {
  type: string
  sql: ${TABLE}."COMPANY_NAME" ;;
}

dimension: category {
  type: string
  sql: ${TABLE}."CATEGORY" ;;
}

dimension: sub_category {
  type: string
  sql: ${TABLE}."SUB_CATEGORY" ;;
}

dimension: trade_type {
  type: string
  sql: ${TABLE}."TRADE_TYPE" ;;
}

dimension: total_billed_overall_past_28 {
  type: number
  sql: ${TABLE}."TOTAL_BILLED_OVERALL_PAST_28" ;;
}

dimension: total_accrued {
  type: string
  sql: ${TABLE}."TOTAL_ACCRUED" ;;
}

dimension: pieces_on_rent {
  type: number
  sql: ${TABLE}."PIECES_ON_RENT" ;;
}

dimension: total_pieces_in_yard {
  type: number
  sql: ${TABLE}."TOTAL_PIECES_IN_YARD" ;;
}

dimension: hours_on_rent {
  type: number
  sql: ${TABLE}."HOURS_ON_RENT" ;;
}

dimension: total_items_in_service {
  type: string
  sql: ${TABLE}."TOTAL_ITEMS_IN_SERVICE" ;;
}

measure: pieces_on_rent_sum {
  label: "Pieces on Rent"
  type: sum
  sql: ${pieces_on_rent} ;;
}

measure: categories_in_service{
  label: "Categories In Service"
  type: count_distinct
  sql: ${category} ;;
}

measure: total_pieces_in_yard_sum {
  label: "Total Pieces in Yard"
  type: sum
  sql: ${total_pieces_in_yard} ;;
}

measure: on_rent_percent {
  label: "On Rent %"
  value_format_name: percent_1
  type: number
  sql: div0(${pieces_on_rent_sum}, ${total_pieces_in_yard_sum}) ;;
}

measure: total_billed_overall_past_28_sum {
  label: "Total Billed On Rent"
  value_format_name: usd_0
  type: sum
  sql: ${total_billed_overall_past_28} ;;
}

set: detail {
  fields: [
    rental_company_id,
    company_name,
    category,
    sub_category,
    total_billed_overall_past_28,
    total_accrued,
    pieces_on_rent,
    total_pieces_in_yard,
    hours_on_rent,
    total_items_in_service
  ]
}
}
