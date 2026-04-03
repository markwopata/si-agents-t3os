view: hourly_asset_usage_date_filter {
  view_label: "Asset Total Utilization"
  derived_table: {
    sql:
    with date_series as (
select
  series::date as day,
  dayname(series::date) as day_name
from table
  (generate_series(
  convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %})::timestamp_tz,
  convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %})::timestamp_tz,
  'day')
)),
day_selection as (
select
    ds.day,
    case when ds.day_name in ('Sat','Sun') then 1 else 0 end as weekend_flag
from
    date_series ds
),
total_weekend_days_selected as (
select
    1 as flag,
    sum(weekend_flag) as total_weekend_days
from
    day_selection
where
  day <= current_date
),
asset_list_own as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    )
    ,own_available_dates as (
    select
        al.asset_id,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date as start_date,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date as end_date,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        sum(miles_driven) as miles_driven
    from
        asset_list_own al
        left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
    where
        report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date - interval '10 days'))
        AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date))
    group by
        al.asset_id,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date
    )
    ,asset_list_rental as (
    select asset_id, start_date, end_date
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
    ),
    rental_available_dates as (
    select
        alr.asset_id,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date as rental_start_date,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date as rental_end_date,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        sum(miles_driven) as miles_driven
    from
        asset_list_rental alr
        left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
    where
        report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC',{% date_start date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date - interval '10 days'))
        AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date))
    group by
        alr.asset_id,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:start_range)::date,
        convert_timezone('{{ _user_attributes['company_timezone'] }}',report_range:end_range)::date
    )
    ,possible_utilization_days as (
    select
        alr.asset_id,
        ---alr.start_date::date,
        --current_date,
        --alr.end_date::date,
        case
        when alr.end_date::date = convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::date then 1
        when
        alr.start_date::date = current_date and (alr.end_date::date >= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz) OR alr.end_date::date < convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)) then
        1
        when
        alr.start_date::date <= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::date and alr.end_date <= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::date then
        datediff(day,convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::date,alr.end_date::date)+1
        when
        alr.start_date::date >= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz) and end_date::date >= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz) then
        datediff(day,alr.start_date::date,convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz))
        when
        alr.start_date::date >= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz) and end_date::date <= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz) then
        datediff(day,alr.start_date::date,alr.end_date::date)
        when
        alr.start_date::date <= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz) and end_date::date <= convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz) then
        datediff(day,convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),alr.end_date::date)
        else
        datediff(day,convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz))
        end as possible_utilization_days
    from
        asset_list_rental alr
    union
    select
       alo.asset_id,
       datediff(day,convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)) as possible_utilization_days
    from
       asset_list_own alo
    )
    ,utilization_info as (
    select
        alo.asset_id,
        'own' as ownership_type,
        start_date,
        end_date,
        1 as weekend_flag,
        case when start_date is not null then 1 end as days_used,
        --count(distinct(start_date)) as days_used,
        --possible_utilization_days,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        round(sum(miles_driven),1) as miles_driven
    from
        asset_list_own alo
        left join own_available_dates oad on alo.asset_id = oad.asset_id
        --join possible_utilization_days pud on pud.asset_id = alo.asset_id
    group by
        alo.asset_id,
        start_date,
        end_date
        --,possible_utilization_days
    UNION
    select
        alr.asset_id,
        'rented' as ownership_type,
        rental_start_date as start_date,
        rental_end_date as end_date,
        1 as weekend_flag,
        case when rental_start_date is not null then 1 end as days_used,
        --count(distinct(start_date)) as days_used,
        --possible_utilization_days,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        round(sum(miles_driven),1) as miles_driven
    from
        asset_list_rental alr
        left join rental_available_dates rad on alr.asset_id = rad.asset_id
        --join possible_utilization_days pud on pud.asset_id = alr.asset_id
    group by
        alr.asset_id,
        rental_start_date,
        rental_end_date
    )
    ,summarize_utilization_info as (
    select
        asset_id,
        ownership_type,
        1 as weekend_flag,
        sum(days_used) as days_used,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        sum(miles_driven) as miles_driven
     from
        utilization_info
     group by
        asset_id,
        ownership_type
     )
     ,asset_status as (
     select asset_id, 'active' as rental_status
     from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', CURRENT_DATE()::timestamp_ntz), convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', CURRENT_DATE()::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
     union
     select asset_id, 'active' as rental_status
     from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
     )
    select
        ui.asset_id,
        ui.ownership_type,
        sum(pud.possible_utilization_days) as possible_utilization_days,
        twd.total_weekend_days,
        coalesce(ast.rental_status,'non-active') as rental_status,
        coalesce(days_used,0) as days_used,
        coalesce(on_time,0) as on_time,
        coalesce(idle_time,0) as idle_time,
        coalesce(miles_driven,0) as miles_driven
    from
        summarize_utilization_info ui
        join possible_utilization_days pud on pud.asset_id = ui.asset_id
        join total_weekend_days_selected twd on twd.flag = ui.weekend_flag
        left join asset_status ast on ast.asset_id = ui.asset_id
    where
       pud.possible_utilization_days >= 0
    group by
        ui.asset_id,
        ui.ownership_type,
        twd.total_weekend_days,
        coalesce(ast.rental_status,'non-active'),
        coalesce(days_used,0),
        coalesce(on_time,0),
        coalesce(idle_time,0),
        coalesce(miles_driven,0)
      ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    hidden: yes
  }

  dimension: ownership_type {
    type: string
    sql: ${TABLE}."OWNERSHIP_TYPE" ;;
    hidden: yes
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
    hidden: yes
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
    hidden: yes
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
    hidden: yes
  }

  dimension: days_used {
    type: number
    sql: ${TABLE}."DAYS_USED" ;;
    hidden: yes
  }

  dimension: possible_utilization_days {
    type: number
    sql: ${TABLE}."POSSIBLE_UTILIZATION_DAYS" ;;
    hidden: yes
  }

  dimension: total_weekend_days {
    type: number
    sql: ${TABLE}."TOTAL_WEEKEND_DAYS" ;;
    hidden: yes
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
    hidden: yes
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${ownership_type},${possible_utilization_days}) ;;
    hidden: yes
  }

  filter: date_filter {
    type: date
    view_label: "Required Filter"
  }

  measure: total_on_time {
    label: "Run Time Hours"
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    value_format_name: decimal_2
    sql_distinct_key: ${primary_key}||${on_time}||${assets.asset_id} ;;
  }

  measure: total_idle_time {
    label: "Idle Time Hours"
    type: sum
    sql: ${idle_time}/3600 ;;
    value_format_name: decimal_2
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [trip_detail*]
  }

  measure: total_days_used {
    type: sum
    sql: ${days_used} ;;
    link: {
      label: "View Trip Log"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&sorts=trip_details.trip_start_time_formatted+asc&f[assets.custom_name]=&f[assets.ownership_type]=&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}"
    }
  }

  measure: total_days_unused {
    type: number
    sql: ${date_filter_difference} - ${used_asset_count} ;;
  }

  dimension: unused_assets {
    type: number
    sql: case when ${on_time}=0 or ${on_time} is null then ${primary_key}
      else null
      end;;
    hidden: yes
  }

  measure: unused_asset_count {
    type: count_distinct
    sql: ${unused_assets} ;;
  }

  dimension: used_assets {
    type: number
    sql: case when ${on_time} > 0 then 1
      else null
      end;;
    hidden: yes
  }

  measure: used_asset_count {
    type: count_distinct
    sql: ${used_assets} ;;
  }

  measure: distinct_asset_id_count {
    type: count_distinct
    label: "  Count"
    sql: ${asset_id} ;;
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
    drill_fields: [chart_drill_opt*]
  }

  dimension: count_asset {
    type: number
    sql: case when ${on_time} > 0 or ${on_time}=0 or ${on_time} is null then 1 else null end  ;;
    hidden: yes
  }

  measure: count_possible_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  dimension: date_filter_difference {
    type: number
    sql: datediff(day,COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date - interval '10 days')),COALESCE(convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz),convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', current_date))) ;;
    hidden: yes
  }

  parameter: utilization_hours {
    type: string
    allowed_value: { value: "1 Hour"}
    allowed_value: { value: "2 Hours"}
    allowed_value: { value: "3 Hours"}
    allowed_value: { value: "4 Hours"}
    allowed_value: { value: "5 Hours"}
    allowed_value: { value: "6 Hours"}
    allowed_value: { value: "7 Hours"}
    allowed_value: { value: "8 Hours"}
    allowed_value: { value: "10 Hours"}
    allowed_value: { value: "12 Hours"}
    allowed_value: { value: "24 Hours"}
    view_label: "Utilization Hours Options"
    description: "Used to select hours per workday"
  }

  measure: dynamic_utilization_percentage {
    label_from_parameter: utilization_hours
    sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
      round(${utilization_percentage_eight_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      round(${utilization_percentage_ten_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      round(${utilization_percentage_twelve_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      round(${utilization_percentage_twenty_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      round(${utilization_percentage_one_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      round(${utilization_percentage_two_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      round(${utilization_percentage_three_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      round(${utilization_percentage_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      round(${utilization_percentage_five_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      round(${utilization_percentage_six_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      round(${utilization_percentage_seven_hours}*100,1)
    {% else %}
      NULL
    {% endif %} ;;
    html: {{value}}% ;;
    # value_format_name: percent_1
  }

  measure: dynamic_average_utilization_percentage {
    label_from_parameter: utilization_hours
    sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
      round(${average_utilization_kpi_eight_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      round(${average_utilization_kpi_ten_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      round(${average_utilization_kpi_twelve_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      round(${average_utilization_kpi_twenty_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      round(${average_utilization_kpi_one_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      round(${average_utilization_kpi_two_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      round(${average_utilization_kpi_three_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      round(${average_utilization_kpi_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      round(${average_utilization_kpi_five_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      round(${average_utilization_kpi_six_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      round(${average_utilization_kpi_seven_hours}*100,1)
    {% else %}
      NULL
    {% endif %} ;;
    html: {{value}} ;;
    # value_format_name: percent_1
  }

  measure: utilization_percentage_eight_hours {
    type: number
    sql: ${total_on_time}/(8*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: total_weekend_days_selected {
    type: sum
    sql: ${total_weekend_days} ;;
  }

  measure: utilization_percentage_ten_hours {
    type: number
    sql: ${total_on_time}/(10*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_twelve_hours {
    type: number
    sql: ${total_on_time}/(12*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_twenty_four_hours {
    type: number
    sql: ${total_on_time}/(24*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_one_hours {
    type: number
    sql: ${total_on_time}/(1*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_two_hours {
    type: number
    sql: ${total_on_time}/(2*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_three_hours {
    type: number
    sql: ${total_on_time}/(3*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_four_hours {
    type: number
    sql: ${total_on_time}/(4*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_five_hours {
    type: number
    sql: ${total_on_time}/(5*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_six_hours {
    type: number
    sql: ${total_on_time}/(6*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: utilization_percentage_seven_hours {
    type: number
    sql: ${total_on_time}/(7*(case when ${total_possible_utilization_days} = 0 then null else ${total_possible_utilization_days} end)) ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: total_possible_utilization_days {
    type: sum
    sql: ${possible_utilization_days} ;;
    hidden: yes
  }

  measure: days_with_no_utilization {
    type: number
    sql: ${total_possible_utilization_days} - ${total_days_used} ;;
    # sql: ${date_filter_difference} - ${total_days_used} ;;
  }

  measure: average_on_time_hours {
    type: number
    sql: (coalesce((${total_on_time}),0)/${count_possible_assets}) ;;
    value_format_name: decimal_2
  }

  measure: total_miles_driven {
    type: sum
    sql: ${miles_driven} ;;
  }

  measure: testing {
    type: number
    sql: (case when (${unused_asset_count} + ${used_asset_count}) = 0 then null else (${unused_asset_count} + ${used_asset_count}) end) ;;
    hidden: yes
  }

  measure: average_utilization_kpi_eight_hours {
    type: number
    sql:
    case
    when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((8*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((8)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end
    ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_ten_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((10*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((10)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((10)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_twelve_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((12*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((12)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((12)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_twenty_four_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((24*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((24)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((24)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_one_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((1*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((1)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((1)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_two_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((2*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((2)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((2)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_three_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((3*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((3)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((3)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_four_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((4*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((4)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((4)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_five_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((5*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((5)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((5)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_six_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((6*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((6)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((6)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  measure: average_utilization_kpi_seven_hours {
    type: number
    sql:
    case when ${date_filter_difference} >= 5 then
    ((${total_on_time})/((7*5/7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when (${date_filter_difference} = 1 AND ${total_weekend_days_selected} = 1) OR (${date_filter_difference} = 2 AND ${total_weekend_days_selected} = 2) then
    ((${total_on_time})/((8)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} >= 1 then
    ((${total_on_time})/((7)*(${date_filter_difference}-${total_weekend_days_selected})))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    when ${date_filter_difference} < 5 AND ${total_weekend_days_selected} = 0 then
    ((${total_on_time})/((7)*${date_filter_difference}))/(case when (${count_possible_assets}) = 0 then null else (${count_possible_assets}) end)
    end ;;
    value_format_name: percent_1
    hidden: yes
  }

  dimension: used_or_unused_asset_string {
    type: string
    sql: case when ${on_time} > 0 then 'Used Asset' when ${on_time} is null and ${assets.tracker_id} is null then 'No Tracker' Else 'Unused Asset' END ;;
  }

  measure: equipment_run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    filters: [asset_types.name: "equipment"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  measure: trailer_run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    filters: [asset_types.name: "trailer"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  measure: vehicle_run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    filters: [asset_types.name: "vehicle"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${distinct_asset_id_count} ;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    hidden: yes
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${asset_last_location_history.location} ;;
    required_fields: [asset_id,current_date]
    # html: <font color="blue "><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ asset_id._value }}/history?selectedDate={{ max_end_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
    description: "A link will only appear if the rental is still active or if you own the asset."
    html:
    {% if rental_status._value == "active" %}
         <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ hourly_asset_usage_date_filter.asset_id._rendered_value }}/history?selectedDate={{ hourly_asset_usage_date_filter.current_date._rendered_value}}" target="_blank">{{value}}</a></font></u>
       {% else %}
         <p>{{ rendered_value }}</p>
       {% endif %} ;;
  }

  set: detail {
    fields: [
      assets.custom_name, asset_utilization_by_day_date_filter.start_range_time_formatted, assets.make, assets.model,
      assets.ownership_type, organizations.asset_groups, total_on_time, total_idle_time
    ]
  }
  # start_range_time_formatted, --went to detail drill set

  set: trip_detail {
    fields: [assets.custom_name, trip_details.trip_start_time_formatted,
      trip_details.start_location, trip_details.trip_end_time_formatted,
      trip_detail.end_location, trip_details.trip_miles, trip_details.total_trip_hours, trip_details.total_idle_hours
    ]
  }

  set: chart_drill_opt {
    fields: [
      assets.custom_name, assets.make, assets.model,
      asset_odometer_based_off_date_selection.odometer, asset_last_location.last_location, asset_last_location.last_contact_time_formatted, hourly_asset_usage_date_filter.total_on_time, hourly_asset_usage_date_filter.total_idle_time
    ]
  }

}
