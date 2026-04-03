view: analytics_quick_insights {
  derived_table: {
    sql: with rent_own_asset_ids as (
      select asset_id
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',  current_date::timestamp_ntz),
      convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz),
      '{{ _user_attributes['user_timezone'] }}'))
      union
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      {% if category_selection._parameter_value == "'Fleet'" %}
      , own_rent_asset_count as (
      select
      'Fleet' as selection,
      count(distinct(ro.asset_id)) as measure_1,
      'Own and Rental Asset Count' as string_1
      from
      rent_own_asset_ids ro
      join assets a on a.asset_id = ro.asset_id
      where
        a.deleted = FALSE
      )
      , number_of_diagnostic_codes as (
      select
          'Fleet' as selection,
          COUNT(DISTINCT ro.asset_id) as measure_2, --number_of_diagnostic_codes
          'Number of Diagnostic Codes' as string_2
      from
      rent_own_asset_ids ro
      inner join tracking_diagnostic_codes tdc on tdc.asset_id = ro.asset_id AND tdc.cleared is null and tdc.code is not null and tdc.report_timestamp is not null
      )
      , ool_assets as (
      SELECT
          'Fleet' as selection,
          count(distinct ro.asset_id) as measure_3, --total_out_of_locks_over_72_hours
          'Total Out of Locks Over 72 hrs.' as string_3
      FROM
      rent_own_asset_ids ro
      inner join v_out_of_lock ool on ro.asset_id = ool.asset_id and ool.over_72_hours_flag = TRUE
      inner join trackers_mapping tm on tm.asset_id = ro.asset_id
      )
      , asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,own_available_dates as (
      select
          a.asset_class,
          sum(on_time) as on_time
      from
          asset_list_own al
          left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
          left join assets a on a.asset_id = al.asset_id
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz)
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz)
      group by
          a.asset_class
      )
      ,asset_list_rental as (
      select asset_id, start_date, end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz), convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}'))
      )
      ,rental_available_dates as (
      select
          a.asset_class,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
          left join assets a on a.asset_id = alr.asset_id
          left join categories c on c.category_id = a.category_id
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz)
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz)
      group by
          a.asset_class
      )
      ,utilization_info as (
      select
          asset_class,
          'own' as ownership_type,
          sum(on_time) as on_time
      from
          own_available_dates oad
      group by
          asset_class
      UNION
      select
          asset_class,
          'rented' as ownership_type,
          round(sum(on_time)/3600,2) as on_time
      from
          rental_available_dates rad
      group by
          asset_class
      )
      ,summarize_utilization_info as (
      select
          'Fleet' as selection,
          asset_class as string_4,
          round(sum(on_time),2) as measure_4
       from
          utilization_info
       group by
          asset_class
      )
      select
          ora.selection,
          ora.measure_1,
          ora.string_1,
          ndc.measure_2,
          ndc.string_2,
          ool.measure_3,
          ool.string_3,
          sui.measure_4,
          sui.string_4
      from
          own_rent_asset_count ora
          inner join number_of_diagnostic_codes ndc on ora.selection = ndc.selection
          inner join ool_assets ool on ool.selection = ora.selection
          inner join summarize_utilization_info sui on sui.selection = ora.selection
      {% elsif category_selection._parameter_value == "'Rentals'" %}
      , on_rent_assets as (
      SELECT
          'Rentals' as selection,
          COUNT(DISTINCT CASE WHEN ea.end_date is null and r.rental_status_id = 5
          OR ((r.rental_status_id) = 5 AND (ea.end_date >= current_timestamp AND (ea.start_date <= current_timestamp)))
          OR ((r.rental_status_id) = 5 and (r.asset_id) is null)
          THEN r.rental_id else null end) AS measure_1,--on_rent_count,
          'On Rent Count' as string_1
      FROM
      rentals r
      LEFT JOIN equipment_assignments ea on ea.rental_id = r.rental_id
      LEFT JOIN assets a on ea.asset_id = a.asset_id
      LEFT JOIN orders o on r.order_id = o.order_id
      LEFT JOIN purchase_orders po on po.purchase_order_id = o.purchase_order_id
      LEFT JOIN users u on u.user_id = o.user_id
      INNER JOIN companies c on c.company_id = u.company_id
      WHERE
      r.rental_status_id = 5
      AND
      (
      {{ _user_attributes['company_id'] }}::integer = (c.company_id)
      and {{ _user_attributes['company_id'] }}::integer = (po.company_id)
      and ((a.asset_id) in (select asset_id from rent_own_asset_ids)
      or (r.asset_id) is null)
      )
      )
      , cycling_this_week as (
      SELECT
          'Rentals' as selection,
          COUNT(DISTINCT ac.rental_id) AS measure_2,--cycling_this_week,
          'Cycling This Week' as string_2
      from
      rentals r
      LEFT JOIN equipment_assignments ea on ea.rental_id = r.rental_id
      --LEFT JOIN assets a on ea.asset_id = a.asset_id
      LEFT JOIN admin_cycle ac on ac.asset_id = ea.asset_id and ac.rental_id = r.rental_id and ac.cycles_next_seven_days = 'TRUE'
      LEFT JOIN orders o on r.order_id = o.order_id
      LEFT JOIN purchase_orders po on po.purchase_order_id = o.purchase_order_id
      LEFT JOIN users u on u.user_id = o.user_id
      INNER JOIN companies c on c.company_id = u.company_id
      WHERE
        ({{ _user_attributes['company_id'] }}::integer = (c.company_id)
        and {{ _user_attributes['company_id'] }}::integer = (po.company_id)
        and ((ea.asset_id) in (select asset_id from rent_own_asset_ids)
        or (r.asset_id) is null)
        )
      )
      , reservation_count as (
      SELECT
          'Rentals' as selection,
          COUNT(DISTINCT CASE WHEN (r.rental_status_id) <= 4  THEN r.rental_id else null end) AS measure_3,--reservation_count
          'Reservation Count' as string_3
      FROM
      rentals r
      LEFT JOIN orders o on r.order_id = o.order_id
      INNER JOIN users u on u.user_id = o.user_id
      INNER JOIN users c on c.company_id = u.company_id and u.company_id = {{ _user_attributes['company_id'] }}::integer
      WHERE
        (
        r.rental_status_id <= 4
        AND
        ((c.company_id) = {{ _user_attributes['company_id'] }}::integer
        and
        (r.rental_id) in (select r.rental_id from rentals r
        join orders o on o.order_id = r.rental_id
        join rental_location_assignments la on la.rental_id = r.rental_id
        join geofences g on g.location_id = la.location_id
        join organization_geofence_xref x on x.geofence_id = g.geofence_id
        join organization_user_xref ux on ux.organization_id = x.organization_id
        where ux.user_id = {{ _user_attributes['user_id'] }}::numeric
        ))
        OR ((u.company_id) = {{ _user_attributes['company_id'] }}::integer
        and {{ _user_attributes['user_id'] }}::numeric = (select user_id from users where user_id = {{ _user_attributes['user_id'] }}::numeric and security_level_id in (1,2))
        ))
      )
      , asset_list_rental as (
      select asset_id, start_date, end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz), convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}'))
      )
      ,rental_available_dates as (
      select
          a.asset_class,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
          left join assets a on a.asset_id = alr.asset_id
          left join categories c on c.category_id = a.category_id
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz)
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz)
      group by
          a.asset_class
      )
      ,utilization_info as (
      select
          asset_class,
          round(sum(on_time)/3600,2) as on_time
      from
          rental_available_dates rad
          --join possible_utilization_days pud on pud.asset_id = alr.asset_id
      group by
          asset_class
      )
      ,summarize_utilization_info as (
      select
          'Rentals' as selection,
          asset_class as string_4,
          on_time as measure_4
       from
          utilization_info
      )
      select
          ora.selection,
          ora.measure_1,
          ora.string_1,
          ndc.measure_2,
          ndc.string_2,
          ool.measure_3,
          ool.string_3,
          sui.measure_4,
          sui.string_4
      from
          on_rent_assets ora
          inner join cycling_this_week ndc on ora.selection = ndc.selection
          inner join reservation_count ool on ool.selection = ora.selection
          inner join summarize_utilization_info sui on sui.selection = ora.selection
      {% else %}
      , total_open_work_orders as (
      SELECT
          'Service' as selection,
          COUNT(CASE WHEN wo.date_completed is null and wo.work_order_type_id = 1 then 1 else null END) AS measure_1, --total_open_work_orders,
          'Total Open Work Orders' as string_1
      FROM
        work_orders.work_orders wo
        inner join markets m on wo.branch_id = m.market_id
      WHERE
        wo.archived_date is null
        and m.company_id = {{ _user_attributes['company_id'] }}::integer
        and m.active = TRUE
      )
      , hard_down_asset_count as (
      select
          'Service' as selection,
          count(*) as measure_2, --hard_down_asset_count,
          'Hard Down Asset Count' as string_2
      from
          rent_own_asset_ids roa
          join (select asset_id, datediff(day,value_timestamp::date,current_date) as days_down from asset_status_key_values where value = 'Hard Down' and name = 'asset_inventory_status') av on av.asset_id = roa.asset_id
      )
      , assets_overdue_for_service as (
      SELECT
          'Service' as selection,
          COUNT(CASE WHEN round(asi.usage_percentage,2) >= 1.01 then 1 else null end) as measure_3,-- assets_overdue_for_service
          'Total Assets Overdue for Service' as string_3
      FROM
      asset_service_intervals asi
      join assets a on a.asset_id = asi.asset_id
      join rent_own_asset_ids roa on roa.asset_id = asi.asset_id
      )
      , last_seven_time_tracking_entries as (
      select
        wout.work_order_id,
        case when wo.work_order_type_id = 1 then 'WO-' else 'INSP-' end as wo_type,
        sum(round(datediff(seconds,start_date,end_date)/3600,2)) as hours
     from
        work_orders.work_order_user_times wout
        join users u on u.user_id = wout.user_id
        join work_orders.work_orders wo on wo.work_order_id = wout.work_order_id
    where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        and wout.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz) AND convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz)
    group by
        wout.work_order_id,
        wo.work_order_type_id
    union
    select
        er.work_order_id,
        case when wo.work_order_type_id = 1 then 'WO-' else 'INSP-' end as wo_type,
        sum(round(overtime_hours + regular_hours,2)) as hours
    from
        time_tracking.time_entries er
        join users u on u.user_id = er.user_id
        join work_orders.work_orders wo on wo.work_order_id = er.work_order_id
    where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        and er.work_order_id is not null
        and er.created_date BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz) AND convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_timestamp()::timestamp_ntz)
    group by
        er.work_order_id,
        wo.work_order_type_id
      )
      , total_hours_per_wo as (
      select
          'Service' as selection,
          concat(wo_type,work_order_id) as string_4,
          round(sum(hours),2) as measure_4 --time_tracking_hours
      from
          last_seven_time_tracking_entries
      where
          hours is not null
      group by
          concat(wo_type,work_order_id)
      )
      select
          owo.selection,
          owo.measure_1,
          owo.string_1,
          hdc.measure_2,
          hdc.string_2,
          aos.measure_3,
          aos.string_3,
          hpwo.measure_4,
          hpwo.string_4
      from
          total_open_work_orders owo
          inner join hard_down_asset_count hdc on owo.selection = hdc.selection
          inner join assets_overdue_for_service aos on aos.selection = owo.selection
          inner join total_hours_per_wo hpwo on hpwo.selection = owo.selection
      {%  endif %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: selection {
    type: string
    sql: ${TABLE}."SELECTION" ;;
  }

  dimension: measure_1 {
    type: number
    sql: ${TABLE}."MEASURE_1" ;;
  }

  dimension: string_1 {
    type: string
    sql: ${TABLE}."STRING_1" ;;
  }

  dimension: measure_2 {
    type: number
    sql: ${TABLE}."MEASURE_2" ;;
  }

  dimension: string_2 {
    type: string
    sql: ${TABLE}."STRING_2" ;;
  }

  dimension: measure_3 {
    type: number
    sql: ${TABLE}."MEASURE_3" ;;
  }

  dimension: string_3 {
    type: string
    sql: ${TABLE}."STRING_3" ;;
  }

  dimension: measure_4 {
    type: number
    sql: ${TABLE}."MEASURE_4" ;;
  }

  dimension: string_4 {
    label: "  "
    type: string
    sql: ${TABLE}."STRING_4" ;;
  }

  parameter: category_selection {
    type: string
    allowed_value: { value: "Fleet"}
    allowed_value: { value: "Rentals"}
    allowed_value: { value: "Service"}
  }

  dimension: dynamic_category_selection {
    label_from_parameter: category_selection
    sql:{% if category_selection._parameter_value == "'Fleet'" %}
      ${selection}
    {% elsif category_selection._parameter_value == "'Rentals'" %}
      ${selection}
    {% elsif category_selection._parameter_value == "'Service'" %}
      ${selection}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: welcome_message {
    type: string
    sql:
    case when '{{ _user_attributes['first_name'] }}' is not null then
    concat('Welcome,',' ','{{ _user_attributes['first_name'] }}','!')
    else
    'Welcome!' end;;
  }

  measure: sum_measure_4 {
    label: " "
    type: sum
    sql: ${measure_4} ;;
    html: {% if category_selection._parameter_value == "'Service'" %}
         {{ rendered_value }}
       {% else %}
         <p>{{ rendered_value }} hrs.</p>
       {% endif %} ;;
  }


  set: detail {
    fields: [
      selection,
      measure_1,
      string_1,
      measure_2,
      string_2,
      measure_3,
      string_3
    ]
  }
}
