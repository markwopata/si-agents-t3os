view: asset_last_parked {
  derived_table: {
    sql: with asset_list as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      union
      SELECT coalesce(ea.asset_id, r.asset_id) as asset_id
FROM es_warehouse.public.orders o
join es_warehouse.public.users u on u.user_id = o.user_id
join es_warehouse.public.rentals r on r.order_id = o.order_id
left join es_warehouse.public.equipment_assignments ea on ea.rental_id = r.rental_id and ea.end_date is null
join es_warehouse.public.rental_types rt on rt.rental_type_id = r.rental_type_id
WHERE
    r.rental_status_id = 5
AND
    u.company_id
        IN (
        SELECT u.company_id
        FROM es_warehouse.public.users u
        WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
        )
AND (
    u.user_id =
        CASE
            WHEN (
                SELECT security_level_id
                FROM es_warehouse.public.users u
                WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
            IN (1, 2)
            THEN u.user_id
            ELSE {{ _user_attributes['user_id'] }}::numeric
            END
            OR
            r.rental_id in (
            select r.rental_id
              from es_warehouse.public.rentals r
              join es_warehouse.public.orders o on o.order_id = r.order_id
              join es_warehouse.public.rental_location_assignments la on la.rental_id = r.rental_id
              join es_warehouse.public.geofences g on g.location_id = la.location_id
              join es_warehouse.public.organization_geofence_xref x on x.geofence_id = g.geofence_id
              join es_warehouse.public.organization_user_xref ux on ux.organization_id = x.organization_id
              where ux.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
    )
      )
    select
      a.asset_id,
      value as last_parked_timestamp,
      l.latitude,
      l.longitude
    from
      asset_list a
      inner join asset_status_key_values akv on a.asset_id = akv.asset_id
      left join (select asset_id, st_x(to_geography(value)) as longitude, st_y(to_geography(value)) as latitude from asset_status_key_values where name = 'location') l on l.asset_id = a.asset_id
    where
      akv.name = 'last_trip_end_timestamp'
      and akv.value is not null
 ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${latitude},${longitude}) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    #code for linking to where an asset is on a map
#     link: {
#       label: "Map Test"
#       url: "{% assign vis= '{\"map_plot_mode\":\"points\",
# \"heatmap_gridlines\":false,
# \"heatmap_gridlines_empty\":false,
# \"heatmap_opacity\":0.5,
# \"show_region_field\":true,
# \"draw_map_labels_above_data\":true,
# \"map_tile_provider\":\"streets\",
# \"map_position\":\"fit_data\",
# \"map_scale_indicator\":\"imperial\",
# \"map_pannable\":true,
# \"map_zoomable\":true,
# \"map_marker_type\":\"icon\",
# \"map_marker_icon_name\":\"checkmark\",
# \"map_marker_radius_mode\":\"proportional_value\",
# \"map_marker_units\":\"meters\",
# \"map_marker_proportional_scale_type\":\"linear\",
# \"map_marker_color_mode\":\"fixed\",
# \"show_view_names\":false,
# \"show_legend\":true,
# \"quantize_map_value_colors\":false,
# \"reverse_map_value_colors\":false,
# \"map_latitude\":28.185671470016807,
# \"map_longitude\":-87.35727310180664,
# \"map_zoom\":6,
# \"map_marker_color\":[],
# \"series_types\":{},
# \"type\":\"looker_map\",
# \"defaults_version\":1,
# \"hidden_fields\":[\"asset_last_parked.asset_id\",
# \"asset_last_parked.last_parked_buckets\"]}' %}

# {% assign dynamic_fields= '[]' %}

# {{link}}&f[asset_last_parked.asset_id]=&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}"
#     }
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: last_parked_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."LAST_PARKED_TIMESTAMP") ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: days_from_today {
    type: number
    sql: datediff(day,current_date,${last_parked_timestamp_date}) ;;
  }

  dimension: last_parked_buckets {
    type: string
    sql: case
    when ${days_from_today} = 0 then 'Today'
    when ${days_from_today} = -1 then 'Yesterday'
    when ${days_from_today} <= -2 and ${days_from_today} >= -7 then 'Last Week'
    when ${days_from_today} <= -8 and ${days_from_today} >= -28 then '2-4 Weeks'
    when ${days_from_today} <= -15 and ${days_from_today} >= -91 then '1-3 Months'
    when ${days_from_today} <= -92 and ${days_from_today} >= -183 then '3-6 Months'
    else '6+ Months'
    end
    ;;
  }

  dimension: ranking_last_bucket {
    type: number
    sql: case
    when ${last_parked_buckets} = 'Today' then 1
    when ${last_parked_buckets} = 'Yesterday' then 2
    when ${last_parked_buckets} = 'Last Week' then 3
    when ${last_parked_buckets} = '2-4 Weeks' then 4
    when ${last_parked_buckets} = '1-3 Months' then 5
    when ${last_parked_buckets} = '3-6 Months' then 6
    when ${last_parked_buckets} = '6+ Months' then 7
    end;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}."LATITUDE" ;;
    sql_longitude: ${TABLE}."LONGITUDE" ;;
  }

  dimension: last_parked_time_formatted {
    group_label: "Created" label: "Last Parked"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_parked_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  # dimension: distance_from_branch {
  #   type: distance
  #   start_location_field: location
  #   end_location_field: locations.test_mapping
  #   units: miles
  # }

  set: detail {
    fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, last_parked_timestamp_time, asset_last_location.location_address]
  }
}
