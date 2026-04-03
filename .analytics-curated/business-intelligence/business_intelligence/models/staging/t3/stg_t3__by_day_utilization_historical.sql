{{
    config(
        materialized="table",
        cluster_by=["date", "owner_company_id", "rental_company_id"],
    )
}}

with
    date_series_raw as (
        select dt_date as day, dayname(dt_date) as day_name
        from {{ ref("platform", "dim_dates") }}
        where
            dt_date >= '2021-01-01' and dt_date <= current_date()
    ),
    date_filterd_hau as (
        select
            report_range:start_range as start_range,
            report_range:end_range as end_range,
            *
        from {{ ref("platform", "es_warehouse__public__hourly_asset_usage") }} hau
        where start_range >= '2021-01-01' {{ var("row_limit") }}
    ),
    distinct_asset_ids as (
        select distinct asset_id from date_filterd_hau {{ var("row_limit") }}
    ),
    -- , date_series as (
    -- select * from
    -- date_series_raw
    -- cross join distinct_asset_ids
    -- -- order by asset_id desc, day desc
    -- )
    date_series as (
        select distinct
            dai.asset_id,
            dsr.day,
            dsr.day_name,
            coalesce(rental_company_id, 0) as rental_company_id,
            cv.owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name
         --   coalesce(cv.jobsite, 'None') as jobsite
        from date_series_raw dsr
        cross join distinct_asset_ids dai
        join
            business_intelligence.triage.stg_t3__company_values cv
            on dai.asset_id = cv.asset_id
            and dsr.day >= cv.start_date::date
            and dsr.day <= cv.end_date::date
    ),
    last_locations as (
        select al.asset_id, al.end_date, al.geofences, al.address, al.location
        from {{ ref("platform", "es_warehouse__snapshot__asset_last_location") }} al
        join
            (
                select asset_id, end_date::date, max(end_date) as max_end_date
                from
                    {{ ref("platform", "es_warehouse__snapshot__asset_last_location") }}
                group by asset_id, end_date::date
            ) as max_dates
            on al.asset_id = max_dates.asset_id
            and al.end_date = max_dates.max_end_date
        where start_date >= '2021-01-01'
        union
        select
            al.asset_id,
            current_timestamp as end_date,
            al.geofences,
            al.address,
            al.location
        from
            {{ ref("platform", "es_warehouse__public__asset_last_location") }} al
            {{ var("row_limit") }}
    ),
    odometer_daily as (
        select
            ds.day as date,
            odo.asset_id,
            odo.odometer,
            row_number() over (
                partition by odo.asset_id, ds.day order by ds.day desc
            ) as last_for_day
        from date_series ds
        left join
            {{ ref("platform", "es_warehouse__scd__scd_asset_odometer") }} odo
            on ds.day >= odo.date_start
            and ds.day <= odo.date_end
            and ds.asset_id = odo.asset_id
        where odo.date_start >= '2021-01-01'
        qualify last_for_day = 1
    ),
    hours_daily as (
        select
            ds.day as date,
            hrs.asset_id,
            hrs.hours,
            row_number() over (
                partition by hrs.asset_id, ds.day order by ds.day desc
            ) as last_for_day
        from date_series ds
        left join
            {{ ref("platform", "es_warehouse__scd__scd_asset_hours") }} hrs
            on ds.day >= hrs.date_start
            and ds.day <= hrs.date_end  -- TODO
            and ds.asset_id = hrs.asset_id
        where hrs.date_start >= '2021-01-01'
        qualify last_for_day = 1
    ),
    max_trip_start_times as (
        select distinct t.asset_id, max(t.start_timestamp) as max_start
        from {{ ref("platform", "es_warehouse__public__trips") }} t
        where
            t.start_timestamp >= '2021-01-01'
            and asset_id is not null
        group by t.asset_id
    ),
    orphaned_trips as (
        select distinct
            t.trip_id,
            row_number() over (
                partition by t.asset_id order by start_timestamp desc
            ) as row_num
        from {{ ref("platform", "es_warehouse__public__trips") }} t
        join
            max_trip_start_times ms
            on ms.asset_id
            and t.asset_id
            and t.start_timestamp != ms.max_start
        where
            t.start_timestamp >= '2021-01-01'
            and t.end_timestamp is null
            and t.asset_id in (
                select distinct asset_id
                from {{ ref("platform", "es_warehouse__public__trips") }}
                where end_timestamp is null
                group by asset_id
                having count(*) > 1
            )
        qualify row_num != 1  -- this is a change
    ),
    cleaned_trips as (
        select *
        from {{ ref("platform", "es_warehouse__public__trips") }} t
        where
            t.start_timestamp >= '2021-01-01'
            and t.trip_id not in (select distinct trip_id from orphaned_trips)
    ),
    in_progress_trips as (
        select distinct
            -- al.asset_id,
            ds.day::date as date,
            t.asset_id,
            coalesce(cv.rental_company_id, 0) as rental_company_id,
            coalesce(cv.owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
           -- coalesce(cv.jobsite, 'None') as jobsite,
            case
                when ds.day::date = current_date()
                then
                    timestampdiff(
                        second, trunc(current_timestamp(), 'DAY'), current_timestamp()
                    )
                when ds.day::date = t.start_timestamp::date
                then datediff(seconds, ds.day, t.start_timestamp)
                when ds.day::date > t.start_timestamp::date or ds.day < t.end_timestamp
                then 86400
            end as in_progress_on_time_utc,
            case
                when ds.day::date = current_date()
                then
                    timestampdiff(
                        second,
                        trunc(
                            convert_timezone('UTC', 'EST', current_timestamp()), 'DAY'
                        ),
                        convert_timezone('UTC', 'EST', current_timestamp())
                    )
                when
                    ds.day::date
                    = convert_timezone('UTC', 'EST', t.start_timestamp::datetime)::date
                then
                    datediff(
                        seconds,
                        ds.day,
                        convert_timezone('UTC', 'EST', t.start_timestamp::datetime)
                    )
                when
                    ds.day::date
                    > convert_timezone('UTC', 'EST', t.start_timestamp::datetime)::date
                    or ds.day
                    < convert_timezone('UTC', 'EST', t.end_timestamp::datetime)
                then 86400
                else 0
            end as in_progress_on_time_est,
            case
                when ds.day::date = current_date()
                then
                    timestampdiff(
                        second,
                        trunc(
                            convert_timezone(
                                'UTC', 'America/Chicago', current_timestamp()
                            ),
                            'DAY'
                        ),
                        convert_timezone('UTC', 'America/Chicago', current_timestamp())
                    )
                when
                    ds.day::date = convert_timezone(
                        'UTC', 'America/Chicago', t.start_timestamp::datetime
                    )::date
                then
                    datediff(
                        seconds,
                        ds.day,
                        convert_timezone(
                            'UTC', 'America/Chicago', t.start_timestamp::datetime
                        )
                    )
                when
                    ds.day::date > convert_timezone(
                        'UTC', 'America/Chicago', t.start_timestamp::datetime
                    )::date
                    or ds.day < convert_timezone(
                        'UTC', 'America/Chicago', t.end_timestamp::datetime
                    )
                then 86400
            end as in_progress_on_time_cst,
            case
                when ds.day::date = current_date()
                then
                    timestampdiff(
                        second,
                        trunc(
                            convert_timezone(
                                'UTC', 'America/Denver', current_timestamp()
                            ),
                            'DAY'
                        ),
                        convert_timezone('UTC', 'America/Denver', current_timestamp())
                    )
                when
                    ds.day::date = convert_timezone(
                        'UTC', 'America/Denver', t.start_timestamp::datetime
                    )::date
                then
                    datediff(
                        seconds,
                        ds.day,
                        convert_timezone(
                            'UTC', 'America/Denver', t.start_timestamp::datetime
                        )
                    )
                when
                    ds.day::date > convert_timezone(
                        'UTC', 'America/Denver', t.start_timestamp::datetime
                    )::date
                    or ds.day < convert_timezone(
                        'UTC', 'America/Denver', t.end_timestamp::datetime
                    )
                then 86400
            end as in_progress_on_time_mnt,
            case
                when ds.day::date = current_date()
                then
                    timestampdiff(
                        second,
                        trunc(
                            convert_timezone(
                                'UTC', 'America/Los_Angeles', current_timestamp()
                            ),
                            'DAY'
                        ),
                        convert_timezone(
                            'UTC', 'America/Los_Angeles', current_timestamp()
                        )
                    )
                when
                    ds.day::date = convert_timezone(
                        'UTC', 'America/Los_Angeles', t.start_timestamp::datetime
                    )::date
                then
                    datediff(
                        seconds,
                        ds.day,
                        convert_timezone(
                            'UTC', 'America/Los_Angeles', t.start_timestamp::datetime
                        )
                    )
                when
                    ds.day::date > convert_timezone(
                        'UTC', 'America/Los_Angeles', t.start_timestamp::datetime
                    )::date
                    or ds.day < convert_timezone(
                        'UTC', 'America/Los_Angeles', t.end_timestamp::datetime
                    )
                then 86400
            end as in_progress_on_time_wst
        from date_series ds
        left join
            cleaned_trips t
            on ds.day between t.start_timestamp and current_timestamp()
            and t.end_timestamp is null
            and t.asset_id = ds.asset_id
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = ds.asset_id
            and ds.day >= cv.start_date
            and ds.day <= cv.end_date
        -- and t.trip_time_seconds is null
        where
            t.end_timestamp is null and t.trip_type_id = 1 and t.asset_id is not null
            {{ var("row_limit") }}
    ),
    utc_time as (
        select distinct
            start_range::date as date,
            hau.asset_id,
            coalesce(rental_company_id, 0) as rental_company_id,
            coalesce(owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
          --  coalesce(cv.jobsite, 'None') as jobsite,
            sum(on_time) as on_time_utc,
            sum(on_time) - sum(idle_time) as run_time_utc,
            sum(idle_time) as idle_time_utc,
            sum(miles_driven) as miles_driven_utc,
            sum(hauled_time) as hauled_time_utc,
            sum(hauling_time) as hauling_time_utc,
            sum(hauling_distance) as hauling_distance_utc,
            sum(hauled_distance) as hauled_distance_utc
        from date_filterd_hau hau
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = hau.asset_id
            and start_range >= cv.start_date
            and end_range <= cv.end_date
        group by
            start_range::date,
            hau.asset_id,
            coalesce(rental_company_id, 0),
            coalesce(owner_company_id, 0),
            coalesce(cv.job_id, 0),
            coalesce(cv.job_name, 'None'),
            coalesce(cv.phase_job_id, 0),
            coalesce(cv.phase_job_name, 'None')
         --   coalesce(cv.jobsite, 'None')
    ),
    est_time as (
        select distinct
            convert_timezone('UTC', 'EST', start_range::timestamp_ntz)::date as date,
            hau.asset_id,
            coalesce(rental_company_id, 0) as rental_company_id,
            coalesce(owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
        --    coalesce(cv.jobsite, 'None') as jobsite,
            sum(on_time) as on_time_est,
            sum(on_time) - sum(idle_time) as run_time_est,
            sum(idle_time) as idle_time_est,
            sum(miles_driven) as miles_driven_est,
            sum(hauled_time) as hauled_time_est,
            sum(hauling_time) as hauling_time_est,
            sum(hauling_distance) as hauling_distance_est,
            sum(hauled_distance) as hauled_distance_est
        from date_filterd_hau hau
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = hau.asset_id
            and start_range >= cv.start_date
            and end_range <= cv.end_date
        group by
            convert_timezone('UTC', 'EST', start_range::timestamp_ntz)::date,
            hau.asset_id,
            coalesce(rental_company_id, 0),
            coalesce(owner_company_id, 0),
            coalesce(cv.job_id, 0),
            coalesce(cv.job_name, 'None'),
            coalesce(cv.phase_job_id, 0),
            coalesce(cv.phase_job_name, 'None')
         --   coalesce(cv.jobsite, 'None')
    ),
    cst_time as (
        select distinct
            convert_timezone('UTC', 'America/Chicago', start_range::timestamp_ntz)::date
            as date,
            hau.asset_id,
            coalesce(rental_company_id, 0) as rental_company_id,
            coalesce(owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
        --    coalesce(cv.jobsite, 'None') as jobsite,
            sum(on_time) as on_time_cst,
            sum(on_time) - sum(idle_time) as run_time_cst,
            sum(idle_time) as idle_time_cst,
            sum(miles_driven) as miles_driven_cst,
            sum(hauled_time) as hauled_time_cst,
            sum(hauling_time) as hauling_time_cst,
            sum(hauling_distance) as hauling_distance_cst,
            sum(hauled_distance) as hauled_distance_cst
        from date_filterd_hau hau
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = hau.asset_id
            and start_range >= cv.start_date
            and end_range <= cv.end_date
        group by
            convert_timezone('UTC', 'America/Chicago', start_range::timestamp_ntz)::date
            ,
            hau.asset_id,
            coalesce(rental_company_id, 0),
            coalesce(owner_company_id, 0),
            coalesce(cv.job_id, 0),
            coalesce(cv.job_name, 'None'),
            coalesce(cv.phase_job_id, 0),
            coalesce(cv.phase_job_name, 'None')
          --  coalesce(cv.jobsite, 'None')
            {{ var("row_limit") }}
    ),
    mnt_time as (
        select distinct
            convert_timezone('UTC', 'America/Denver', start_range::timestamp_ntz)::date
            as date,
            hau.asset_id,
            coalesce(rental_company_id, 0) as rental_company_id,
            coalesce(owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
         --  coalesce(cv.jobsite, 'None') as jobsite,
            sum(on_time) as on_time_mnt,
            sum(on_time) - sum(idle_time) as run_time_mnt,
            sum(idle_time) as idle_time_mnt,
            sum(miles_driven) as miles_driven_mnt,
            sum(hauled_time) as hauled_time_mnt,
            sum(hauling_time) as hauling_time_mnt,
            sum(hauling_distance) as hauling_distance_mnt,
            sum(hauled_distance) as hauled_distance_mnt
        from date_filterd_hau hau
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = hau.asset_id
            and start_range >= cv.start_date
            and end_range <= cv.end_date
        group by
            convert_timezone('UTC', 'America/Denver', start_range::timestamp_ntz)::date,
            hau.asset_id,
            coalesce(rental_company_id, 0),
            coalesce(owner_company_id, 0),
            coalesce(cv.job_id, 0),
            coalesce(cv.job_name, 'None'),
            coalesce(cv.phase_job_id, 0),
            coalesce(cv.phase_job_name, 'None')
        --    coalesce(cv.jobsite, 'None')
            {{ var("row_limit") }}
    ),
    wst_time as (
        select distinct
            convert_timezone(
                'UTC', 'America/Los_Angeles', start_range::timestamp_ntz
            )::date as date,
            hau.asset_id,
            coalesce(rental_company_id, 0) as rental_company_id,
            coalesce(owner_company_id, 0) as owner_company_id,
            coalesce(cv.job_id, 0) as job_id,
            coalesce(cv.job_name, 'None') as job_name,
            coalesce(cv.phase_job_id, 0) as phase_job_id,
            coalesce(cv.phase_job_name, 'None') as phase_job_name,
         --   coalesce(cv.jobsite, 'None') as jobsite,
            sum(on_time) as on_time_wst,
            sum(on_time) - sum(idle_time) as run_time_wst,
            sum(idle_time) as idle_time_wst,
            sum(miles_driven) as miles_driven_wst,
            sum(hauled_time) as hauled_time_wst,
            sum(hauling_time) as hauling_time_wst,
            sum(hauling_distance) as hauling_distance_wst,
            sum(hauled_distance) as hauled_distance_wst
        from date_filterd_hau hau
        left join
            {{ ref("stg_t3__company_values") }} cv
            on cv.asset_id = hau.asset_id
            and start_range >= cv.start_date
            and end_range <= cv.end_date
        group by
            convert_timezone(
                'UTC', 'America/Los_Angeles', start_range::timestamp_ntz
            )::date,
            hau.asset_id,
            coalesce(rental_company_id, 0),
            coalesce(owner_company_id, 0),
            coalesce(cv.job_id, 0),
            coalesce(cv.job_name, 'None'),
            coalesce(cv.phase_job_id, 0),
            coalesce(cv.phase_job_name, 'None')
         --   coalesce(cv.jobsite, 'None')
            {{ var("row_limit") }}
    ),
    data_layer as (
        select
            coalesce(
                ds.day, utc.date, est.date, cst.date, mnt.date, wst.date, ipt.date
            ) as date,
            coalesce(
                ds.asset_id,
                utc.asset_id,
                est.asset_id,
                cst.asset_id,
                mnt.asset_id,
                wst.asset_id,
                ipt.asset_id,
                null
            ) as asset_id,
            coalesce(
                ds.rental_company_id,
                utc.rental_company_id,
                est.rental_company_id,
                cst.rental_company_id,
                mnt.rental_company_id,
                wst.rental_company_id,
                ipt.rental_company_id,
                null
            ) as rental_company_id,
            coalesce(
                ds.owner_company_id,
                utc.owner_company_id,
                est.owner_company_id,
                cst.owner_company_id,
                mnt.owner_company_id,
                wst.owner_company_id,
                ipt.owner_company_id,
                null
            ) as owner_company_id,
            coalesce(
                ds.job_id,
                utc.job_id,
                est.job_id,
                cst.job_id,
                mnt.job_id,
                wst.job_id,
                ipt.job_id,
                null
            ) as job_id,
            coalesce(
                ds.job_name,
                utc.job_name,
                est.job_name,
                cst.job_name,
                mnt.job_name,
                wst.job_name,
                ipt.job_name,
                null
            ) as job_name,
            coalesce(
                ds.phase_job_id,
                utc.phase_job_id,
                est.phase_job_id,
                cst.phase_job_id,
                mnt.phase_job_id,
                wst.phase_job_id,
                ipt.phase_job_id,
                null
            ) as phase_job_id,
            coalesce(
                ds.phase_job_name,
                utc.phase_job_name,
                est.phase_job_name,
                cst.phase_job_name,
                mnt.phase_job_name,
                wst.phase_job_name,
                ipt.phase_job_name,
                null
            ) as phase_job_name,
         --   coalesce(
         --       ds.jobsite,
            --     utc.jobsite,
            --     est.jobsite,
            --     cst.jobsite,
            --     mnt.jobsite,
            --     wst.jobsite,
            --     ipt.jobsite,
            --     null
            -- ) as jobsite,
            on_time_utc,
            in_progress_on_time_utc,
            run_time_utc,
            idle_time_utc,
            miles_driven_utc,
            hauled_time_utc,
            hauling_time_utc,
            hauling_distance_utc,
            hauled_distance_utc,
            on_time_est,
            in_progress_on_time_est,
            run_time_est,
            idle_time_est,
            miles_driven_est,
            hauled_time_est,
            hauling_time_est,
            hauling_distance_est,
            hauled_distance_est,
            on_time_cst,
            in_progress_on_time_cst,
            run_time_cst,
            idle_time_cst,
            miles_driven_cst,
            hauled_time_cst,
            hauling_time_cst,
            hauling_distance_cst,
            hauled_distance_cst,
            on_time_mnt,
            in_progress_on_time_mnt,
            run_time_mnt,
            idle_time_mnt,
            miles_driven_mnt,
            hauled_time_mnt,
            hauling_time_mnt,
            hauling_distance_mnt,
            hauled_distance_mnt,
            on_time_wst,
            in_progress_on_time_wst,
            run_time_wst,
            idle_time_wst,
            miles_driven_wst,
            hauled_time_wst,
            hauling_time_wst,
            hauling_distance_wst,
            hauled_distance_wst
        from date_series ds
        left join
            utc_time utc
            on utc.date = ds.day
            and ds.asset_id = utc.asset_id
            and ds.rental_company_id = utc.rental_company_id
            and ds.owner_company_id = utc.owner_company_id
            and utc.job_id = ds.job_id
            and ds.phase_job_id = ds.phase_job_id
            and utc.job_name = ds.job_name
            and utc.phase_job_name = ds.phase_job_name
        left join
            est_time est
            on est.date = ds.day
            and est.asset_id = ds.asset_id
            and est.rental_company_id = ds.rental_company_id
            and est.owner_company_id = ds.owner_company_id
            and ds.job_id = est.job_id
            and ds.phase_job_id = est.phase_job_id
            and ds.job_name = est.job_name
            and ds.phase_job_name = est.phase_job_name
        left join
            cst_time cst
            on cst.date = ds.day
            and cst.asset_id = ds.asset_id
            and cst.rental_company_id = ds.rental_company_id
            and cst.owner_company_id = ds.owner_company_id
            and ds.job_id = cst.job_id
            and ds.phase_job_id = cst.phase_job_id
            and ds.job_name = cst.job_name
            and ds.phase_job_name = cst.phase_job_name
        left join
            mnt_time mnt
            on mnt.date = ds.day
            and mnt.asset_id = ds.asset_id
            and mnt.rental_company_id = ds.rental_company_id
            and mnt.owner_company_id = ds.owner_company_id
            and ds.job_id = mnt.job_id
            and ds.phase_job_id = mnt.phase_job_id
            and ds.job_name = mnt.job_name
            and ds.phase_job_name = mnt.phase_job_name
        left join
            wst_time wst
            on wst.date = ds.day
            and wst.asset_id = ds.asset_id
            and wst.rental_company_id = ds.rental_company_id
            and wst.owner_company_id = ds.owner_company_id
            and ds.job_id = wst.job_id
            and ds.phase_job_id = wst.phase_job_id
            and ds.job_name = wst.job_name
            and ds.phase_job_name = wst.phase_job_name
        left join
            in_progress_trips ipt
            on ipt.date = ds.day
            and ipt.asset_id = ds.asset_id
            and ipt.rental_company_id = ds.rental_company_id
            and ipt.owner_company_id = ds.owner_company_id
            and ds.job_id = ipt.job_id
            and ds.phase_job_id = ipt.phase_job_id
            and ds.job_name = ipt.job_name
            and ds.phase_job_name = ipt.phase_job_name
            {{ var("row_limit") }}
    )
select distinct
    concat(dl.date, dl.asset_id, dl.rental_company_id, coalesce(dl.owner_company_id, a.company_id, null), job_id, phase_job_id)    as primary_key,
    dl.date,
    dayname(dl.date) as day_name,
    dl.asset_id,
    dl.rental_company_id,
    coalesce(dl.owner_company_id, a.company_id, null) as owner_company_id,
    on_time_utc,
    in_progress_on_time_utc,
    run_time_utc,
    idle_time_utc,
    miles_driven_utc,
    hauled_time_utc,
    hauling_time_utc,
    hauling_distance_utc,
    hauled_distance_utc,
    on_time_est,
    in_progress_on_time_est,
    run_time_est,
    idle_time_est,
    miles_driven_est,
    hauled_time_est,
    hauling_time_est,
    hauling_distance_est,
    hauled_distance_est,
    on_time_cst,
    in_progress_on_time_cst,
    run_time_cst,
    idle_time_cst,
    miles_driven_cst,
    hauled_time_cst,
    hauling_time_cst,
    hauling_distance_cst,
    hauled_distance_cst,
    on_time_mnt,
    in_progress_on_time_mnt,
    run_time_mnt,
    idle_time_mnt,
    miles_driven_mnt,
    hauled_time_mnt,
    hauling_time_mnt,
    hauling_distance_mnt,
    hauled_distance_mnt,
    on_time_wst,
    in_progress_on_time_wst,
    run_time_wst,
    idle_time_wst,
    miles_driven_wst,
    hauled_time_wst,
    hauling_time_wst,
    hauling_distance_wst,
    hauled_distance_wst,
    job_id,
    job_name,
    phase_job_id,
    phase_job_name,
  --  jobsite,
    al.end_date::date as last_location_date,
    al.end_date as last_checkin_timestamp_end_date,
    al.end_date::date as address_end_date,
    al.end_date::date as geofence_end_date,
    al.geofences,
    al.address,
    al.location,
    ai.asset,
    ai.custom_name,
    ai.asset_class,
    ai.parent_category,
    ai.category,
    ai.branch,
    ai.make,
    ai.model,
    ai.serial_number_vin,
    ai.serial_number,
    ai.vin,
    ai.asset_type,
    ai.tracker_grouping,
    ai.tracker_device_serial,
    ai.tracker_tracker_id,
    ai.esdb_tracker_id,
    ai.driver_name,
    ai.contact_in_72_hours,
    case
        when hauling_distance_utc > 0 or hauled_distance_utc > 0
        then 'used'
        else 'unused'
    end as used_unused_designation,
    case when dayname(dl.date) in ('Sat', 'Sun') then 1 else 0 end as weekend_flag,
    case when on_time_utc > 0 then 1 else 0 end as day_used,
    1 as possible_utilization_days,
    coalesce(od.odometer, 0) as odometer,
    coalesce(hr.hours, 0) as hours,
    coalesce(aa.owned_asset_count, null) as owned_asset_count,
    coalesce(a2.rental_asset_count, null) as rental_asset_count,
    -- , bcu.distinct_asset_count as benchmarked_asset_count
    -- , bcu.utilization_30_day_class_benchmark
    current_timestamp()::timestamp_ntz as data_refresh_timestamp
from data_layer dl
left join
    {{ ref("platform", "es_warehouse__public__assets") }} a on a.asset_id = dl.asset_id
left join last_locations al on al.asset_id = dl.asset_id and dl.date = al.end_date::date
left join {{ ref("stg_t3__asset_info") }} ai on ai.asset_id = dl.asset_id
left join odometer_daily od on od.asset_id = dl.asset_id and dl.date = od.date
left join hours_daily hr on hr.asset_id = dl.asset_id and dl.date = hr.date
left join
    {{ ref("stg_t3__available_assets") }} aa
    on dl.date = aa.day
    and aa.company_id = coalesce(dl.owner_company_id, a.company_id)
left join
    {{ ref("stg_t3__available_assets") }} a2
    on dl.date = a2.day
    and a2.company_id = dl.rental_company_id
    -- left join
    -- BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BENCHMARKS_CLASS_UTILIZATION bcu
    -- on ai.asset_class = bcu.asset_class and dl.date >= DATEADD(day, -30,
    -- CURRENT_DATE())
    {{ var("row_limit") }}
