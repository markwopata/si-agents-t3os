view: yardz_rental_export {
  derived_table: {
    sql: SELECT
          'PATRIOT EQUIPMENT RENTAL & SALES, INC.' as company,
          r.rental_id as contract_number,
          a.asset_class as equipment_description,
          a.custom_name as equipment_number,
          po.name as po,
          coalesce(r.quantity,1) as quantity,
          a.serial_number,
          r.start_date::date as start_date,
          r.end_date::date as est_return_date,
          coalesce(dl.nickname,' ') as job_name,
          a.make,
          a.model,
          a.year,
          r.price_per_day as day_rate,
          r.price_per_week as week_rate,
          r.price_per_month as month_rate,
          ll.latitude,
          ll.longitude,
          round(h.hours,2) as operating_hours,
          round(od.odometer,2) as miles,
          llt.last_location_timestamp::date as location_date,
          concat(HOUR(to_timestamp(llt.last_location_timestamp)),':',MINUTE(to_timestamp(llt.last_location_timestamp))) as location_time,
          h.updated::date as hours_date,
          concat(HOUR(to_timestamp(h.updated)),':',MINUTE(to_timestamp(h.updated))) as hours_time,
          od.updated::date as mileage_date,
          concat(HOUR(to_timestamp(od.updated)),':',MINUTE(to_timestamp(od.updated))) as mileage_time
      from
          rentals r
          left join equipment_assignments ea on r.rental_id = ea.rental_id
          left join assets a on a.asset_id = ea.asset_id
          left join rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join orders o on r.order_id = o.order_id
          left join users u on u.user_id = o.user_id
          join companies c on c.company_id = u.company_id
          left join deliveries d on d.delivery_id = r.drop_off_delivery_id
          left join locations dl on dl.location_id = d.location_id
          left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join (select asset_id,value as hours, updated from asset_status_key_values where name = 'hours') h on h.asset_id = a.asset_id
          left join (select asset_id,value as odometer, updated from asset_status_key_values where name = 'odometer') od on od.asset_id = a.asset_id
          left join (select asset_id,value as last_location_timestamp from asset_status_key_values where name = 'last_location_timestamp') llt on llt.asset_id = a.asset_id
          left join
                  (select
                       asset_id,
                       st_y(to_geography(value)) as latitude,
                       st_x(to_geography(value)) as  longitude
                   from
                      es_warehouse.public.asset_status_key_values
                   where
                      name in ('location')) ll on ll.asset_id = a.asset_id
      where
        c.company_id in (
        59389
        )
        AND (
        (r.rental_status_id = 5 AND (ea.end_date >= current_timestamp() or ea.end_date is null))
        OR (ea.end_date >= current_timestamp AND ea.start_date <= current_timestamp)
        OR r.rental_status_id = 5 AND r.asset_id is null
        )
        and r.deleted = false
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: contract_number {
    type: number
    sql: ${TABLE}."CONTRACT_NUMBER" ;;
    value_format_name: id
  }

  dimension: equipment_description {
    type: string
    sql: ${TABLE}."EQUIPMENT_DESCRIPTION" ;;
  }

  dimension: equipment_number {
    type: string
    sql: ${TABLE}."EQUIPMENT_NUMBER" ;;
    value_format_name: id
  }

  dimension: po {
    label: "PO"
    type: string
    sql: ${TABLE}."PO" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: est_return_date {
    type: date
    sql: ${TABLE}."EST_RETURN_DATE" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
    value_format_name: usd
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
    value_format_name: usd
  }

  dimension: month_rate {
    type: number
    sql: ${TABLE}."MONTH_RATE" ;;
    value_format_name: usd
  }

  dimension: latitude {
    type: string
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: string
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: operating_hours {
    type: number
    sql: ${TABLE}."OPERATING_HOURS" ;;
    value_format_name: decimal_2
  }

  dimension: miles {
    type: number
    sql: ${TABLE}."MILES" ;;
    value_format_name: decimal_2
  }

  dimension: location_date {
    type: date
    sql: ${TABLE}."LOCATION_DATE" ;;
  }

  dimension: location_time {
    type: string
    sql: ${TABLE}."LOCATION_TIME" ;;
  }

  dimension: hours_date {
    type: date
    sql: ${TABLE}."HOURS_DATE" ;;
  }

  dimension: hours_time {
    type: string
    sql: ${TABLE}."HOURS_TIME" ;;
  }

  dimension: mileage_date {
    type: date
    sql: ${TABLE}."MILEAGE_DATE" ;;
  }

  dimension: mileage_time {
    type: string
    sql: ${TABLE}."MILEAGE_TIME" ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}."latitude" ;;
    sql_longitude: ${TABLE}."longitude" ;;
  }

  set: detail {
    fields: [
      company,
      contract_number,
      equipment_description,
      equipment_number,
      po,
      quantity,
      serial_number,
      start_date,
      est_return_date,
      job_name,
      make,
      model,
      year,
      day_rate,
      week_rate,
      month_rate,
      latitude,
      longitude,
      operating_hours,
      miles,
      location_date,
      location_time,
      hours_date,
      hours_time,
      mileage_date,
      mileage_time,
      location
    ]
  }
}
