view: asset_utilization_ratio {
  derived_table: {
    sql:
with revenue_by_asset_cte as (
                                                                    select li.asset_id
                                                                    , li.line_item_id
                                                                    , i.invoice_id
                                                                    , (CURRENT_DATE - INTERVAL '12 months')            as ttm_start
                                                                    , CURRENT_DATE                                     as ttm_end
                                                                    , i.start_date
                                                                    , i.end_date
                                                                    , li.amount
                                                               from es_warehouse.public.line_items li
                                                                        join es_warehouse.public.invoices i on li.invoice_id = i.invoice_id
                                                               where li.line_item_type_id = 8
                                                                 and i.company_id <> 1854
                                                                 and li.asset_id is not null
                                                                 and amount <> 0)

, financial_util_summary_cte as (select asset_id
                                      , ttm_start::date           as ttm_start
                                      , ttm_end::date             as ttm_end
                                      , sum(amount) as asset_revenue
                                 from revenue_by_asset_cte
                                 group by asset_id, ttm_start, ttm_end
                                 order by ttm_start, asset_id)

, time_util_cte as (select (CURRENT_DATE - INTERVAL '12 months')                               as ttm
                         , datediff(days, (CURRENT_DATE - INTERVAL '12 months'), CURRENT_DATE) as ttm_length
                         , asset_id
                         , purchase_price
                         , sum(iff(on_rent, 1, 0))                                             as days_on_rent
                         , sum(iff(in_rental_fleet, 1, 0))                                     as days_asset_in_fleet
                         , iff(ttm_length = days_asset_in_fleet, true, false)                  as in_fleet_entire_ttm
                    from historical_utilization
                    where in_rental_fleet
                      and purchase_price > 0
                    group by (CURRENT_DATE - INTERVAL '12 months'), asset_id, purchase_price)

 select tuc.asset_id
      --, aa.class
      , tuc.ttm
      , tuc.days_on_rent
      , tuc.days_asset_in_fleet
      , tuc.in_fleet_entire_ttm
      , days_on_rent / days_asset_in_fleet                  as time_utilization
      , fusc.asset_revenue
      , tuc.purchase_price
      , case
            when min(rs.date_start) < ttm then asset_revenue / purchase_price
            else asset_revenue *
                 (datediff('days', (CURRENT_DATE - INTERVAL '12 months'), CURRENT_DATE) /
                  days_asset_in_fleet) / purchase_price end as financial_utilization
 from time_util_cte tuc
          join financial_util_summary_cte fusc
               on tuc.ttm = fusc.ttm_start and tuc.asset_id = fusc.asset_id
          left join es_warehouse.public.assets_aggregate aa on tuc.asset_id = aa.asset_id
          left join ES_WAREHOUSE.SCD.SCD_ASSET_RENTAL_STATUS rs
                    on tuc.asset_id = rs.asset_id
 group by tuc.asset_id, tuc.ttm, tuc.days_on_rent, tuc.days_asset_in_fleet
        , tuc.in_fleet_entire_ttm, days_on_rent / days_asset_in_fleet
        , fusc.asset_revenue, tuc.purchase_price
    ;;
  }

  dimension: asset_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.asset_id ;;
  }

  dimension: ttm {
    type: date
    sql: ${TABLE}.ttm ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}.days_on_rent ;;
  }

  dimension: days_asset_in_fleet {
    type: number
    sql: ${TABLE}.days_asset_in_fleet ;;
  }

  dimension: in_fleet_entire_ttm {
    type: yesno
    sql: ${TABLE}.in_fleet_entire_ttm ;;
  }

  dimension: time_utilization {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.time_utilization ;;
  }

  dimension: asset_revenue {
    type: number
    sql: ${TABLE}.asset_revenue ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}.purchase_price ;;
  }

  dimension: financial_utilization {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.financial_utilization ;;
  }
}
