{{ config(
    materialized='incremental',
    unique_key=['distinct_id'],
    cluster_by=['asset_id','date_time']
) }}

/*
-- Initial load 
with
    driver_assignments as (
        select distinct
            asset_id,
            operator_name as driver_name_new,
            assignment_time,
            unassignment_time
        from business_intelligence.triage.stg_t3__operator_assignments
        where
            assignment_time >= dateadd('day', -365, current_date())
            and coalesce(unassignment_time, current_timestamp()) <= current_timestamp()
    ),
    pre as (
        select
            a.asset_id,
            a.company_id,
            a.custom_name as asset_name,
            a.driver_name as driver_name_legacy,
            t.trip_id,
            case
                when ti.tracking_incident_type_id = 5
                then coalesce(ai.start_timestamp, ai.end_timestamp)
                when ti.tracking_incident_type_id = 17
                then
                    coalesce(
                        ti.report_timestamp - interval '5 minutes', te.report_timestamp
                    )
                else coalesce(ti.report_timestamp, te.report_timestamp)
            end as date_time,
            case
                when ti.tracking_incident_type_id = 32
                then 'Over Speed Limit'
                when ti.tracking_incident_type_id = 33
                then 'Over Set Speed Threshold'
                when ti.tracking_incident_type_id = 5
                then 'Idling'
                else tiy.name
            end as tracking_incident_name,
            case
                when ti.tracking_incident_type_id = 5 then null else te.speed
            end as speed,
            case
                when ti.tracking_incident_type_id = 5
                then null
                else te.posted_speed_limit
            end as posted_speed_limit,
            case
                when ti.tracking_incident_type_id = 5 then null else ti.duration
            end as duration,
            case
                when ti.tracking_incident_type_id = 5
                then ai.asset_idle_id
                else ti.tracking_incident_id
            end as tracking_incident_id,
            case
                when ti.tracking_incident_type_id = 5
                then ai.end_idle_incident_id
                else te.tracking_event_id
            end as tracking_event_id,
            concat(
                coalesce(start_street, ''),
                ', ',
                coalesce(start_city, ''),
                ', ',
                coalesce(s1.abbreviation, '')
            ) as start_address,
            concat(
                coalesce(end_street, ''),
                ', ',
                coalesce(end_city, ''),
                ', ',
                coalesce(s2.abbreviation, '')
            ) as end_address,
            t.trip_distance_miles as total_trip_miles,
            t.trip_time_seconds as total_trip_seconds,
            t.start_lat,
            t.start_lon,
            t.end_lat,
            t.end_lon
        from {# { ref("platform", "es_warehouse__public__assets") } #} a
        join
            {# { ref("platform", "es_warehouse__public__tracking_events") } #} te
            on te.asset_id = a.asset_id
        left join
            {# { ref("platform", "es_warehouse__public__tracking_incidents") } #} ti
            on ti.tracking_event_id = te.tracking_event_id
        join
            {# { ref("platform", "es_warehouse__public__tracking_incident_types") } #} tiy
            on tiy.tracking_incident_type_id = ti.tracking_incident_type_id
            and ti.tracking_incident_type_id in (5, 12, 13, 14, 15, 16, 18, 19, 20, 32, 33)
        left join
            {# { ref("platform", "es_warehouse__public__asset_idles") } #} ai
            on ai.end_idle_incident_id = ti.tracking_incident_id
            and ti.tracking_incident_type_id = 5
        join
            {# { ref("platform", "es_warehouse__public__trips") } #} t
            on t.trip_id = te.trip_id
        left join
            {# { ref("platform", "es_warehouse__public__states") } #} s1
            on s1.state_id = t.start_state_id
        left join
            {# { ref("platform", "es_warehouse__public__states") } #} s2
            on s2.state_id = t.end_state_id

        where
            te.report_timestamp >= dateadd('day', -365, current_date())
            and te.report_timestamp <= current_timestamp()
    ),
    final_output as (
        select
            pre.asset_id,
            pre.company_id,
            pre.asset_name,
            pre.driver_name_legacy,
            da.driver_name_new,
            pre.trip_id,
            pre.date_time,
            pre.tracking_incident_name,
            pre.speed,
            pre.posted_speed_limit,
            pre.duration,
            pre.tracking_incident_id,
            pre.tracking_event_id,
            pre.start_address,
            pre.end_address,
            pre.total_trip_miles,
            pre.total_trip_seconds,
            pre.start_lat,
            pre.start_lon,
            pre.end_lat,
            pre.end_lon,
            ec.name as equipment_class,
            current_timestamp() as date_refresh_timestamp
        from pre
        left join
            {# { ref("platform", "es_warehouse__public__assets") } #} a
            on a.asset_id = pre.asset_id
        left join
            {# { ref("platform", "es_warehouse__public__equipment_classes") } #} ec
            on ec.equipment_class_id = a.equipment_class_id
        left join driver_assignments da on da.asset_id = a.asset_id
    )
select distinct
    md5(
        hash(
            asset_id,
            company_id,
            asset_name,
            driver_name_legacy,
            driver_name_new,
            trip_id,
            date_time,
            tracking_incident_name,
            speed,
            posted_speed_limit,
            duration,
            tracking_incident_id,
            tracking_event_id,
            start_address,
            end_address,
            total_trip_miles,
            total_trip_seconds,
            start_lat,
            start_lon,
            end_lat,
            end_lon,
            equipment_class
        )
    ) as distinct_id,
    *
from final_output
*/
 

-- Incremental load CTE
with pre as (
        select
            a.asset_id,
            a.company_id,
            a.custom_name as asset_name,
            a.driver_name as driver_name_legacy,
            t.trip_id,
            case
                when ti.tracking_incident_type_id = 5
                then coalesce(ai.start_timestamp, ai.end_timestamp)
                when ti.tracking_incident_type_id = 17
                then
                    coalesce(
                        ti.report_timestamp - interval '5 minutes', te.report_timestamp
                    )
                else coalesce(ti.report_timestamp, te.report_timestamp)
            end as date_time,
            case
                when ti.tracking_incident_type_id = 32
                then 'Over Speed Limit'
                when ti.tracking_incident_type_id = 33
                then 'Over Set Speed Threshold'
                when ti.tracking_incident_type_id = 5
                then 'Idling'
                else tiy.name
            end as tracking_incident_name,
            case
                when ti.tracking_incident_type_id = 5 then null else te.speed
            end as speed,
            case
                when ti.tracking_incident_type_id = 5 then null else ti.optional_fields:maxSpeed
            end as maxspeed,
            case
                when ti.tracking_incident_type_id = 5
                then null
                else te.posted_speed_limit
            end as posted_speed_limit,
            case
                when ti.tracking_incident_type_id = 5 then null else ti.duration
            end as duration,
            case
                when ti.tracking_incident_type_id = 5
                then ai.asset_idle_id
                else ti.tracking_incident_id
            end as tracking_incident_id,
            case
                when ti.tracking_incident_type_id = 5
                then ai.end_idle_incident_id
                else te.tracking_event_id
            end as tracking_event_id,
           ti.asset_incident_threshold_id,
           case 
           when 
           start_street is NULL AND start_city IS NULL and s1.abbreviation IS NULL then NULL
           when 
           start_street is NULL AND start_city IS NULL and s1.abbreviation IS NOT NULL then s1.abbreviation
           when 
           start_street is NULL AND start_city IS NOT NULL and s1.abbreviation IS NULL then start_city
           when 
           start_street is NULL AND start_city IS NOT NULL and s1.abbreviation IS NOT NULL then
            concat(
                coalesce(start_city, ''),
                ', ',
                coalesce(s1.abbreviation, '')
            ) 
           else
           concat(
                coalesce(start_street, ''),
                ', ',
                coalesce(start_city, ''),
                ', ',
                coalesce(s1.abbreviation, '')
            ) 
            end as start_address,
            concat(
                coalesce(end_street, ''),
                ', ',
                coalesce(end_city, ''),
                ', ',
                coalesce(s2.abbreviation, '')
            ) as end_address,
            t.trip_distance_miles as total_trip_miles,
            t.trip_time_seconds as total_trip_seconds,
            t.start_lat,
            t.start_lon,
            t.end_lat,
            t.end_lon,
            te.location_lat as speed_location_lat,
            te.location_lon as speed_location_lon
        from {{ ref("platform", "es_warehouse__public__assets") }} a
        join
            {{ ref("platform", "es_warehouse__public__tracking_incidents") }} ti
            on ti.asset_id = a.asset_id
        left join
            {{ ref("platform", "es_warehouse__public__tracking_events") }} te
            on te.tracking_event_id = ti.tracking_event_id
        join
            {{ ref("platform", "es_warehouse__public__tracking_incident_types") }} tiy
            on tiy.tracking_incident_type_id = ti.tracking_incident_type_id
            and ti.tracking_incident_type_id in (2, 5, 12, 13, 14, 15, 16, 18, 19, 20, 32, 33)
        left join
            {{ ref("platform", "es_warehouse__public__asset_idles") }} ai
            on ai.end_idle_incident_id = ti.tracking_incident_id
            and ti.tracking_incident_type_id = 5
        join
            {{ ref("platform", "es_warehouse__public__trips") }} t
            on t.trip_id = ti.trip_id
        left join
            {{ ref("platform", "es_warehouse__public__states") }} s1
            on s1.state_id = t.start_state_id
        left join
            {{ ref("platform", "es_warehouse__public__states") }} s2
            on s2.state_id = t.end_state_id
        {% if is_incremental() %}
        where
            te.report_timestamp >= (select max(date_refresh_timestamp) as max_refresh from {{ this }})
            and te.report_timestamp <= current_timestamp()
            and ti.report_timestamp >= (select max(date_refresh_timestamp) as max_refresh from {{ this }})
            and ti.report_timestamp <= current_timestamp()
        {% else %}
        where
            te.report_timestamp >= dateadd('day', -365, current_date())
            and te.report_timestamp <= current_timestamp()
            and ti.report_timestamp >= dateadd('day', -365, current_date())
            and ti.report_timestamp <= current_timestamp()
        {% endif %}
        {{ var('assets_table_slicer') }}
        {{ var('row_limit') }}
),
driver_assignments as (
        select distinct
            da.asset_id,
            da.operator_name as driver_name_new,
            da.assignment_time,
            da.unassignment_time
        from pre 
        join business_intelligence.triage.stg_t3__operator_assignments da on pre.asset_id = da.asset_id
        and pre.date_time >= da.assignment_time
        and pre.date_time <= coalesce(da.unassignment_time, current_timestamp())
),      
final_output as (
        select
            pre.asset_id,
            pre.company_id,
            pre.asset_name,
            pre.driver_name_legacy,
            da.driver_name_new,
            pre.trip_id,
            pre.date_time,
            pre.tracking_incident_name,
            pre.speed,
            pre.maxspeed,
            pre.posted_speed_limit,
            pre.duration,
            pre.tracking_incident_id,
            pre.tracking_event_id,
            pre.asset_incident_threshold_id,
            pre.start_address,
            pre.end_address,
            pre.total_trip_miles,
            pre.total_trip_seconds,
            pre.start_lat,
            pre.start_lon,
            pre.end_lat,
            pre.end_lon,
            pre.speed_location_lat,
            pre.speed_location_lon,
            ec.name as equipment_class,
            current_timestamp() as date_refresh_timestamp
        from pre
        left join
            {{ ref("platform", "es_warehouse__public__assets") }} a
            on a.asset_id = pre.asset_id
        left join
            {{ ref("platform", "es_warehouse__public__equipment_classes") }} ec
            on ec.equipment_class_id = a.equipment_class_id
        left join driver_assignments da on pre.asset_id = da.asset_id
        and pre.date_time >= da.assignment_time
        and pre.date_time <= coalesce(da.unassignment_time, current_timestamp())
        {{ var('row_limit') }}
    )
select distinct
    md5(
        hash(
            asset_id,
            company_id,
            asset_name,
            driver_name_legacy,
            driver_name_new,
            trip_id,
            date_time,
            tracking_incident_name,
            speed,
            maxspeed,
            posted_speed_limit,
            duration,
            tracking_incident_id,
            tracking_event_id,
            asset_incident_threshold_id,
            start_address,
            end_address,
            total_trip_miles,
            total_trip_seconds,
            start_lat,
            start_lon,
            end_lat,
            end_lon,
            speed_location_lat,
            speed_location_lon,
            equipment_class
        )
    ) as distinct_id,
    *
from final_output
{{ var('row_limit') }}