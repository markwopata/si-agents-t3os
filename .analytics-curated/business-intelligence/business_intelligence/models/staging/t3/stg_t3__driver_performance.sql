{{
    config(
        materialized='table',
        cluster_by=['company_id', 'date']
    )
}}

-- Driver Performance staging model
with incidents as (
    select
        tit.* exclude (driver_name_new,driver_name_legacy), coalesce(tit.driver_name_new, tit.driver_name_legacy) as driver_name,
        ait.* exclude (company_id, asset_id),
        case
            when tracking_incident_name = 'Over Speed' and maxspeed - speed >= 10 then tracking_incident_id
            when tracking_incident_name = 'Over Set Speed Threshold' and itd.exceeded_threshold_value - ait.exceeded_value_range:"upper_bound" >= 10 then tracking_incident_id
            when tracking_incident_name = 'Over Speed Limit' and itd.exceeded_threshold_value - itd.baseline_threshold_value >= 10 then tracking_incident_id
        end as ten_mph_over
    from business_intelligence.triage.stg_t3__tracking_incidents_triage tit
    left join es_warehouse.public.asset_incident_thresholds ait
        on ait.asset_incident_threshold_id = tit.asset_incident_threshold_id
        and ait.company_id = tit.company_id
    left join es_warehouse.public.asset_incident_threshold_durations itd
        on itd.asset_incident_threshold_id = ait.asset_incident_threshold_id
        and itd.asset_id = ait.asset_id
        and itd.asset_incident_threshold_id = tit.asset_incident_threshold_id
        and itd.asset_id = tit.asset_id
    where tracking_incident_name not in ('Idling', 'Ignition Off', 'Ignition On')
        and tit.company_id = 18415
),
company_scores as (
    select
        date_time::date as date_time,
        company_id,
        count(distinct tracking_incident_id) as company_total_violations,
        count(distinct case when tracking_incident_name in ('Aggressive Deceleration', 'Hard Cornering', 'Hard Left', 'Hard Right') then tracking_incident_id end) as company_severe_violations,
        count(distinct ten_mph_over) as company_ten_mph_over
    from incidents
    group by 1, 2
),
driver_weekly_totals as (
    select
        driver_name,
        company_id,
        concat(year(date_time), '-', lpad(week(date_time), 2, 0)) as year_week,
        count(distinct tracking_incident_id) as driver_weekly_total_violations
    from incidents
    group by 1, 2, 3
),
driver_monthly_totals as (
    select
        driver_name,
        company_id,
        concat(year(date_time), '-', lpad(month(date_time), 2, 0)) as year_month,
        count(distinct tracking_incident_id) as driver_monthly_total_violations
    from incidents
    group by 1, 2, 3
),
driver_weekly_usage as (
    select
        driver_name,
        rental_company_id,
        owner_company_id,
        concat(year(date), '-', lpad(week(date), 2, 0)) as year_week,
        sum(case when run_time_utc > 0 then 1 else 0 end) as days_used_weekly
    from business_intelligence.triage.stg_t3__by_day_utilization
    where rental_company_id = 18415 or owner_company_id = 18415
    group by 1, 2, 3, 4
),
driver_monthly_usage as (
    select
        driver_name,
        rental_company_id,
        owner_company_id,
        concat(year(date), '-', lpad(month(date), 2, 0)) as year_month,
        sum(case when run_time_utc > 0 then 1 else 0 end) as days_used_monthly
    from business_intelligence.triage.stg_t3__by_day_utilization
    where rental_company_id = 18415 or owner_company_id = 18415
    group by 1, 2, 3, 4
),
weekly_util_totals as (
    select
        driver_name,
        coalesce(owner_company_id,rental_company_id) as company_id,
        concat(year(date), '-', lpad(week(date), 2, 0)) as year_week,
        sum(run_time_utc) as weekly_run_time_utc_seconds,
        sum(miles_driven_utc) as weekly_miles_driven_utc
    from business_intelligence.triage.stg_t3__by_day_utilization
    where rental_company_id = 18415 or owner_company_id = 18415
    group by 1, 2, 3
)
,
monthly_util_totals as (
    select
        driver_name,
        coalesce(owner_company_id,rental_company_id) as company_id,
        concat(year(date), '-', lpad(month(date), 2, 0)) as year_month,
        sum(run_time_utc) as monthly_run_time_utc_seconds,
        sum(miles_driven_utc) as monthly_miles_driven_utc
    from business_intelligence.triage.stg_t3__by_day_utilization
    where rental_company_id = 18415 or owner_company_id = 18415
    group by 1, 2, 3
),
assignment_periods as (
    select
        b.asset_id,
        b.user_id,
        b.start_date,
        b.branch_id,
        coalesce(b.end_date, '2999-12-31') as end_date,
        trim(trim(u.first_name) || ' ' || trim(u.last_name)) as driver_name,
        listagg(o.name, '~ ') as groups
    from es_warehouse.public.branch_asset_assignments b
    join es_warehouse.public.users u on u.user_id = b.user_id
    left join es_warehouse.public.organization_asset_xref x on x.asset_id = b.asset_id
    left join es_warehouse.public.organizations o on o.organization_id = x.organization_id
    group by b.asset_id, b.user_id, b.start_date, b.branch_id, end_date, driver_name
),
driver_asset_assignments as (
    select
        ap.driver_name,
        ap.asset_id,
        ap.branch_id,
        max(util.rental_company_id) as rental_company_id,
        max(util.owner_company_id) as owner_company_id,
        ap.start_date as start_date,
        ap.end_date as end_date,
        ap.groups,
        count(distinct case when util.run_time_utc > 0 then util.date else null end) as total_days_used,
        count(distinct case when util.run_time_utc = 0 or util.run_time_utc is null then util.date else null end) as total_days_not_used
    from assignment_periods ap
    left join business_intelligence.triage.stg_t3__by_day_utilization util
        on util.asset_id = ap.asset_id
        and util.date >= ap.start_date
        and util.date <= ap.end_date
        and (util.rental_company_id = 18415 or util.owner_company_id = 18415)
    group by ap.driver_name, ap.asset_id, ap.branch_id, ap.start_date, ap.end_date, ap.groups
    having (max(util.rental_company_id) = 18415 or max(util.owner_company_id) = 18415)
)
, fleetcam as (
    select 
      fe.event_date as date_time
    , fet.event_type_name as tracking_incident_name
    , fe.event_type_id as tracking_incident_id
    , a.asset_id
    , daa.driver_name
    , NULL as ten_mph_over
    , a.company_id as company_id
    , 'Fleet Cam' as incident_source
        from  analytics.bi_ops.fleetcam_events fe
        left join analytics.bi_ops.fleetcam_event_types fet on fet.event_type_id = fe.event_type_id
        left join analytics.bi_ops.fleetcam_vehicles fv on fv.vehicle_id = fe.vehicle_id
        left join analytics.fleetcam.asset_fleetcam_xwalk afx on afx.fleetcam_vehicle_id = fv.vehicle_id
        left join es_warehouse.public.assets a on a.asset_id = afx.es_asset_id
        left join driver_asset_assignments daa on daa.asset_id = a.asset_id and fe.event_date >= daa.start_date and fe.event_date <= daa.end_date
        --left join business_intelligence.triage.stg_t3__stg_t3_companyn u on u.asset_id = a.asset_id and fe.event_date::date = u.date
    where (a.company_id = 18415 or a.company_id is null)
)
, tracking_pre as (
    select
    u.date,
    year(u.date) as year,
    lpad(month(u.date), 2, 0) as month,
    lpad(week(u.date), 2, 0) as week_num,
    concat(year(u.date), '-', lpad(month(u.date), 2, 0)) as year_month,
    concat(year(u.date), '-', lpad(week(u.date), 2, 0)) as year_week,
    u.driver_name,
    coalesce(u.owner_company_id,u.rental_company_id) as company_id,
    wst.driver_weekly_total_violations,
    mst.driver_monthly_total_violations,
    wut.weekly_run_time_utc_seconds,
    wut.weekly_miles_driven_utc,
    mut.monthly_run_time_utc_seconds,
    mut.monthly_miles_driven_utc,
    u.asset_id,
    custom_name as asset_name,
    'Vehicle Tracker' as incident_source,
    coalesce(m.name, 'Testing Branch') as branch,
    sum(u.run_time_utc) as run_time_utc_seconds,
    sum(u.miles_driven_utc) as miles_driven_utc,
    count(distinct case when i.tracking_incident_name in ('Over Speed', 'Over Set Speed Threshold', 'Over Speed Limit') then i.tracking_incident_id end) as speeding_violations,
    count(distinct case when i.tracking_incident_name in ('Hard Cornering', 'Hard Left', 'Hard Right') then i.tracking_incident_id end) as cornering_violations,
    count(distinct case when i.tracking_incident_name in ('Aggressive Deceleration', 'Aggressive Acceleration') then i.tracking_incident_id end) as acceleration_decceleration_violations,
    count(distinct case when i.tracking_incident_name in ('Impact') then i.tracking_incident_id end) as impact_violations,
    count(distinct i.tracking_incident_id) as total_violations,
    count(distinct case when i.tracking_incident_name in ('Aggressive Deceleration', 'Impact', 'Over Speed Limit', 'Over Set Speed Threshold', 'Over Speed') then i.tracking_incident_id end) as severe_violations,
    count(distinct i.ten_mph_over) as ten_mph_over,
    daa.start_date,
    daa.end_date,
    daa.groups,
    daa.total_days_used,
    daa.total_days_not_used,
    datediff(day, daa.start_date, case when daa.end_date = '2999-12-31' then current_date() else daa.end_date end) as assignment_duration_days,
    case when weekly_miles_driven_utc = 0 then 0 else driver_weekly_total_violations / weekly_run_time_utc_seconds * 3600 end as weekly_violations_per_hour,
    case when weekly_miles_driven_utc = 0 then 0 else driver_weekly_total_violations / weekly_miles_driven_utc end as weekly_violations_per_mile,
    case when monthly_run_time_utc_seconds = 0 then 0 else driver_monthly_total_violations / monthly_run_time_utc_seconds * 3600 end as monthly_violations_per_hour,
    case when monthly_miles_driven_utc = 0 then 0 else driver_monthly_total_violations / monthly_miles_driven_utc end as monthly_violations_per_mile,
    4 as free_violations_per_week,
    20 as free_violations_per_month,
    case
        when (weekly_run_time_utc_seconds > 0 or weekly_miles_driven_utc > 0) and driver_weekly_total_violations is null then 100 
        when weekly_run_time_utc_seconds = 0 or weekly_run_time_utc_seconds is null then null
        when (weekly_violations_per_hour >= 7 or weekly_violations_per_mile >= 7) then greatest(0, 40 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 5 or weekly_violations_per_mile >= 5) then greatest(0, 50 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 3 or weekly_violations_per_mile >= 3) then greatest(0, 80 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 0 or weekly_violations_per_mile >= 0) then greatest(0, 100 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        else 250
        -- greatest(0, 100 - (weekly_violations_per_hour * 10 / sqrt(weekly_run_time_utc_seconds)))
    end as weekly_score,
    case
        when (monthly_run_time_utc_seconds > 0 or monthly_miles_driven_utc > 0) and driver_monthly_total_violations is null then 100 
        when monthly_run_time_utc_seconds = 0 or monthly_run_time_utc_seconds is null then null
        when (monthly_violations_per_hour >= 4 or monthly_violations_per_mile >= 4) then greatest(0, 40 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 3 or monthly_violations_per_mile >= 3) then greatest(0, 60 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 2 or monthly_violations_per_mile >= 2) then greatest(0, 70 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 1 or monthly_violations_per_mile >= 1) then greatest(0, 80 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 0 or monthly_violations_per_mile >= 0) then greatest(0, 100 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        else 250
        -- greatest(0, 100 - (monthly_violations_per_hour * 10 / sqrt(monthly_run_time_utc_seconds)))
    end as monthly_score,
    case when weekly_score + monthly_score = 0 then 0 else (weekly_score + monthly_score) / 2 end as safety_score_percent
from business_intelligence.triage.stg_t3__by_day_utilization u
left join incidents i
    on i.asset_id = u.asset_id
    and i.date_time::date = u.date
    and trim(upper(coalesce(i.driver_name, ''))) = trim(upper(coalesce(u.driver_name, '')))
    and (i.company_id = u.rental_company_id or i.company_id = u.owner_company_id)
left join company_scores cs
    on cs.company_id = coalesce(u.rental_company_id, u.owner_company_id)
    and cs.date_time::date = u.date
left join driver_asset_assignments daa
    on daa.asset_id = u.asset_id
    and u.date >= daa.start_date
    and u.date <= daa.end_date
    and (daa.rental_company_id = u.rental_company_id or daa.owner_company_id = u.owner_company_id)
left join es_warehouse.public.markets m
    on m.market_id = daa.branch_id
    and u.date >= daa.start_date
    and u.date <= coalesce(daa.end_date, '2999-12-31')
left join driver_weekly_totals wst
    on wst.driver_name = u.driver_name
    and (wst.company_id = u.rental_company_id or wst.company_id = u.owner_company_id)
    and wst.year_week = concat(year(u.date), '-', lpad(week(u.date), 2, 0))
left join driver_monthly_totals mst
    on mst.driver_name = u.driver_name
    and (mst.company_id = u.rental_company_id or mst.company_id = u.owner_company_id)
    and mst.year_month = concat(year(u.date), '-', lpad(month(u.date), 2, 0))
left join weekly_util_totals wut
    on wut.driver_name = u.driver_name
    and (wut.company_id = u.rental_company_id or wut.company_id = u.owner_company_id)
    and wut.year_week = concat(year(u.date), '-', lpad(week(u.date), 2, 0))
left join monthly_util_totals mut
    on mut.driver_name = u.driver_name
    and (mut.company_id = u.rental_company_id or mut.company_id = u.owner_company_id)
    and mut.year_month = concat(year(u.date), '-', lpad(month(u.date), 2, 0))
where (u.rental_company_id = 18415 or u.owner_company_id = 18415)
    -- Testing filters
    and u.date >= dateadd(year, -1, current_date())
    and u.driver_name is not null
     -- Testing filters
group by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    cs.company_total_violations,
    daa.start_date,
    daa.end_date,
    daa.groups,
    daa.total_days_used,
    daa.total_days_not_used
)
, fleetcam_pre as (
      select
    u.date,
    year(u.date) as year,
    lpad(month(u.date), 2, 0) as month,
    lpad(week(u.date), 2, 0) as week_num,
    concat(year(u.date), '-', lpad(month(u.date), 2, 0)) as year_month,
    concat(year(u.date), '-', lpad(week(u.date), 2, 0)) as year_week,
    u.driver_name,
    coalesce(u.owner_company_id,u.rental_company_id) as company_id,
    wst.driver_weekly_total_violations,
    mst.driver_monthly_total_violations,
    wut.weekly_run_time_utc_seconds,
    wut.weekly_miles_driven_utc,
    mut.monthly_run_time_utc_seconds,
    mut.monthly_miles_driven_utc,
    u.asset_id,
    custom_name as asset_name,
    i.incident_source as incident_source,
    coalesce(m.name, 'Testing Branch') as branch,
    sum(u.run_time_utc) as run_time_utc_seconds,
    sum(u.miles_driven_utc) as miles_driven_utc,
    count(distinct case when i.tracking_incident_name in ('Over Speed', 'Over Set Speed Threshold', 'Over Speed Limit') then i.tracking_incident_id end) as speeding_violations,
    count(distinct case when i.tracking_incident_name in ('Hard Cornering', 'Hard Left', 'Hard Right') then i.tracking_incident_id end) as cornering_violations,
    count(distinct case when i.tracking_incident_name in ('Aggressive Deceleration', 'Aggressive Acceleration') then i.tracking_incident_id end) as acceleration_decceleration_violations,
    count(distinct case when i.tracking_incident_name in ('Impact') then i.tracking_incident_id end) as impact_violations,
    count(distinct i.tracking_incident_id) as total_violations,
    count(distinct case when i.tracking_incident_name in ('Aggressive Deceleration', 'Impact', 'Over Speed Limit', 'Over Set Speed Threshold', 'Over Speed') then i.tracking_incident_id end) as severe_violations,
    count(distinct i.ten_mph_over) as ten_mph_over,
    daa.start_date,
    daa.end_date,
    daa.groups,
    daa.total_days_used,
    daa.total_days_not_used,
    datediff(day, daa.start_date, case when daa.end_date = '2999-12-31' then current_date() else daa.end_date end) as assignment_duration_days,
    case when weekly_miles_driven_utc = 0 then 0 else driver_weekly_total_violations / weekly_run_time_utc_seconds * 3600 end as weekly_violations_per_hour,
    case when weekly_miles_driven_utc = 0 then 0 else driver_weekly_total_violations / weekly_miles_driven_utc end as weekly_violations_per_mile,
    case when monthly_run_time_utc_seconds = 0 then 0 else driver_monthly_total_violations / monthly_run_time_utc_seconds * 3600 end as monthly_violations_per_hour,
    case when monthly_miles_driven_utc = 0 then 0 else driver_monthly_total_violations / monthly_miles_driven_utc end as monthly_violations_per_mile,
    4 as free_violations_per_week,
    20 as free_violations_per_month,
    case
        when (weekly_run_time_utc_seconds > 0 or weekly_miles_driven_utc > 0) and driver_weekly_total_violations is null then 100 
        when weekly_run_time_utc_seconds = 0 or weekly_run_time_utc_seconds is null then null
        when (weekly_violations_per_hour >= 7 or weekly_violations_per_mile >= 7) then greatest(0, 40 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 5 or weekly_violations_per_mile >= 5) then greatest(0, 50 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 3 or weekly_violations_per_mile >= 3) then greatest(0, 80 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        when (weekly_violations_per_hour >= 0 or weekly_violations_per_mile >= 0) then greatest(0, 100 - (greatest(0, driver_weekly_total_violations - free_violations_per_week) * 3))
        else 250
        -- greatest(0, 100 - (weekly_violations_per_hour * 10 / sqrt(weekly_run_time_utc_seconds)))
    end as weekly_score,
    case
        when (monthly_run_time_utc_seconds > 0 or monthly_miles_driven_utc > 0) and driver_monthly_total_violations is null then 100 
        when monthly_run_time_utc_seconds = 0 or monthly_run_time_utc_seconds is null then null
        when (monthly_violations_per_hour >= 4 or monthly_violations_per_mile >= 4) then greatest(0, 40 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 3 or monthly_violations_per_mile >= 3) then greatest(0, 60 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 2 or monthly_violations_per_mile >= 2) then greatest(0, 70 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 1 or monthly_violations_per_mile >= 1) then greatest(0, 80 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        when (monthly_violations_per_hour >= 0 or monthly_violations_per_mile >= 0) then greatest(0, 100 - (greatest(0, driver_monthly_total_violations - free_violations_per_month) * 3))
        else 250
        -- greatest(0, 100 - (monthly_violations_per_hour * 10 / sqrt(monthly_run_time_utc_seconds)))
    end as monthly_score,
    case when weekly_score + monthly_score = 0 then 0 else (weekly_score + monthly_score) / 2 end as safety_score_percent
from business_intelligence.triage.stg_t3__by_day_utilization u
left join fleetcam i
    on i.asset_id = u.asset_id
    and i.date_time::date = u.date
    and trim(upper(coalesce(i.driver_name, ''))) = trim(upper(coalesce(u.driver_name, '')))
    and (i.company_id = u.rental_company_id or i.company_id = u.owner_company_id)
left join company_scores cs
    on cs.company_id = coalesce(u.rental_company_id, u.owner_company_id)
    and cs.date_time::date = u.date
left join driver_asset_assignments daa
    on daa.asset_id = u.asset_id
    and u.date >= daa.start_date
    and u.date <= daa.end_date
    and (daa.rental_company_id = u.rental_company_id or daa.owner_company_id = u.owner_company_id)
left join es_warehouse.public.markets m
    on m.market_id = daa.branch_id
    and u.date >= daa.start_date
    and u.date <= coalesce(daa.end_date, '2999-12-31')
left join driver_weekly_totals wst
    on wst.driver_name = u.driver_name
    and (wst.company_id = u.rental_company_id or wst.company_id = u.owner_company_id)
    and wst.year_week = concat(year(u.date), '-', lpad(week(u.date), 2, 0))
left join driver_monthly_totals mst
    on mst.driver_name = u.driver_name
    and (mst.company_id = u.rental_company_id or mst.company_id = u.owner_company_id)
    and mst.year_month = concat(year(u.date), '-', lpad(month(u.date), 2, 0))
left join weekly_util_totals wut
    on wut.driver_name = u.driver_name
    and (wut.company_id = u.rental_company_id or wut.company_id = u.owner_company_id)
    and wut.year_week = concat(year(u.date), '-', lpad(week(u.date), 2, 0))
left join monthly_util_totals mut
    on mut.driver_name = u.driver_name
    and (mut.company_id = u.rental_company_id or mut.company_id = u.owner_company_id)
    and mut.year_month = concat(year(u.date), '-', lpad(month(u.date), 2, 0))
where (u.rental_company_id = 18415 or u.owner_company_id = 18415)
    -- Testing filters
    and u.date >= dateadd(year, -1, current_date())
    and u.driver_name is not null
     -- Testing filters
group by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    cs.company_total_violations,
    daa.start_date,
    daa.end_date,
    daa.groups,
    daa.total_days_used,
    daa.total_days_not_used
    )
   SELECT * from tracking_pre WHERE run_time_utc_seconds > 0
   UNION
   SELECT * FROM fleetcam_pre 