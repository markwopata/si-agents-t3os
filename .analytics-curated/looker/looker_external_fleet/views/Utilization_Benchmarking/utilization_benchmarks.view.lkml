
view: utilization_benchmarks {
  derived_table: {
    sql: with date_series as (
            select
            series::date as day,
            dayname(series::date) as day_name
            from table
            (generate_series(
              DATEADD('day', -365, CURRENT_DATE())::timestamp_tz,
              DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))::timestamp_tz,
              'day')
            ))
            ,total_weekend_days_selected as (
            select
                sum(case when ds.day_name in ('Sat','Sun') then 1 else 0 end) as weekend_flag
            from
                date_series ds
            where
              ds.day <= current_date
            )
            ,asset_list_own as (
            select
                alo.asset_id,
                'Owned' as ownership,
                a.custom_name as asset,
                org.group_name,
                a.asset_class,
                cat.name as category,
                m.name as branch,
                a.make,
                a.model,
                coalesce(a.serial_number,a.vin) as serial_number_vin,
                concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
                tm.tracker_grouping,
                a.driver_name,
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp_end_date,
                coalesce(hll.address,ll.address) as address_end_date,
                coalesce(hll.geofences,ll.geofences) as geofence_end_date
                --,'active' as rental_status
            from
                table(assetlist(147431::numeric)) alo
                join es_warehouse.public.assets a on alo.asset_id = a.asset_id
                left join es_warehouse.public.asset_types ast on ast.asset_type_id = a.asset_type_id
                left join (select oax.asset_id, listagg(o.name,', ') as group_name from es_warehouse.public.organization_asset_xref oax
                join es_warehouse.public.organizations o on oax.organization_id = o.organization_id where 1=1 -- no filter on 'asset_utilization_by_day.groups_filter'
       group by oax.asset_id) org on org.asset_id = alo.asset_id
                left join es_warehouse.public.categories cat on cat.category_id = a.category_id
                left join es_warehouse.public.markets m on m.market_id = a.inventory_branch_id
                join es_warehouse.public.trackers_mapping tm on tm.asset_id = alo.asset_id
                left join (select asset_id, value as last_location_timestamp from es_warehouse.public.asset_status_key_values where name = 'last_location_timestamp') lc on lc.asset_id = alo.asset_id
                left join es_warehouse.snapshot.asset_last_location hll on hll.asset_id = alo.asset_id and hll.end_date::date = convert_timezone('America/Chicago','UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))::date
                left join es_warehouse.public.asset_last_location ll on ll.asset_id = alo.asset_id

            )
            ,in_progress_own_trips as (

                select
                  null as asset_id,
                  null as asset,
                  null as group_name,
                  null as asset_class,
                  null as category,
                  null as branch,
                  null as make,
                  null as model,
                  null as serial_number_vin,
                  null as asset_type,
                  null as ownership,
                  null as tracker_grouping,
                  null as driver_name,
                  null as last_checkin_timestamp_end_date,
                  null as address_end_date,
                  null as geofence_end_date,
                  null as start_date,
                  null as end_date,
                  null as on_time,
                  null as idle_time,
                  null as miles_driven,
                  null as start_time
                from
                  es_warehouse.public.trips

            )
            ,own_available_dates_summary as (
            select
                al.asset_id,
                al.asset,
                al.group_name,
                al.asset_class,
                al.category,
                al.branch,
                al.make,
                al.model,
                al.serial_number_vin,
                al.asset_type,
                al.ownership,
                al.tracker_grouping,
                al.driver_name,
                al.last_checkin_timestamp_end_date,
                al.address_end_date,
                al.geofence_end_date,
                --al.rental_status,
                convert_timezone('America/Chicago',report_range:start_range)::date as start_date,
                convert_timezone('America/Chicago',report_range:end_range)::date as end_date,
                sum(on_time) as on_time,
                sum(idle_time) as idle_time,
                sum(miles_driven) as miles_driven
            from
                asset_list_own al
                left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
            where
                report_range:start_range >= convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE()))
                AND report_range:end_range <= convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                AND

                dayname(convert_timezone('America/Chicago',report_range:start_range)::date) not in ('Sat','Sun')

            group by
                al.asset_id,
                al.asset,
                al.group_name,
                al.asset_class,
                al.category,
                al.branch,
                al.make,
                al.model,
                al.serial_number_vin,
                al.asset_type,
                al.ownership,
                al.tracker_grouping,
                al.driver_name,
                al.last_checkin_timestamp_end_date,
                al.address_end_date,
                al.geofence_end_date,
                --al.rental_status,
                convert_timezone('America/Chicago',report_range:start_range)::date,
                convert_timezone('America/Chicago',report_range:end_range)::date
            UNION
            select
              asset_id,
              asset,
              group_name,
              asset_class,
              category,
              branch,
              make,
              model,
              serial_number_vin,
              asset_type,
              ownership,
              tracker_grouping,
              driver_name,
              last_checkin_timestamp_end_date,
              address_end_date,
              geofence_end_date,
              start_date,
              end_date,
              case
                when start_time::date = start_date then datediff(seconds,start_time,dateadd(milliseconds,999,dateadd(seconds,59,dateadd(minutes,59,dateadd(hours,23,convert_timezone('America/Chicago',start_time::date))))))
                --convert_timezone('America/Chicago',current_timestamp))
                when start_date = current_date() then datediff(seconds,start_date,current_timestamp)
                when start_date > start_time::date then 86400

              else 0
                end  as on_time,
              0 as idle_time,
              0 as miles_driven
            from
              in_progress_own_trips
            )
            ,own_available_dates as (
            select
              asset_id,
              asset,
              group_name,
              asset_class,
              category,
              branch,
              make,
              model,
              serial_number_vin,
              asset_type,
              ownership,
              tracker_grouping,
              driver_name,
              last_checkin_timestamp_end_date,
              address_end_date,
              geofence_end_date,
              --rental_status,
              start_date,
              end_date,
              sum(on_time) as on_time,
              sum(idle_time) as idle_time,
              sum(miles_driven) as miles_driven
            from
              own_available_dates_summary
            group by
              asset_id,
              asset,
              group_name,
              asset_class,
              category,
              branch,
              make,
              model,
              serial_number_vin,
              asset_type,
              ownership,
              tracker_grouping,
              driver_name,
              last_checkin_timestamp_end_date,
              address_end_date,
              geofence_end_date,
              --rental_status,
              start_date,
              end_date
            )
            ,asset_list_rental as (
            select
                alr.asset_id,
                alr.start_date,
                alr.end_date,
                'Rented' as ownership,
                a.custom_name as asset,
                org.group_name,
                a.asset_class,
                cat.name as category,
                m.name as branch,
                a.make,
                a.model,
                coalesce(a.serial_number,a.vin) as serial_number_vin,
                concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
                tm.tracker_grouping,
                a.driver_name,
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp_end_date,
                coalesce(hll.address,ll.address) as address_end_date,
                coalesce(hll.geofences,ll.geofences) as geofence_end_date
                --,case when alr.end_date >= current_date() then 'active' else 'non-active' end as rental_status
            from
                table(rental_asset_list(147431::numeric,
                convert_timezone('America/Chicago','UTC', DATEADD('day', -6, CURRENT_DATE())),
                convert_timezone('America/Chicago','UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))),
                'America/Chicago')) alr
                join es_warehouse.public.assets a on alr.asset_id = a.asset_id
                left join es_warehouse.public.asset_types ast on ast.asset_type_id = a.asset_type_id
                left join (select oax.asset_id, listagg(o.name,', ') as group_name from es_warehouse.public.organization_asset_xref oax join es_warehouse.public.organizations o on oax.organization_id = o.organization_id where 1=1 -- no filter on 'asset_utilization_by_day.groups_filter'
       group by oax.asset_id) org on org.asset_id = alr.asset_id
                left join es_warehouse.public.categories cat on cat.category_id = a.category_id
                left join es_warehouse.public.markets m on m.market_id = a.inventory_branch_id
                join es_warehouse.public.trackers_mapping tm on tm.asset_id = alr.asset_id
                left join (select asset_id, value as last_location_timestamp from es_warehouse.public.asset_status_key_values where name = 'last_location_timestamp') lc on lc.asset_id = alr.asset_id
                left join es_warehouse.snapshot.asset_last_location hll on hll.asset_id = alr.asset_id AND alr.end_date <= hll.end_date::date AND alr.start_date >= hll.start_date AND hll.end_date::date = convert_timezone('America/Chicago','UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))::date
                left join es_warehouse.public.asset_last_location ll on ll.asset_id = alr.asset_id AND alr.end_date >= current_date()
            where
                --(UPPER( ast.name ) = UPPER('Equipment') OR UPPER( ast.name ) = UPPER('Vehicle'))
                1=1 -- no filter on 'asset_utilization_by_day.custom_name_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.asset_class_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.groups_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.ownership_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.category_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.branch_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.asset_type_filter'

                AND 1=1 -- no filter on 'asset_utilization_by_day.tracker_grouping_filter'

                AND tm.asset_id is not null
                AND

                  1 = 1

                AND a.company_id <> 60574
            ),
            rental_available_dates_summary as (
            select
                alr.asset_id,
                alr.asset,
                alr.group_name,
                alr.asset_class,
                alr.category,
                alr.branch,
                alr.make,
                alr.model,
                alr.serial_number_vin,
                alr.asset_type,
                alr.ownership,
                alr.tracker_grouping,
                alr.driver_name,
                alr.last_checkin_timestamp_end_date,
                alr.address_end_date,
                alr.geofence_end_date,
                --alr.rental_status,
                convert_timezone('America/Chicago',report_range:start_range)::date as rental_start_date,
                convert_timezone('America/Chicago',report_range:end_range)::date as rental_end_date,
                sum(on_time) as on_time,
                sum(idle_time) as idle_time,
                sum(miles_driven) as miles_driven
            from
                asset_list_rental alr
                left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
            where
                report_range:start_range >= convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE()))
                AND report_range:end_range <= convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                --DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))
                AND

                dayname(convert_timezone('America/Chicago',report_range:start_range)::date) not in ('Sat','Sun')

            group by
                alr.asset_id,
                alr.asset,
                alr.group_name,
                alr.asset_class,
                alr.category,
                alr.branch,
                alr.make,
                alr.model,
                alr.serial_number_vin,
                alr.asset_type,
                alr.ownership,
                alr.tracker_grouping,
                alr.driver_name,
                alr.last_checkin_timestamp_end_date,
                alr.address_end_date,
                alr.geofence_end_date,
                --alr.rental_status,
                convert_timezone('America/Chicago',report_range:start_range)::date,
                convert_timezone('America/Chicago',report_range:end_range)::date
            UNION

                select
                  null as asset_id,
                  null as asset,
                  null as group_name,
                  null as asset_class,
                  null as category,
                  null as branch,
                  null as make,
                  null as model,
                  null as serial_number_vin,
                  null as asset_type,
                  null as ownership,
                  null as tracker_grouping,
                  null as driver_name,
                  null as last_checkin_timestamp_end_date,
                  null as address_end_date,
                  null as geofence_end_date,
                  null as start_date,
                  null as end_date,
                  null as on_time,
                  null as idle_time,
                  null as miles_driven
                from
                  es_warehouse.public.trips

            )
            ,rental_available_dates as (
            select
              asset_id,
              asset,
              group_name,
              asset_class,
              category,
              branch,
              make,
              model,
              serial_number_vin,
              asset_type,
              ownership,
              tracker_grouping,
              driver_name,
              last_checkin_timestamp_end_date,
              address_end_date,
              geofence_end_date,
              --rental_status,
              rental_start_date,
              rental_end_date,
              sum(on_time) as on_time,
              sum(idle_time) as idle_time,
              sum(miles_driven) as miles_driven
            from
              rental_available_dates_summary
            group by
              asset_id,
              asset,
              group_name,
              asset_class,
              category,
              branch,
              make,
              model,
              serial_number_vin,
              asset_type,
              ownership,
              tracker_grouping,
              driver_name,
              last_checkin_timestamp_end_date,
              address_end_date,
              geofence_end_date,
              --rental_status,
              rental_start_date,
              rental_end_date
            )
            , asset_run_time as (
            select
              asset_id,
              sum(on_time) as total_run_time
            from
              own_available_dates
            where

              dayname(end_date::date) not in ('Sat','Sun')

            group by
              asset_id
            UNION
            select
              asset_id,
              sum(on_time) as total_run_time
            from
              rental_available_dates
            where

              dayname(rental_end_date::date) not in ('Sat','Sun')

            group by
              asset_id
            )
            , asset_used_designation as (
            select
              asset_id,
              'used' as asset_designation
            from
              asset_run_time
            where
              total_run_time > 0
            )
            , assets_dates as (
            select dt.day as generated_date,
            alo.asset_id,
            null as rental_start_date,
            null as rental_end_date,
            'own' as source
            from date_series dt
            cross join asset_list_own alo
            UNION
            select dt.day as generated_date,
            alr.asset_id,
            alr.start_date as rental_start_date,
            alr.end_date as rental_end_date,
            'rental' as source
            from date_series dt
            cross join asset_list_rental alr
            where dt.day BETWEEN alr.start_date AND alr.end_date
            )
            , odometer_list as (
            select
                ad.asset_id,
                odometer,
                case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end as end_date,
                date_trunc('day',
                convert_timezone('America/Chicago',case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end))::timestamp_ntz::date as modified_end_date,
                ROW_NUMBER() OVER(partition by ad.asset_id, modified_end_date ORDER BY end_date desc) as last_for_day,
                'own' as source
            from
                assets_dates ad
                left join ES_WAREHOUSE.SCD.SCD_ASSET_ODOMETER sao on sao.asset_id = ad.asset_id
            where
                ad.source = 'own'
                AND end_date between
                convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE())) and
                convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
            qualify last_for_day = 1
            UNION
            select
                ad.asset_id,
                odometer,
                case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end as end_date,
                date_trunc('day',convert_timezone('America/Chicago',case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end))::timestamp_ntz::date as modified_end_date,
                ROW_NUMBER() OVER(partition by ad.asset_id, modified_end_date ORDER BY end_date desc) as last_for_day,
                'rental' as source
            from
                assets_dates ad
                left join ES_WAREHOUSE.SCD.SCD_ASSET_ODOMETER sao on sao.asset_id = ad.asset_id
            where
                ad.source = 'rental'
                AND end_date between
                convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE())) and
                convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
            qualify last_for_day = 1
            )
            , odometer_ready as (
            select
                dt.generated_date,
                dt.asset_id,
                case when od.odometer is null then
                lag(od.odometer, 1, 0) IGNORE NULLS OVER (PARTITION BY dt.asset_id ORDER BY generated_date DESC)
                else od.odometer end as odometer
                --as odometer_lag,
               -- case when odometer_lag = 0 then max(od.odometer) OVER (PARTITION BY dt.asset_id) else odometer_lag end as daily_ending_odometer
            from
                assets_dates dt
                left join odometer_list od on dt.generated_date = od.modified_end_date and dt.asset_id = od.asset_id
            where
                dt.source = 'own'
            UNION
            select
                dt.generated_date,
                dt.asset_id,
                case when od.odometer is null then
                lag(od.odometer, 1, 0) IGNORE NULLS OVER (PARTITION BY dt.asset_id ORDER BY generated_date DESC)
                else od.odometer end as odometer
                --as odometer_lag,
               -- case when odometer_lag = 0 then max(od.odometer) OVER (PARTITION BY dt.asset_id) else odometer_lag end as daily_ending_odometer
            from
                assets_dates dt
                left join odometer_list od on dt.generated_date = od.modified_end_date and dt.asset_id = od.asset_id
            where
                dt.source = 'rental'
            )
            , hour_list as (
            select
                ad.asset_id,
                hours,
                case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end as end_date,
                date_trunc('day',convert_timezone('America/Chicago',case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end))::timestamp_ntz::date as modified_end_date,
                ROW_NUMBER() OVER(partition by ad.asset_id, modified_end_date ORDER BY end_date desc) as last_for_day,
                'own' as source
            from
                assets_dates ad
                left join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS sah on sah.asset_id = ad.asset_id
            where
                ad.source = 'own'
                AND end_date between
                convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE())) and
                convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
            qualify last_for_day = 1
            UNION
            select
                ad.asset_id,
                hours,
                case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end as end_date,
                date_trunc('day',convert_timezone('America/Chicago',case when current_flag = 1 then convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
                else date_end end))::timestamp_ntz::date as modified_end_date,
                ROW_NUMBER() OVER(partition by ad.asset_id, modified_end_date ORDER BY end_date desc) as last_for_day,
                'rental' as source
            from
                assets_dates ad
                left join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS sah on sah.asset_id = ad.asset_id
            where
                ad.source = 'rental'
                AND end_date between
                convert_timezone('America/Chicago','UTC',DATEADD('day', -6, CURRENT_DATE())) and
                convert_timezone('America/Chicago','UTC',DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))
            qualify last_for_day = 1
            )
            , hour_ready as (
            select
                dt.generated_date,
                dt.asset_id,
                case when hr.hours is null then
                lag(hr.hours, 1, 0) IGNORE NULLS OVER (PARTITION BY dt.asset_id ORDER BY generated_date DESC)
                else hr.hours end as hours
            from
                assets_dates dt
                left join hour_list hr on dt.generated_date = hr.modified_end_date and dt.asset_id = hr.asset_id
            where
                dt.source = 'own'
            UNION
            select
                dt.generated_date,
                dt.asset_id,
                case when hr.hours is null then
                lag(hr.hours, 1, 0) IGNORE NULLS OVER (PARTITION BY dt.asset_id ORDER BY generated_date DESC)
                else hr.hours end as hours
            from
                assets_dates dt
                left join hour_list hr on dt.generated_date = hr.modified_end_date and dt.asset_id = hr.asset_id
            where
                dt.source = 'rental'
            )
            , pre_frame as (select
                ds.day,
                ds.day_name,
                alo.asset_id,
                alo.asset,
                alo.group_name,
                alo.asset_class,
                alo.category,
                alo.branch,
                alo.make,
                alo.model,
                alo.serial_number_vin,
                alo.asset_type,
                alo.ownership,
                alo.tracker_grouping,
                alo.driver_name,
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp,
                coalesce(hll.address,ll.address) as address,
                coalesce(hll.geofences,ll.geofences) as geofence,
                alo.last_checkin_timestamp_end_date,
                alo.address_end_date,
                alo.geofence_end_date,
                --alo.rental_status,
                coalesce(aud.asset_designation,'unused') as used_unused_designation,
                sum(case when on_time > 0 then 1 else 0 end) as day_used,
                1 as possible_utilization_days,
                round(coalesce(sum(on_time),0)/3600,2) - round(coalesce(sum(idle_time),0)/3600,2) as run_time,
                round(coalesce(sum(idle_time),0)/3600,2) as idle_time,
                coalesce(round(sum(miles_driven),1),0) as miles_driven,
                round(coalesce(sum(on_time),0)/3600,2) as on_time
            from
                date_series ds
                join asset_list_own alo on 1=1
                left join own_available_dates oad on oad.asset_id = alo.asset_id and oad.start_date = ds.day
                --left join possible_utilization_days pud on pud.asset_id = oad.asset_id
                --left join total_weekend_days_selected wd on 1=1
                left join asset_used_designation aud on aud.asset_id = alo.asset_id
                left join es_warehouse.snapshot.asset_last_location hll on hll.asset_id = alo.asset_id AND ds.day::date = hll.start_date::date
                --hll.end_date::date = convert_timezone('America/Chicago','UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))::date
                left join es_warehouse.public.asset_last_location ll on ll.asset_id = alo.asset_id
            where
                ds.day <= current_date
                AND

                dayname(ds.day::date) not in ('Sat','Sun')

            group by
                ds.day,
                ds.day_name,
                alo.asset_id,
                alo.asset,
                alo.group_name,
                alo.asset_class,
                alo.category,
                alo.branch,
                alo.make,
                alo.model,
                alo.serial_number_vin,
                alo.asset_type,
                alo.ownership,
                alo.tracker_grouping,
                alo.driver_name,
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp),
                coalesce(hll.address,ll.address),
                coalesce(hll.geofences,ll.geofences),
                alo.last_checkin_timestamp_end_date,
                alo.address_end_date,
                alo.geofence_end_date,
                --alo.rental_status,
                --wd.weekend_flag,
                coalesce(aud.asset_designation,'unused')
            UNION
            select
                ds.day,
                ds.day_name,
                alr.asset_id,
                alr.asset,
                alr.group_name,
                alr.asset_class,
                alr.category,
                alr.branch,
                alr.make,
                alr.model,
                alr.serial_number_vin,
                alr.asset_type,
                alr.ownership,
                alr.tracker_grouping,
                alr.driver_name,
                --these need to be replaced with a join on asset_id and date after the previous CTE is changed or revomed and replaced
                --similar to what was done with hours and odometer
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp,
                coalesce(hll.address,ll.address) as address,
                coalesce(hll.geofences,ll.geofences) as geofence,
                alr.last_checkin_timestamp_end_date,
                alr.address_end_date,
                alr.geofence_end_date,
                -------------
                --alr.rental_status,
                coalesce(aud.asset_designation,'unused') as used_unused_designation,
                case when on_time > 0 then 1 else 0 end as day_used,
                1 as possible_utilization_days,
                round(coalesce(sum(on_time),0)/3600,2) - round(coalesce(sum(idle_time),0)/3600,2) as run_time,
                round(coalesce(sum(idle_time),0)/3600,2) as idle_time,
                coalesce(round(sum(miles_driven),1),0) as miles_driven,
                round(coalesce(sum(on_time),0)/3600,2) as on_time
            from
                date_series ds
                join asset_list_rental alr on ds.day >= alr.start_date::date AND ds.day <= alr.end_date::date
                left join rental_available_dates rad on rad.asset_id = alr.asset_id and rad.rental_start_date = ds.day
                --left join possible_utilization_days pud on pud.asset_id = alr.asset_id
                --left join total_weekend_days_selected wd on 1=1
                left join asset_used_designation aud on aud.asset_id = alr.asset_id
                left join es_warehouse.snapshot.asset_last_location hll on hll.asset_id = alr.asset_id AND alr.end_date <= hll.end_date::date AND alr.start_date >= hll.start_date::date AND ds.day::date = hll.start_date::date
                --hll.end_date::date = convert_timezone('America/Chicago','UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))::date
                left join es_warehouse.public.asset_last_location ll on ll.asset_id = alr.asset_id AND alr.end_date >= current_date()
                where
                ds.day <= current_date
                AND alr.asset_id is not null
                AND

                dayname(ds.day::date) not in ('Sat','Sun')

            group by
                ds.day,
                ds.day_name,
                alr.asset_id,
                alr.asset,
                alr.group_name,
                alr.asset_class,
                alr.category,
                alr.branch,
                alr.make,
                alr.model,
                alr.serial_number_vin,
                alr.asset_type,
                alr.ownership,
                alr.tracker_grouping,
                alr.driver_name,
                coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp),
                coalesce(hll.address,ll.address),
                coalesce(hll.geofences,ll.geofences),
                alr.last_checkin_timestamp_end_date,
                alr.address_end_date,
                alr.geofence_end_date,
                on_time,
                --alr.rental_status,
                --wd.weekend_flag,
                coalesce(aud.asset_designation,'unused')
                )
              select pre.*
              , case when month(day) in (1,2,12) then 'Winter'
              when month(day) in (3,4,5) then 'Spring'
              when month(day) in (6,7,8) then 'Summer'
              when month(day) in (9,10,11) then 'Fall'
              else 'else' end as season
              , coalesce(od.odometer,0) as odometer
              , coalesce(hr.hours,0) as hours
              , case when geofence is null then False
                else True end as Geofence_TF
              , make as y_axis
              , run_time as x_axis
              from pre_frame pre
              left join odometer_ready od on pre.day = od.generated_date and pre.asset_id = od.asset_id
              left join hour_ready hr on pre.day = hr.generated_date and pre.asset_id = hr.asset_id

              ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: y_axis {
    type: string
    sql: ${TABLE}."Y_AXIS" ;;
  }

  dimension: x_axis {
    type: string
    sql: ${TABLE}."X_AXIS" ;;
  }

  filter: y_axis_filter {
    type: string
    sql: ${TABLE}."Y_AXIS" ;;
  }

  filter: x_axis_filter {
    type: string
    sql: ${TABLE}."X_AXIS" ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

    dimension: day_used {
    type: number
    sql: ${TABLE}."DAY_USED" ;;
  }

  dimension: possible_utilization_days {
    type: number
    sql: ${TABLE}."POSSIBLE_UTILIZATION_DAYS" ;;
  }

  dimension: run_time {
    type: number
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: day_name {
    type: string
    sql: ${TABLE}."DAY_NAME" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."tracker_grouping" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: geofence {
    type: string
    sql: ${TABLE}."GEOFENCE" ;;
  }

  dimension_group: last_checkin_timestamp_end_date {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP_END_DATE" ;;
  }

  dimension: address_end_date {
    type: string
    sql: ${TABLE}."ADDRESS_END_DATE" ;;
  }

  dimension: geofence_end_date {
    type: string
    sql: ${TABLE}."GEOFENCE_END_DATE" ;;
  }

  dimension: used_unused_designation {
    type: string
    sql: ${TABLE}."USED_UNUSED_DESIGNATION" ;;
  }

  dimension: season {
    type: string
    sql: ${TABLE}."SEASON" ;;
  }

  dimension: geofence_tf {
    type: yesno
    sql: ${TABLE}."GEOFENCE_TF" ;;
  }


  measure: x_axis_measure {
    label: "X Axis"
    type: sum
    sql: ${x_axis} ;;
  }

  measure: odometer_measure {
    label: "Odometer"
    type: sum
    sql: ${odometer} ;;
  }

  measure: hours_measure {
    label: "Hours"
    type: sum
    sql: ${hours} ;;
  }

  measure: day_used_measure {
    label: "Days Used"
    type: sum
    sql: ${day_used} ;;
  }

  measure: possible_utilization_days_measure {
    label: "Possible Utilization Days"
    type: sum
    sql: ${possible_utilization_days} ;;
  }

  measure: run_time_measure {
    label: "Run Time"
    type: sum
    sql: ${run_time} ;;
  }

  measure: idle_time_measure {
    label: "Idle Time"
    type: sum
    sql: ${idle_time} ;;
  }

  measure: miles_driven_measure {
    label: "Miles Driven"
    type: sum
    sql: ${miles_driven} ;;
  }

  measure: on_time_measure {
    label: "On Time"
    type: sum
    sql: ${on_time} ;;
  }

  set: detail {
    fields: [
      x_axis,
      y_axis,
      x_axis_filter,
      y_axis_filter,
      day,
      day_name,
      asset_id,
      asset,
      group_name,
      asset_class,
      category,
      branch,
      make,
      model,
      serial_number_vin,
      asset_type,
      ownership,
      tracker_grouping,
      driver_name,
      last_checkin_timestamp_time,
      address,
      geofence,
      last_checkin_timestamp_end_date_time,
      address_end_date,
      geofence_end_date,
      used_unused_designation,
      day_used,
      possible_utilization_days,
      run_time,
      idle_time,
      miles_driven,
      on_time,
      season,
      odometer,
      hours,
      geofence_tf
    ]
  }
}