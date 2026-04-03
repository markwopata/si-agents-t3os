view: deliveries_to_be_completed_by_date {
  derived_table: {
    sql: select
          r.rental_id,
          r.asset_id,
          r.end_date as rental_end_date,
          d.completed_date as delievery_completed_date,
          datediff(day,r.end_date::date,coalesce(d.completed_date::date,current_date)) as days_waiting_for_pickup,
          po.name as po_name,
          cm.name as vendor
        from
          rentals r
          left join orders o on r.order_id = o.order_id
          left join users u on u.user_id = o.user_id
          left join deliveries d on d.delivery_id = r.return_delivery_id
          left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join markets m on m.market_id = o.market_id
          left join companies cm on cm.company_id = m.company_id
        where
        overlaps(
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})::date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})::date,
              r.end_date::date,
              d.completed_date::date
          )
         and u.company_id = {{ _user_attributes['company_id'] }}
         and datediff(day,r.end_date::date,d.completed_date::date) >= 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    primary_key: yes
    value_format_name: id
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: rental_end_date {
    type: time
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension_group: delievery_completed_date {
    type: time
    sql: ${TABLE}."DELIEVERY_COMPLETED_DATE" ;;
  }

  dimension: days_waiting_for_pickup {
    type: number
    sql: ${TABLE}."DAYS_WAITING_FOR_PICKUP" ;;
  }

  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  parameter: date_selector {
    type: date
    description: "Use this field to select a date to filter results by."
  }

  filter: date_filter {
    type: date_time
  }

  dimension: rental_end_date_formatted {
    group_label: "HTML Passed Date Format" label: "Rental End Date"
    sql: ${rental_end_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: delievery_date_formatted {
    group_label: "HTML Passed Date Format" label: "Delievery Completed Date"
    sql: ${delievery_completed_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [rental_id, assets.custom_name, assets.asset_class, rental_end_date_formatted, delievery_date_formatted, days_waiting_for_pickup]
  }
}
