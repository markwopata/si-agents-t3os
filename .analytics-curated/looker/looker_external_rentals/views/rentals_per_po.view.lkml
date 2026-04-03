view: rentals_per_po {
  derived_table: {
    sql: SELECT
          r.rental_id::text as rental_id,
          'EquipmentShare' as vendor,
          coalesce(a.custom_name,' ') as custom_name,
          coalesce(concat(a.make,' ',a.model),concat('Bulk Item - ',p.part_id)) as make_and_model,
          coalesce(l.nickname,' ') as jobsite,
          coalesce(po.name,' ') as purchase_order_name,
          coalesce(a.asset_class,pt.description,' ') as asset_class,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          r.start_date::date as rental_start_date,
          ac.end_this_rental_cycle::date as scheduled_off_rent_date,
          ac.next_cycle_inv_date::date::date as next_cycle_date,
          ac.price_per_day,
          ac.price_per_month,
          ac.price_per_week,
          round(coalesce(amt.amount,0)+coalesce(rrc.cheapest_option,0),2) as to_date_rental,
          ea.asset_id
      from
          rentals r
          left join equipment_assignments ea on r.rental_id = ea.rental_id
          left join assets a on a.asset_id = ea.asset_id
          left join rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join inventory.parts p on p.part_id = rpa.part_id
          left join inventory.part_types pt on pt.part_type_id = p.part_type_id
          left join rental_location_assignments rla on rla.rental_id = ea.rental_id and rla.end_date is null
          left join locations l on l.location_id = rla.location_id
          left join admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = ea.asset_id
          left join orders o on r.order_id = o.order_id
          left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join users u on u.user_id = o.user_id
          join companies c on c.company_id = u.company_id
          left join
          (
          select
                  r.rental_id,
                  --sum(li.amount) as amount
                  sum(coalesce(li.total, 0)) as amount
              from
                  orders o
                  join rentals r on o.order_id = r.order_id
                  join global_line_items li on r.rental_id = li.rental_id
              where
                  li.line_item_type_id = 8
              group by
                  r.rental_id
          ) amt on amt.rental_id = r.rental_id
          left join remaining_rental_cost rrc on rrc.rental_id = r.rental_id
          left join asset_last_location ll on ll.asset_id = a.asset_id
      where
          po.company_id = {{ _user_attributes['company_id'] }}::numeric--32686--{{ _user_attributes['company_id'] }}
          AND c.company_id = {{ _user_attributes['company_id'] }}::numeric--32686--{{ _user_attributes['company_id'] }}
          --AND PO.name = '3031022-834860'
          AND (
          r.rental_status_id = 5
          OR ea.end_date >= current_timestamp() AND ea.start_date <=current_timestamp()
          OR r.rental_status_id = 5 AND r.asset_id is null
          )
          AND {% condition po_name_filter %} po.name {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: scheduled_off_rent_date {
    type: date
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
  }

  dimension: next_cycle_date {
    type: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: to_date_rental {
    type: number
    sql: ${TABLE}."TO_DATE_RENTAL" ;;
    value_format_name: usd
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  filter: po_name_filter {
    suggest_explore: budget_amount_remaining_by_day
    suggest_dimension: purchase_orders.name
  }

  measure: on_rent_rentals {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_start_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Rental Start Date"
    sql: ${rental_start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: scheduled_off_rent_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Scheduled Off Rent Date"
    sql: ${scheduled_off_rent_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: next_cycle_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Rental End Date"
    sql: ${next_cycle_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [
      rental_id,
      vendor,
      custom_name,
      make_and_model,
      jobsite,
      purchase_order_name,
      asset_class,
      ordered_by,
      rental_start_date_formatted,
      scheduled_off_rent_date_formatted,
      next_cycle_date_formatted,
      price_per_day,
      price_per_week,
      price_per_month,
      to_date_rental
    ]
  }
}
