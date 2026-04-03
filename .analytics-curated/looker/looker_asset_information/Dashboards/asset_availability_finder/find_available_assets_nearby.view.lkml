
view: find_available_assets_nearby {
  derived_table: {
    sql: with user_location as (
      {% if searching_ability._parameter_value == "'Use My Home Market'" %}
      select
          cd.location,
          coalesce(l.latitude,'38.9566321') as user_lat,
          coalesce(l.longitude,'-92.2530969') as user_lon
      from
          analytics.payroll.company_directory cd
          left join es_warehouse.public.markets m on m.market_id = cd.market_id
          left join es_warehouse.public.locations l on l.location_id = m.location_id
      where
          lower(work_email) = lower('{{ _user_attributes['email'] }}')
      {% elsif searching_ability._parameter_value == "'Select Market'" %}
      select
          mrx.market_name,
          coalesce(l.latitude,'38.9566321') as user_lat,
          coalesce(l.longitude,'-92.2530969') as user_lon
      from
          analytics.public.market_region_xwalk mrx
          left join es_warehouse.public.markets m on m.market_id = mrx.market_id
          left join es_warehouse.public.locations l on l.location_id = m.location_id
      where
          {% condition branch_filter %} mrx.market_name {% endcondition %}
      {% else %}
      NULL
      {% endif %}
      )
      , asset_location as (
      select
      askv.asset_id,
      askv.value as inventory_status,
      a.make,
      a.model,
      --a.asset_class,
      REPLACE(ec.name, ',', '') as asset_class,
      mrx.market_name,
      m.sales_email,
      coalesce(loc.lat,l.latitude) as asset_lat,
      coalesce(loc.lon,l.longitude) as asset_lon,
      ll.last_location_timestamp,
      NULL as rental_start_date,
      NULL as rental_end_date,
      IFF(a.tracker_id is null,'No Tracker','Tracker') asset_has_tracker
      from
      es_warehouse.public.asset_status_key_values askv
      join es_warehouse.public.assets a on a.asset_id = askv.asset_id
      join es_warehouse.public.markets m on m.market_id = a.rental_branch_id
      join analytics.bi_ops.asset_ownership ao on ao.asset_id = a.asset_id
      join analytics.public.market_region_xwalk mrx on mrx.market_id = a.rental_branch_id
      left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
      left join es_warehouse.public.equipment_classes_models_xref ecm on ecm.equipment_model_id = em.equipment_model_id
      left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = ecm.equipment_class_id
      left join
          (
          select
          asset_id,
          st_y(to_geography(value)) as lat,
          st_x(to_geography(value)) as lon
          from
          es_warehouse.public.asset_status_key_values
          where name in ('location')
          ) loc on loc.asset_id = askv.asset_id
      left join
          (
          select
          asset_id,
          value as last_location_timestamp
          from
          es_warehouse.public.asset_status_key_values
          where
          name in ('last_location_timestamp')
          )
          ll on ll.asset_id = askv.asset_id
      left join es_warehouse.public.locations l on l.location_id = m.location_id
      where
      askv.name = 'asset_inventory_status'
      AND (askv.value is not null AND askv.value not in ('On Rent','Assigned', 'Pre-Delivered'))
      AND ao.rentable = TRUE
      AND ao.ownership in ('ES', 'OWN', 'CUSTOMER', 'RETAIL')
      AND ao.market_company_id = 1854
      --AND a.asset_class = 'Electric Scissor Lift, 19'' Narrow'
      AND {% condition asset_class_filter %} REPLACE(a.asset_class, ',', '') {% endcondition %}
      AND {% condition make_filter %} a.make {% endcondition %}
      AND {% condition model_filter %} a.model {% endcondition %}
      {% if show_assigned_assets._parameter_value == "'No'" %}
      {% else %}
      UNION
      select
      askv.asset_id,
      askv.value as inventory_status,
      a.make,
      a.model,
      --a.asset_class,
      REPLACE(ec.name, ',', '') as asset_class,
      mrx.market_name,
      m.sales_email,
      coalesce(loc.lat,l.latitude) as asset_lat,
      coalesce(loc.lon,l.longitude) as asset_lon,
      ll.last_location_timestamp,
      r.start_date::date as rental_start_date,
      r.end_date::date as rental_end_date,
      IFF(a.tracker_id is null,'No Tracker','Tracker') asset_has_tracker
      from
      es_warehouse.public.asset_status_key_values askv
      join es_warehouse.public.assets a on a.asset_id = askv.asset_id
      join es_warehouse.public.markets m on m.market_id = a.rental_branch_id
      join analytics.bi_ops.asset_ownership ao on ao.asset_id = a.asset_id
      join analytics.public.market_region_xwalk mrx on mrx.market_id = a.rental_branch_id
      left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
      left join es_warehouse.public.equipment_classes_models_xref ecm on ecm.equipment_model_id = em.equipment_model_id
      left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = ecm.equipment_class_id
      join es_warehouse.public.equipment_assignments ea on ea.asset_id = askv.asset_id AND ea.end_date is null
      left join es_warehouse.public.rentals r on r.rental_id = ea.rental_id
      left join
          (
          select
          asset_id,
          st_y(to_geography(value)) as lat,
          st_x(to_geography(value)) as lon
          from
          es_warehouse.public.asset_status_key_values
          where name in ('location')
          ) loc on loc.asset_id = askv.asset_id
      left join
          (
          select
          asset_id,
          value as last_location_timestamp
          from
          es_warehouse.public.asset_status_key_values
          where
          name in ('last_location_timestamp')
          )
          ll on ll.asset_id = askv.asset_id
      left join es_warehouse.public.locations l on l.location_id = m.location_id
      where
      askv.name = 'asset_inventory_status'
      AND (askv.value is not null AND askv.value in ('Assigned'))
      AND ao.rentable = TRUE
      AND ao.ownership in ('ES', 'OWN', 'CUSTOMER', 'RETAIL')
      AND ao.market_company_id = 1854
      --AND a.asset_class = 'Electric Scissor Lift, 19'' Narrow'
      AND {% condition asset_class_filter %} REPLACE(a.asset_class, ',', '') {% endcondition %}
      AND {% condition make_filter %} a.make {% endcondition %}
      AND {% condition model_filter %} a.model {% endcondition %}
      {% endif %}
      )
      select
      al.asset_id,
      al.asset_class,
      al.make,
      al.model,
      al.market_name,
      al.sales_email,
      al.inventory_status,
      al.last_location_timestamp,
      IFF((DATEDIFF(hours,al.last_location_timestamp,current_timestamp) >= 120),TRUE,FALSE) as unstable_tracker_location,
      (haversine(user_lat,user_lon, asset_lat, asset_lon) * 0.621371) as distance,
      asset_lat,
      asset_lon,
      al.rental_start_date,
      al.rental_end_date,
      al.asset_has_tracker
      from
      asset_location al
      join user_location ul on 1=1
      where
      {% if miles_away._parameter_value == "'All Company'" %}
      1=1
      {% else %}
      round(distance,2) <= ({% parameter miles_away %})
      {% endif %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
    required_fields: [make,model]
    html:
    {{rendered_value}}
    <td>
    <span style="color: #C0C0C0;"> {{make._value}} - {{model._value}}</span>
    </td>;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: sales_email {
    label: "Market Email"
    type: string
    sql: ${TABLE}."SALES_EMAIL" ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension: last_location_timestamp {
    type: date
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: unstable_tracker_location {
    type: number
    sql: ${TABLE}."UNSTABLE_TRACKER_LOCATION" ;;
  }

  dimension: distance {
    type: number
    sql: ${TABLE}."DISTANCE" ;;
  }

  dimension: asset_lat {
    type: number
    sql: ${TABLE}."ASSET_LAT" ;;
  }

  dimension: asset_lon {
    type: number
    sql: ${TABLE}."ASSET_LON" ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: asset_has_tracker {
    type: string
    sql: ${TABLE}."ASSET_HAS_TRACKER" ;;
  }

  dimension: asset_location {
    type: location
    sql_latitude: ${asset_lat} ;;
    sql_longitude: ${asset_lon} ;;
  }

  measure: miles_from_home_store {
    label: "Miles from Market"
    type: sum
    sql: ${distance} ;;
    value_format_name: decimal_0
  }

  dimension: market_and_email {
    group_label: "Custom Market"
    label: "Market"
    type: string
    sql: ${market_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/342?Manager+Name=&Work+Phone=&Market+Name={{filterable_value | url_encode}}"target="_blank"><b>{{rendered_value}} ➔ </b></a></font>
    <td>
    <span style="color: #C0C0C0;"> {{sales_email._value}} </span>
    </td>;;
  }

  dimension: asset_tracker {
    label: "Asset"
    type: string
    sql: ${asset_id} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/169?Asset%20ID={{rendered_value}}"target="_blank"><b>{{rendered_value}} ➔ </b></a></font>
    <td>
    {% if unstable_tracker_location._rendered_value == '0' %}

      {% else %}
      <span style="color: #1b1b1b;"><b>Stale GPS </b></span>
      {% endif %}
    {% if asset_has_tracker._rendered_value == 'Tracker' %}

      {% else %}
      <span style="color: #1b1b1b;"><b>No Tracker </b></span>
      {% endif %}
    </td>;;
  }
  # Old Code under assets
  # <span style="color: #C0C0C0;">Last Tracker Location Date: <b>{{last_location_timestamp._rendered_value}} </b></span>

  dimension: inventory_status_formatted {
    group_label: "Custom Inventory Status"
    label: "Inventory Status"
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
    required_fields: [rental_start_date,rental_end_date]
    html: {% if value == 'Ready To Rent' %}

          <span style="color: #00CB86;">◉ </span>{{rendered_value}}

          {% elsif value == 'Soft Down' %}

          <span style="color: #d47376;">◉ </span>{{rendered_value}}

          {% elsif value == 'Needs Inspection' %}

          <span style="color: #FFBF00;">◉ </span>{{rendered_value}}

          {% elsif value == 'Pending Return' %}

          <span style="color: #8C8C8C;">◉ </span>{{rendered_value}}

          {% elsif value == 'Pre-Delivered' %}

          <span style="color: #DCDCDC;">◉ </span>{{rendered_value}}

          {% elsif value == 'Hard Down' %}

          <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

          {% elsif value == 'Make Ready' %}

          <span style="color: #ffad6a;">◉ </span>{{rendered_value}}

          {% elsif value == 'Assigned' %}

          <span style="color: #DCDCDC;">◉ </span>
          {{rendered_value}}
          {% if show_assigned_assets._parameter_value == "'No'" %}
          {% else %}
          <td>
          <span style="color: #C0C0C0;">Rental Dates: <br />{{ rental_start_date._rendered_value }} - {{ rental_end_date._rendered_value }}</span>
          </td>
          {% endif %}
          {% else %}

          {% endif %};;
  }
  # ❯ old arrow shown for inventory status format

  # parameter: miles_away {
  #   type: string
  #   allowed_value: { value: "50"}
  #   allowed_value: { value: "100"}
  #   allowed_value: { value: "150"}
  #   allowed_value: { value: "200"}
  #   allowed_value: { value: "250"}
  #   allowed_value: { value: "300"}
  #   allowed_value: { value: "350"}
  #   allowed_value: { value: "400"}
  #   allowed_value: { value: "450"}
  #   allowed_value: { value: "500"}
  #   allowed_value: { value: "All Company"}
  # }

  parameter: miles_away {
    type: number
    description: "Input Max Miles Away to Find an Asset"
    default_value: "150"
  }

  parameter: searching_ability {
    type: string
    allowed_value: { value: "Use My Home Market"}
    allowed_value: { value: "Select Market"}
  }

  parameter: show_assigned_assets {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  filter: asset_class_filter {
  }

  filter: make_filter {
  }

  filter: model_filter {
  }

  filter: branch_filter {
  }

  set: detail {
    fields: [
        asset_id,
  asset_class,
  market_name,
  sales_email,
  inventory_status_formatted
    ]
  }
}
