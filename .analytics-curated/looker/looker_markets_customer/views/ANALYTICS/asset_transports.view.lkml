view: asset_transports {
  derived_table: {
    sql:
      select
        d.date_created delivery_created,
        d.completed_date,
        d.scheduled_date,
        d.delivery_id,
        d.order_id,
        d.note,
        concat(u1.first_name, ' ', u1.last_name) driver,
        concat(u2.first_name, ' ', u2.last_name) completed_by,
        d.asset_id,
        d.completed_by_user_id,
        ds.name delivery_status,
        mrx.market_name,
        mrx.district,
        mrx.region_name,
        concat(l.city, ', ', s.name) origin,
        a.name,
        a.asset_class,
        dft.name facilitator
      from es_warehouse.public.deliveries d
      join es_warehouse.public.delivery_statuses ds on d.delivery_status_id = ds.delivery_status_id
      join es_warehouse.public.orders o on d.order_id = o.order_id
      join analytics.public.market_region_xwalk mrx on o.market_id = mrx.market_id
      left join es_warehouse.public.locations l on d.origin_location_id = l.location_id
      left join es_warehouse.public.states s on l.state_id = s.state_id
      left join es_warehouse.public.users u1 on d.driver_user_id = u1.user_id
      left join es_warehouse.public.users u2 on d.completed_by_user_id = u2.user_id
      join es_warehouse.public.assets a on d.asset_id = a.asset_id
      left join es_warehouse.public.delivery_facilitator_types dft on d.facilitator_type_id = dft.delivery_facilitator_type_id
      where d.rental_id is null
      and d.date_created >= '2024-01-01'
      ;;
  }

  dimension: delivery_created {
    type: date
    sql: ${TABLE}.delivery_created ;;
  }

  dimension_group: completed_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMPLETED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: facilitator {
    type: string
    sql: ${TABLE}."FACILITATOR" ;;
  }

  dimension_group: scheduled_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SCHEDULED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
  }

  dimension: driver {
    type: string
    sql: ${TABLE}.driver ;;
  }

  dimension: completed_by {
    type: string
    sql: ${TABLE}.completed_by ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: completed_by_user_id {
    type: number
    sql: ${TABLE}.completed_by_user_id ;;
  }

  dimension: delivery_status {
    type: string
    sql: ${TABLE}.delivery_status ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: origin {
    type: string
    sql: ${TABLE}.origin ;;
  }

  dimension: formatted_completed_date {
    group_label: "HTML Formatted Date"
    label: "Completed Date"
    type: date
    datatype: date
    sql: ${TABLE}.completed_date ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }

  dimension: formatted_scheduled_date {
    group_label: "HTML Formatted Date"
    label: "Scheduled Date"
    type: date
    datatype: date
    sql: ${TABLE}.scheduled_date ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }

  dimension: formatted_delivery_created {
    group_label: "HTML Formatted Date"
    label: "Delivery Created"
    type: date
    datatype: date
    sql: ${TABLE}.delivery_created ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }

  dimension: asset_id_html {
    group_label: "Asset ID HTML"
    label: "Asset ID"
    sql: ${asset_id} ;;
    html:
    <a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id._value}}" style='color: blue;'
    target="_blank"><b>{{asset_id._value}}</b> ➔</a>
    ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: delivery_id {
    type: string
    sql: ${TABLE}.delivery_id ;;
  }

  measure: delivery_count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_id_html {
    group_label: "Order ID HTML"
    label: "Order ID"
    sql: ${order_id} ;;
    html:
    <a href="https://admin.equipmentshare.com/#/home/orders/{{order_id._value}}/transports/{{delivery_id._value}}" style='color: blue;'
    target="_blank"><b>{{order_id._value}}</b> ➔</a>
    ;;
  }



  set: detail {
    fields: [
      formatted_scheduled_date,
      formatted_completed_date,
      delivery_status,
      market,
      origin,
      asset_id_html,
      asset_class,
      driver,
      completed_by,
      note
      ]
  }

}
