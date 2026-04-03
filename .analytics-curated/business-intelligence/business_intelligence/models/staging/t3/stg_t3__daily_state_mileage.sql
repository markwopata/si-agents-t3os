{{ config(
   materialized='incremental',
   unique_key=['asset_id', 'report_day', 'name','start_tracking_event_id'],
   cluster_by=['asset_id', 'report_day'],
   on_schema_change='fail'
) }}

{% set lookback_days = var('lookback_days', 1460) %}
{% set processing_days = var('processing_days', 1460) %}

{% if is_incremental() %}
{% set affected_assets_query %}
select distinct te.asset_id
from {{ ref("platform","es_warehouse__public__tracking_events") }} te
left join (
    select asset_id, max(state_entry_raw) as max_processed_timestamp
    from {{ this }}
    group by asset_id
) existing on te.asset_id = existing.asset_id
where (te.report_timestamp > coalesce(existing.max_processed_timestamp, '1900-01-01'::timestamp_tz) or existing.max_processed_timestamp is null)
and te.report_timestamp >= (select coalesce(min(state_exit_raw), current_date - {{ processing_days }}) from {{ this }})
and te.trip_odo_miles is not null  
and te.trip_id is not null
{% endset %}
{% endif %}

with asset_list as (
   select asset_id, company_id
   from {{ ref("stg_t3__asset_info") }} 
),

base_tracking_data as (
    select 
        a.asset_id,
        al.company_id, 
        s.ifta_reporting,
        coalesce(age.start_tracking_event_id, age.asset_geofence_encounter_id) as start_tracking_event_id,
        te.report_timestamp,
        date(te.report_timestamp) as report_day,
        a.custom_name, 
        g.name as geofence_name, 
        a.model, 
        a.make, 
        a.vin,
        age.start_odometer as encounter_start_odometer, 
        age.end_odometer as encounter_end_odometer,
        te.location_lat, 
        te.location_lon, 
        t.start_odometer as trip_start_odometer, 
        t.end_odometer as trip_end_odometer,
        te.trip_odo_miles,
        te.trip_id,
        age.encounter_time_range:start_range::timestamp_tz as encounter_start_range
    from asset_list al
        join {{ ref("platform","es_warehouse__public__assets") }} a on a.asset_id = al.asset_id
        join {{ ref("platform","es_warehouse__public__asset_settings") }} s on s.asset_settings_id = a.asset_settings_id
        join {{ ref("platform","es_warehouse__public__tracking_events") }} te on te.asset_id = a.asset_id
        join {{ ref("platform","es_warehouse__public__trips") }} t on t.trip_id = te.trip_id and t.trip_type_id <> 3
        join {{ ref("platform","es_warehouse__public__asset_geofence_encounters") }} age on te.report_timestamp < coalesce(age.encounter_time_range:end_range::timestamp_tz, '9999-12-31 00:00:00'::timestamp_tz)
            and te.report_timestamp >= age.encounter_time_range:start_range::timestamp_tz 
            and te.asset_id = age.asset_id 
        join {{ ref("platform","es_warehouse__public__geofences") }} g on g.geofence_id = age.geofence_id and g.geofence_type_id = 2 and not coalesce(g.deleted, false)
    where te.trip_odo_miles is not null
        and te.trip_id is not null
        and not coalesce(a.deleted, false)
        and te.report_timestamp >= current_date - {{ processing_days }}
        {% if is_incremental() %}
        and a.asset_id in ({{ affected_assets_query }})
        and te.report_timestamp >= (
            select coalesce(min(state_exit_raw), current_date - {{ processing_days }})
            from {{ this }}
        )
        {% endif %}
),

miles_calculation as (
    select *,
        greatest(
            lead(trip_odo_miles, 1) ignore nulls over (
                partition by trip_id 
                order by report_timestamp, encounter_start_range
            ) - trip_odo_miles, 
            0
        ) as miles_increment
    from base_tracking_data
),

daily_aggregation as (
    select distinct 
        asset_id,
        company_id,
        ifta_reporting, 
        custom_name, 
        make, 
        model, 
        vin, 
        geofence_name as name,
        start_tracking_event_id,
        date(report_timestamp) as report_day,
        first_value(report_timestamp) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp) as state_entry,
        last_value(report_timestamp) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp rows between unbounded preceding and unbounded following) as state_exit,
        sum(miles_increment) over (partition by start_tracking_event_id, date(report_timestamp)) as miles_driven,
        first_value(trip_start_odometer) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp) as t_start_odometer,
        last_value(trip_end_odometer) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp rows between unbounded preceding and unbounded following) as t_end_odometer,
        first_value(encounter_start_odometer) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp) as start_odometer,
        last_value(encounter_end_odometer) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp rows between unbounded preceding and unbounded following) as end_odometer,
        first_value(location_lat) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp) as start_lat,
        first_value(location_lon) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp) as start_lon,
        last_value(location_lat) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp rows between unbounded preceding and unbounded following) as end_lat,
        last_value(location_lon) ignore nulls over (partition by start_tracking_event_id, date(report_timestamp) order by report_timestamp rows between unbounded preceding and unbounded following) as end_lon
    from miles_calculation
),

daily_aggregation_clean as (
    select *
    from daily_aggregation
    {% if is_incremental() %}
    where not (miles_driven = 0 and end_odometer is null)
    {% endif %}
),

formatted_output as (
    select 
        asset_id,
        company_id,
        ifta_reporting, 
        custom_name, 
        make, 
        model, 
        vin, 
        name,
        start_tracking_event_id,
        report_day,
        state_entry as state_entry_raw,
        state_exit as state_exit_raw,
        to_varchar(convert_timezone('America/Chicago', state_entry), 'mon-dd-yyyy HH12:mi:ss AM') as state_entry, 
        to_varchar(convert_timezone('America/Chicago', state_exit), 'mon-dd-yyyy HH12:mi:ss AM') as state_exit,
        case
            when row_number() over (partition by asset_id, report_day order by state_entry) = 1 
                 and max(state_entry) over (partition by asset_id, report_day) = state_entry 
                then to_varchar(t_start_odometer, '999,999,999,999.00')
            when row_number() over (partition by asset_id, report_day order by state_entry) = 1 
                then to_varchar(coalesce(end_odometer - miles_driven, 0), '999,999,999,999.00')
            else to_varchar(start_odometer, '999,999,999,999.00')
        end as start_odometer_formatted,
        case 
            when row_number() over (partition by asset_id, report_day order by state_entry) = 1 
                 and max(state_entry) over (partition by asset_id, report_day) = state_entry 
                then to_varchar(t_end_odometer, '999,999,999,999.00')
            when max(state_entry) over (partition by asset_id, report_day) = state_entry 
                then to_varchar(coalesce(start_odometer + miles_driven, 0), '999,999,999,999.00')
            else to_varchar(end_odometer, '999,999,999,999.00')
        end as end_odometer_formatted,
        miles_driven,
        start_lat, 
        start_lon, 
        end_lat, 
        end_lon
    from daily_aggregation_clean
)

select 
    asset_id, 
    company_id,
    ifta_reporting,
    custom_name, 
    make, 
    model, 
    vin,
    name,
    start_tracking_event_id,
    report_day,
    state_entry_raw,
    state_exit_raw,
    state_entry, 
    state_exit, 
    start_odometer_formatted as start_odometer, 
    end_odometer_formatted as end_odometer, 
    miles_driven, 
    start_lat, 
    start_lon, 
    end_lat, 
    end_lon 
from formatted_output

union all

select 
    al.asset_id,
    al.company_id,
    s.ifta_reporting,
    a.custom_name,
    a.make,
    a.model,
    a.vin,
    null as name,
    null as start_tracking_event_id,
    null as report_day,
    null as state_entry_raw,
    null as state_exit_raw,
    null as state_entry,
    null as state_exit,
    null as start_odometer, 
    null as end_odometer,
    0 as miles_driven,
    null as start_lat, 
    null as start_lon, 
    null as end_lat, 
    null as end_lon
from asset_list al
join {{ ref("platform","es_warehouse__public__assets") }} a on a.asset_id = al.asset_id
join {{ ref("platform","es_warehouse__public__asset_settings") }} s on s.asset_settings_id = a.asset_settings_id
where not exists (
    select 1 from formatted_output fo 
    where fo.asset_id = al.asset_id
)

order by custom_name