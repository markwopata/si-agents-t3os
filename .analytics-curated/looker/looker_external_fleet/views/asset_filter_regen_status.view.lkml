view: asset_filter_regen_status {
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
        akv.value as filter_regen_status,
        akv.updated
      from
          asset_list a
          inner join asset_status_key_values akv on a.asset_id = akv.asset_id
      where
          akv.name = 'diesel_particles_filter_regen_status'
          and akv.value is not null
          --and asset_id in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
       ;;
  }

  measure: count {
    type: count
    drill_fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, filter_status, asset_last_location.location_address]
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: filter_regen_status {
    type: string
    sql: ${TABLE}."FILTER_REGEN_STATUS" ;;
  }

  dimension_group: updated {
    type: time
    sql: ${TABLE}."UPDATED" ;;
  }

  dimension: filter_status {
    type: string
    sql: case when ${filter_regen_status} = 0 then 'Excellent'
    when ${filter_regen_status} = 1 then 'Good'
    when ${filter_regen_status} = 2 then 'Warning'
    when ${filter_regen_status} = 3 then 'Critical'
    when ${filter_regen_status} = 4 then 'Failure'
    end
    ;;
  }

  dimension: ranking_filter_status {
    type: number
    sql: case
          when ${filter_status} = 'Excellent' then 1
          when ${filter_status} = 'Good' then 2
          when ${filter_status} = 'Warning' then 3
          when ${filter_status} = 'Critical' then 4
          when ${filter_status} = 'Failure' then 5
          else 6
          end;;
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${count} ;;
  }

  set: detail {
    fields: [assets.custom_name, filter_status, updated_time]
  }
}
