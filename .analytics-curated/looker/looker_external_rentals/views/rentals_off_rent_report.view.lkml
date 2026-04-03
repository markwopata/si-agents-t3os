view: rentals_off_rent_report {
  derived_table: {
    sql: with asset_list_rental as (
          select asset_id, start_date, end_date, rental_id
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}), '{{ _user_attributes['user_timezone'] }}'))
          --from table(rental_asset_list(33416::numeric, convert_timezone('America/Chicago', 'UTC', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz), convert_timezone('America/Chicago', 'UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))::timestamp_ntz), 'America/Chicago'))
          )
          select
                r.rental_id,
                r.asset_id,
                convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.start_date::timestamp_ntz)::date as rental_start_date,
                convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.end_date::timestamp_ntz)::date as rental_end_date,
                --r.start_date::date as rental_start_date,
                --r.end_date::date as rental_end_date,
                po.name as po_name,
                l.nickname as jobsite,
                a.asset_class,
                r.price_per_day,
                r.price_per_week,
                r.price_per_month,
                o.order_id,
                concat(a.make,' ',a.model) as make_and_model,
                a.custom_name as custom_name,
                r.rental_status_id,
                concat(u.first_name,' ',u.last_name) as ordered_by,
                cm.name as vendor
            from
                asset_list_rental alr
                inner join rentals r on r.rental_id = alr.rental_id and r.asset_id = alr.asset_id
                left join orders o on r.order_id = o.order_id
                left join users u on u.user_id = o.user_id
                left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
                left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= {% date_end date_filter %}::date AND rla.start_date >= {% date_start date_filter %}::date))
                left join locations l on l.location_id = rla.location_id
                left join assets a on a.asset_id = r.asset_id
                left join companies c on c.company_id = u.user_id
                left join markets m on m.market_id = o.market_id
                left join companies cm on cm.company_id = m.company_id
            where
              u.company_id = {{ _user_attributes['company_id'] }}
              and po.company_id = {{ _user_attributes['company_id'] }}
              and l.company_id = {{ _user_attributes['company_id'] }}
              and r.deleted = false
              and r.end_date BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
              and r.rental_status_id NOT IN (1,2,3,4,5)
          union
            select
                r.rental_id,
                r.asset_id,
                convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.start_date::timestamp_ntz)::date as rental_start_date,
                convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.end_date::timestamp_ntz)::date as rental_end_date,
                --r.start_date::date as rental_start_date,
                --r.end_date::date as rental_end_date,
                po.name as po_name,
                l.nickname as jobsite,
                pt.description as asset_class,
                r.price_per_day,
                r.price_per_week,
                r.price_per_month,
                o.order_id,
                concat('Bulk Item - ',p.part_id) as make_and_model,
                'Bulk Item' as custom_name,
                r.rental_status_id,
                concat(u.first_name,' ',u.last_name) as ordered_by,
                cm.name as vendor
            from
              rentals r
              join rental_part_assignments rpa on rpa.rental_id = r.rental_id
              join inventory.parts p on p.part_id = rpa.part_id
              left join inventory.part_types pt on pt.part_type_id = p.part_type_id
              left join orders o on r.order_id = o.order_id
              left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
              left join users u on u.user_id = o.user_id
              join companies c on c.company_id = u.company_id
              left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) AND rla.start_date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})))
              left join locations l on l.location_id = rla.location_id
              left join markets m on m.market_id = o.market_id
              left join companies cm on cm.company_id = m.company_id
            where
              u.company_id = {{ _user_attributes['company_id'] }}
              and po.company_id = {{ _user_attributes['company_id'] }}
              and l.company_id = {{ _user_attributes['company_id'] }}
              and r.deleted = false
              and r.end_date BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: po_name {
    label: "PO"
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
    value_format_name: id
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: rental_start_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Rental Start Date"
    sql: ${rental_start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: rental_end_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Rental End Date"
    sql: ${rental_end_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: asset {
    type: string
    sql: concat(${custom_name}, ' (',${make_and_model},')') ;;
  }

  set: detail {
    fields: [
      rental_id,
      asset_id,
      rental_start_date,
      rental_end_date,
      po_name,
      jobsite,
      asset_class,
      price_per_day,
      price_per_week,
      price_per_month,
      order_id,
      make_and_model,
      custom_name,
      rental_status_id,
      ordered_by
    ]
  }
}
