view: utilization_by_day {
  derived_table: {
    sql: with date_series as (
      select
        series::date as day,
        dayname(series::date) as day_name
      from table
        (generate_series(
        convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %})::timestamp_tz,
        convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %})::timestamp_tz,
        'day')
      )),
 --     day_selection as (
--      select
--          ds.day,
--          case when ds.day_name in ('Sat','Sun') then 1 else 0 end as weekend_flag
--      from
--          date_series ds
--      ),
--      total_weekend_days_selected as (
--      select
--          1 as flag,
--          sum(weekend_flag) as total_weekend_days
--      from
--          day_selection
--      where
--          day <= current_date
--      ),
      asset_list_own as (
          select asset_id, 'Owned' as ownership_type
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
      ,own_available_dates as (
      select
          al.asset_id,
          al.ownership_type,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date as start_date,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date as end_date,
          sum(on_time) as on_time
      from
          asset_list_own al
          join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
          join assets a on al.asset_id = a.asset_id
          join asset_types at on at.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = al.asset_id
          --left join organization_asset_xref oax on oax.asset_id = al.asset_id
          --left join organizations org on org.organization_id = oax.organization_id
          left join categories cat on cat.category_id = a.category_id
          join markets m on m.market_id = a.inventory_branch_id
          join asset_last_location ll on ll.asset_id = al.asset_id
      where
          report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date - interval '10 days'))
          AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date))
          AND {% condition asset_names_filter %} at.name {% endcondition %}
          AND {% condition custom_name_filter %} a.custom_name {% endcondition %}
          --AND {% condition groups_filter %} org.name {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition last_location_filter %} ll.geofences {% endcondition %}
          AND {% condition ownership_filter %} al.ownership_type {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
      group by
          al.asset_id,
          al.ownership_type,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date
      )
      ,asset_list_rental as (
      select asset_id, start_date, end_date, 'Rented' as ownership_type
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
      ),
      rental_available_dates as (
      select
          alr.asset_id,
          alr.ownership_type,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date as rental_start_date,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date as rental_end_date,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
          join assets a on alr.asset_id = a.asset_id
          join asset_types at on at.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alr.asset_id
          --left join organization_asset_xref oax on oax.asset_id = alr.asset_id
          --left join organizations org on org.organization_id = oax.organization_id
          left join categories cat on cat.category_id = a.category_id
          join markets m on m.market_id = a.inventory_branch_id
          join asset_last_location ll on ll.asset_id = alr.asset_id
      where
          report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC',{% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date - interval '10 days'))
          AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date))
          AND {% condition asset_names_filter %} at.name {% endcondition %}
          AND {% condition custom_name_filter %} a.custom_name {% endcondition %}
          --AND {% condition groups_filter %} org.name {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition last_location_filter %} ll.geofences {% endcondition %}
          AND {% condition ownership_filter %} alr.ownership_type {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
      group by
          alr.asset_id,
          alr.ownership_type,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date
      )
      ,utilization_per_asset as (
      select
          alo.asset_id,
          sum(on_time) as on_time
      from
          asset_list_own alo
          left join own_available_dates oad on alo.asset_id = oad.asset_id
      group by
          alo.asset_id
      UNION
      select
          alr.asset_id,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join rental_available_dates rad on alr.asset_id = rad.asset_id
      group by
          alr.asset_id
       )
      ,used_unused_assets as (
      select
          upa.asset_id,
          case when on_time > 0 then 'Used Asset' when on_time is null and a.tracker_id is null then 'No Tracker' else 'Unused Asset' end as asset_type
      from
          utilization_per_asset upa
          join assets a on a.asset_id = upa.asset_id
       )
      ,utilization_info as (
      select
          start_date,
          sum(on_time) as on_time
      from
          asset_list_own alo
          left join own_available_dates oad on alo.asset_id = oad.asset_id
          join used_unused_assets uua on uua.asset_id = alo.asset_id
      where
        {% condition used_unused_filter %} asset_type {% endcondition %}
      group by
          start_date
      UNION
      select
          rental_start_date as start_date,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          join rental_available_dates rad on alr.asset_id = rad.asset_id
          join used_unused_assets uua on uua.asset_id = alr.asset_id
      where
        {% condition used_unused_filter %} asset_type {% endcondition %}
      group by
          rental_start_date
       )
       ,assets_per_day as (
       select
          ds.day,
          'Rented' as ownership_type,
          count(distinct(alr.asset_id)) as asset_count
       from
          asset_list_rental alr
          join date_series ds on ds.day between alr.start_date::date and alr.end_date::date
          join used_unused_assets uua on uua.asset_id = alr.asset_id
          join assets a on alr.asset_id = a.asset_id
          join asset_types at on at.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alr.asset_id
          --left join organization_asset_xref oax on oax.asset_id = alr.asset_id
          --left join organizations org on org.organization_id = oax.organization_id
          left join categories cat on cat.category_id = a.category_id
          join markets m on m.market_id = a.inventory_branch_id
          join asset_last_location ll on ll.asset_id = alr.asset_id
       where
          {% condition ownership_filter %} alr.ownership_type {% endcondition %}
          AND {% condition used_unused_filter %} asset_type {% endcondition %}
          AND {% condition asset_names_filter %} at.name {% endcondition %}
          AND {% condition custom_name_filter %} a.custom_name {% endcondition %}
          --AND {% condition groups_filter %} org.name {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition last_location_filter %} ll.geofences {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
       group by
          ds.day
       union
       select
          ds.day,
          'Owned' as ownership_type,
          count(distinct(alo.asset_id)) as asset_count
       from
          date_series ds
          left join asset_list_own alo on 1=1
          join used_unused_assets uua on uua.asset_id = alo.asset_id
          join assets a on alo.asset_id = a.asset_id
          join asset_types at on at.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alo.asset_id
          --left join organization_asset_xref oax on oax.asset_id = alo.asset_id
          --left join organizations org on org.organization_id = oax.organization_id
          left join categories cat on cat.category_id = a.category_id
          join markets m on m.market_id = a.inventory_branch_id
          join asset_last_location ll on ll.asset_id = alo.asset_id
       where
          {% condition ownership_filter %} alo.ownership_type {% endcondition %}
          AND {% condition used_unused_filter %} asset_type {% endcondition %}
          AND {% condition asset_names_filter %} at.name {% endcondition %}
          AND {% condition custom_name_filter %} a.custom_name {% endcondition %}
          --AND {% condition groups_filter %} org.name {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition last_location_filter %} ll.geofences {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
       group by
          ds.day
       )
      ,per_day_on_time as (
       select
          ds.day,
          --sum(asset_count) as total_available_assets,
          --on_time as total_on_time
          sum(on_time) as total_on_time
       from
          date_series ds
          --left join assets_per_day apd on apd.day = ds.day
          join utilization_info ui on ui.start_date = ds.day
       where
          ds.day <= current_date
       group by
          ds.day
       )
       ,per_day_available_assets as (
       select
          ds.day,
          sum(asset_count) as total_available_assets
       from
          date_series ds
          join assets_per_day apd on apd.day = ds.day
       where
          ds.day <= current_date
       group by
          ds.day
       )
       ,days_for_calculation as (
       select
  --        total_weekend_days,
          datediff(day,min(day),max(day)) as date_filter_difference
       from
          per_day_available_assets pda
  --        left join total_weekend_days_selected twd on 1=1
 --      group by
--          total_weekend_days
       )
       select
          ds.day,
          coalesce(round(total_on_time/3600,2),0) as total_on_time,
          total_available_assets,
          --total_weekend_days,
          date_filter_difference
       from
          date_series ds
          left join per_day_available_assets pda on pda.day = ds.day
          left join per_day_on_time pdo on pdo.day = ds.day
          left join days_for_calculation dfc on 1=1
       where
          total_available_assets is not null
       ;;
  }

#   //       ,days_for_calculation as (
# //       select
# //          total_weekend_days,
# //          datediff(day,min(day),max(day))+1 as date_filter_difference
# //       from
# //          per_day_history pdh
# //          left join total_weekend_days_selected twd on 1=1
# //       group by
# //          total_weekend_days
# //       )

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(day,${total_on_time},${total_available_assets}) ;;
    hidden: yes
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: total_on_time {
    type: number
    sql: ${TABLE}."TOTAL_ON_TIME" ;;
    hidden: yes
  }

  dimension: total_available_assets {
    type: number
    sql: ${TABLE}."TOTAL_AVAILABLE_ASSETS" ;;
    hidden: yes
  }

  dimension: total_weekend_days {
    type: number
    sql: ${TABLE}."TOTAL_WEEKEND_DAYS" ;;
    hidden: yes
  }

  dimension: date_filter_difference {
    type: number
    sql: ${TABLE}."DATE_FILTER_DIFFERENCE" ;;
    hidden: yes
  }

  dimension: start_range_time_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_date_filter_difference {
    type: max
    sql: ${date_filter_difference} ;;
  }

  measure: total_selected_weekend_days {
    type: max
    sql: ${total_weekend_days} ;;
  }

  measure: total_selected_on_time {
    label: "Total On Time"
    type: sum
    sql: coalesce(${total_on_time},0) ;;
  }

  measure: total_selected_available_assets {
    label: "Total Available Assets"
    type: sum
    sql: ${total_available_assets} ;;
  }

  measure: average_utilization_kpi_eight_hours {
    type: number
    sql:
    case
    when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((8*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((8)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: test {
    type: number
    sql: case
          when ${total_date_filter_difference} >= 5 then ((${total_selected_on_time})/((8*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
          end
          ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_ten_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((10*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((10)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((10)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_twelve_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((12*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((12)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((12)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_one_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((1*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((1)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((1)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_two_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((2*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((2)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((2)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_three_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((3*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((3)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((3)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_four_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((4*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((4)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((4)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_five_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((5*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((5)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((5)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_six_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((6*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((6)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((6)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: average_utilization_kpi_seven_hours {
    type: number
    sql:
    case when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((7*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((7)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: utilization_average_over_the_days {
    type: number
    sql: ${average_utilization_kpi_eight_hours}/${total_date_filter_difference} ;;
    hidden: yes
  }

  # parameter: utilization_hours_selection {
  #   type: string
  #   allowed_value: { value: "8 Hours"}
  #   allowed_value: { value: "10 Hours"}
  #   allowed_value: { value: "12 Hours"}
  # }

  dimension: parameter_name {
    type: string
    sql: "Utilization %" ;;
  }

  measure: dynamic_average_utilization_percentage_by_day {
    # label_from_parameter: hourly_asset_usage_date_filter.utilization_hours
    label: "Utilization %"
    sql:
    coalesce(
    {% if hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'8 Hours'" %}
      ${daily_utilization_kpi_eight_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'10 Hours'" %}
      ${daily_utilization_kpi_ten_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'12 Hours'" %}
      ${daily_utilization_kpi_twelve_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'24 Hours'" %}
      ${daily_utilization_kpi_twenty_four_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'1 Hour'" %}
      ${daily_utilization_kpi_one_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'2 Hours'" %}
      ${daily_utilization_kpi_two_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'3 Hours'" %}
      ${daily_utilization_kpi_three_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'4 Hours'" %}
      ${daily_utilization_kpi_four_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'5 Hours'" %}
      ${daily_utilization_kpi_five_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'6 Hours'" %}
      ${daily_utilization_kpi_six_hours}
    {% elsif hourly_asset_usage_date_filter.utilization_hours._parameter_value == "'7 Hours'" %}
      ${daily_utilization_kpi_seven_hours}
    {% else %}
      NULL
    {% endif %},0) ;;
    html: {{rendered_value}}
          <br />Available Assets: {{ total_selected_available_assets._rendered_value }}
          <br />Total Run Time: {{total_selected_on_time._rendered_value}};;
    type: number
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  measure: daily_utilization_kpi_eight_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(8))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_ten_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(10))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_twelve_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(12))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_twenty_four_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(24))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_one_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(1))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_two_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(2))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_three_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(3))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_four_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(4))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_five_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(5))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_six_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(6))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  measure: daily_utilization_kpi_seven_hours {
    type: number
    sql:
    ((${total_selected_on_time})/(7))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
    # value_format_name: decimal_1
    # html: {{rendered_value}}% ;;
    hidden: yes
  }

  filter: asset_names_filter {
    suggest_explore: assets
    suggest_dimension: asset_types.asset_type
    view_label: "Utilization Filters"
    description: "Returns data for asset names selected when looking at utilization by day"
  }

  filter: custom_name_filter {
    suggest_explore: assets
    suggest_dimension: assets.custom_name
    view_label: "Utilization Filters"
    description: "Returns data for assets selected when looking at utilization by day"
  }

  filter: groups_filter {
    suggest_explore: assets
    suggest_dimension: organizations.groups
    view_label: "Utilization Filters"
    description: "Returns data for groups selected when looking at utilization by day"
  }

  filter: category_filter {
    suggest_explore: assets
    suggest_dimension: categories.name
    view_label: "Utilization Filters"
    description: "Returns data for categories selected when looking at utilization by day"
  }

  filter: ownership_filter {
    suggest_explore: assets
    suggest_dimension: assets.ownership_type
    view_label: "Utilization Filters"
    description: "Returns data for ownership selected when looking at utilization by day"
  }

  filter: branch_filter {
    suggest_explore: assets
    suggest_dimension: markets.name
    view_label: "Utilization Filters"
    description: "Returns data for branch selected when looking at utilization by day"
  }

  filter: last_location_filter {
    suggest_explore: assets
    suggest_dimension: asset_last_location.last_location
    view_label: "Utilization Filters"
    description: "Returns data for last location selected when looking at utilization by day"
  }

  filter: used_unused_filter {
    suggest_explore: assets
    suggest_dimension: hourly_asset_usage_date_filter.used_or_unused_asset_string
    view_label: "Utilization Filters"
    description: "Returns data for used/unused assets selected when looking at utilization by day"
  }

  filter: asset_class_filter {
    suggest_explore: assets
    suggest_dimension: assets.asset_class
    view_label: "Utilization Filters"
    description: "Returns data for asset class selected when looking at utilization by day"
  }

  ######Need to write calculation to take the average of the averages per day....maybe needs to be a table calculation?

  set: detail {
    fields: [start_range_time_formatted, total_selected_on_time, total_selected_available_assets, dynamic_average_utilization_percentage_by_day]
  }
}
