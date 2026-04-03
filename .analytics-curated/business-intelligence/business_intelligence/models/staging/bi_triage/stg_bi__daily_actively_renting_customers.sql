{{ config(
    materialized='table'
    , cluster_by=['date', 'asset_id']
) }}

select v_dim_dates_bi.date, 
iea.asset_id, 
iah.oec, 
iea.rental_id, 
o.market_id, 
iea.date_start, 
iea.date_end, 
c.company_id, 
c.name as company_name,
is_last_30_days , 
is_last_31_days, 
is_last_60_days, 
is_last_90_days, 
is_prior_month_to_date, 
is_prior_month,  
is_current_month , 
is_first_day_of_month, 
is_last_day_of_month,
current_timestamp AS update_timestamp

from {{ ref('v_dim_dates_bi') }} v_dim_dates_bi
LEFT JOIN analytics.assets.int_equipment_assignments iea on v_dim_dates_bi.date >= iea.date_start::DATE AND 
    v_dim_dates_bi.date <= iea.date_end::DATE
LEFT JOIN es_warehouse.public.rentals r on r.rental_id = iea.rental_id
LEFT JOIN es_warehouse.public.orders o on o.order_id = r.order_id
LEFT JOIN es_warehouse.public.users u on u.user_id = o.user_id
LEFT JOIN es_warehouse.public.companies c on c.company_id = u.company_id
LEFT JOIN analytics.assets.int_asset_historical iah on iah.asset_id = iea.asset_id and
    iah.daily_timestamp::DATE = v_dim_dates_bi.date

WHERE iea.rental_duration >= 30 and 
    not iea.is_intercompany and 
    iah.in_rental_fleet

    order by date desc