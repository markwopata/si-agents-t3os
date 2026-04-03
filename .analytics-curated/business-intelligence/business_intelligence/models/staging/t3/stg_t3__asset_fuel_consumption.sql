with asset_list as (
select
    a.asset_id,
    a.custom_name as asset,
    a.company_id, 
    at.name as asset_type,
    a.custom_name,
    cat.name as category_name, 
    m.name as market_name, 
    a.asset_class
from {{ref('platform', 'es_warehouse__public__assets')}} a 
join {{ref('platform', 'es_warehouse__public__asset_types')}} at on at.asset_type_id = a.asset_type_id
left join {{ref('platform', 'es_warehouse__public__categories')}} cat on cat.category_id = a.category_id
join {{ref('platform', 'es_warehouse__public__markets')}} m on  m.market_id = a.inventory_branch_id 
and m.company_id = a.company_id
),
asset_info as (
select
    alo.asset_id,
    alo.company_id, 
    alo.asset,
    alo.asset_type,
    alo.custom_name,
    alo.category_name, 
    alo.market_name, 
    alo.asset_class,
    1 as dummy_join_param,
    t.start_timestamp as start_timestamp,
    coalesce(t.end_timestamp,'2999-12-31') as end_timestamp,
    (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters) as liters_used,
    coalesce((t.end_total_idle_fuel_used_liters - t.start_total_idle_fuel_used_liters),0) as liters_idle
from asset_list alo
join {{ref('platform', 'es_warehouse__public__trips')}} t on t.asset_id = alo.asset_id
where ((t.end_total_fuel_used_liters - t.start_total_fuel_used_liters) > 0 OR (t.end_total_idle_fuel_used_liters - t.start_total_idle_fuel_used_liters) > 0)
),
phases as (
select
    o.company_id,
    o.job_id,
    r.asset_id,
    r.start_date,
    r.end_date,
    j.name as phase_job_name,
    j.job_id as phase_job_id,
    jp.name as job_name
from {{ref('platform', 'es_warehouse__public__orders')}} o
left join {{ref('platform', 'es_warehouse__public__rentals')}} r on (r.order_id = o.order_id)
join {{ref('platform', 'es_warehouse__public__jobs')}} j on (j.job_id = o.job_id) and j.parent_job_id is not null
left join {{ref('platform', 'es_warehouse__public__jobs')}}  jp on (j.parent_job_id = jp.job_id)
where
r.asset_id is not null
and r.deleted = false
and o.deleted = false
),
job_name_list as (
select
    o.company_id,
    o.job_id,
    r.asset_id,
    r.start_date,
    r.end_date,
    NULL as phase_job_name,
    NULL as phase_job_id,
    j.name as job_name

from  {{ref('platform', 'es_warehouse__public__orders')}} o
left join {{ref('platform', 'es_warehouse__public__rentals')}} r on (r.order_id = o.order_id)
join {{ref('platform', 'es_warehouse__public__jobs')}} j on (j.job_id = o.job_id) and j.parent_job_id is null
where
r.asset_id is not null
and r.deleted = false
and o.deleted = false
),
jobs_list as (
Select * from phases
UNION
Select * from job_name_list
),
hau_aggregated as (
  select
    asset_id,
    report_range:start_range::date as hau_start_date,
    report_range:end_range::date as hau_end_date,
    sum(on_time) as on_time,
    sum(idle_time) as idle_time,
    sum(miles_driven) as miles_driven
  from es_warehouse.public.hourly_asset_usage
  group by asset_id, report_range:start_range::date,report_range:end_range::date
),
pre_final as (
select
    oai.asset_id,
    oai.company_id, 
    oai.asset,
    oai.asset_type,
    oai.custom_name,
    oai.category_name, 
    oai.market_name, 
    oai.asset_class,
    
    oai.dummy_join_param,
    oai.start_timestamp::date as start_date,
    jl.job_id,
    jl.job_name,
    jl.phase_job_id,
    jl.phase_job_name,

    hau.hau_start_date,
    hau.hau_end_date,
    
    round(sum(oai.liters_used)*0.264172,2) as gallons_used_per_day,
    round(sum(oai.liters_idle)*0.264172,2) as idle_gallons_per_day,
    hau.on_time,
    hau.idle_time,
    hau.miles_driven
    
from asset_info oai
left join hau_aggregated hau 
  on oai.asset_id = hau.asset_id 
  and hau.hau_start_date = oai.start_timestamp::date
  and hau.hau_end_date = oai.start_timestamp::date
left join jobs_list jl 
    on jl.asset_id = oai.asset_id 
    and jl.start_date <= oai.start_timestamp::date 
    and jl.end_date >= oai.start_timestamp::date 
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,hau.on_time,hau.idle_time,hau.miles_driven
)
select
    pre.*, 
    case
        when pre.miles_driven < 0 then 'YES'
        when pre.gallons_used_per_day < 0 then 'YES'
        when pre.on_time < 0 then 'YES'
        when pre.idle_time < 0 then 'YES'
        when pre.idle_gallons_per_day < 0 then 'YES'
        when pre.idle_gallons_per_day > 20000 then 'YES'
    else 'NO' 
    end as suspect_trip_data_flag,
    case
      when pre.miles_driven < 0 then 'YES'
      when pre.gallons_used_per_day < 0 then 'YES'
      when pre.on_time < 0 then 'YES'
      when pre.idle_time < 0 then 'YES'
      when pre.idle_gallons_per_day < 0 then 'YES'
      when pre.idle_gallons_per_day > 20000 then 'YES'
    else 'NO'
      end as suspect_trip_table_flag
from pre_final as pre
