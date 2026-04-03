view: isi_demolition_on_rent_report {
  derived_table: {
    sql: WITH amt as (

                  select
                  r.rental_id,
                  sum(li.amount+li.tax_amount) as amount
                  from rentals r
                  join line_items li on r.rental_id = li.rental_id
                  group by r.rental_id
                  )


      SELECT

      'ISI Demolition' as "supplier",
      coalesce(dl.nickname,' ') as "job_name",
      coalesce(dl.city,' ') as "job_location",
      a.custom_name as "equipment_type",
      a.asset_id as "equipment_id",
      coalesce(r.quantity,1) as "quantity",
      r.end_date::date as "estimated_return_date",
      ac.last_cycle_inv_date::date as "billed_through",
      r.start_date::date as "date_rented",
      ac.total_days_on_rent as "days_on_rent",
      r.price_per_day as "day_rate",
      r.price_per_week as "week_rate",
      r.price_per_month as "four_week_rate",
      round(coalesce(amt.amount,0),2) as "total_billed",
      concat(u.first_name,' ',u.last_name) as "ordered_by",
      case when dft.name = 'In House' then 'EquipmentShare' else dft.name end as "delivery_facilitator_name"
      from rentals r
      left join equipment_assignments ea on r.rental_id = ea.rental_id
      left join assets a on a.asset_id = ea.asset_id
      left join rental_part_assignments rpa on rpa.rental_id = r.rental_id
      left join inventory.parts p on p.part_id = rpa.part_id
      left join inventory.part_types pt on pt.part_type_id = p.part_type_id
      left join admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = ea.asset_id
      left join orders o on r.order_id = o.order_id
      left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
      left join users u on u.user_id = o.user_id
      join companies c on c.company_id = u.company_id
      left join deliveries d on d.delivery_id = r.drop_off_delivery_id
      left join locations dl on dl.location_id = d.location_id
      left join states s on s.state_id = dl.state_id
      left join deliveries dr on dr.delivery_id = r.return_delivery_id
      left join categories cat on cat.category_id = a.category_id
      left join amt on amt.rental_id = r.rental_id
      left join delivery_facilitator_types dft on d.facilitator_type_id = dft.delivery_facilitator_type_id
      where
      po.company_id = 53633
      AND c.company_id = 53633
      AND(
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

  dimension: supplier {
    type: string
    sql: ${TABLE}."supplier" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."job_name" ;;
  }

  dimension: job_location {
    type: string
    sql: ${TABLE}."job_location" ;;
  }

  dimension: equipment_type {
    type: string
    sql: ${TABLE}."equipment_type" ;;
  }

  dimension: equipment_id {
    label: "Equipment #"
    type: string
    sql: ${TABLE}."equipment_id" ;;
  }

  dimension: quantity {
    label: "Quantity"
    type: number
    sql: ${TABLE}."quantity" ;;
  }

  dimension: estimated_return_date {
    type: date
    sql: ${TABLE}."estimated_return_date" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: billed_through {
    type: date
    sql: ${TABLE}."billed_through" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ordered_by" ;;
  }

  dimension: date_rented {
    type: date
    sql: ${TABLE}."date_rented" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: delivery_facilitator_name {
    label: "Pickup Ticket Number"
    type: string
    sql: ${TABLE}."delivery_facilitator_name" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."days_on_rent" ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."day_rate" ;;
    value_format_name: usd_0
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."week_rate" ;;
    value_format_name: usd_0
  }

  dimension: four_week_rate {
    label: "4 Week Rate"
    type: number
    sql: ${TABLE}."four_week_rate" ;;
    value_format_name: usd_0
  }

  dimension: total_billed {
    type: number
    sql: ${TABLE}."total_billed" ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      supplier,
      job_name,
      job_location,
      equipment_type,
      equipment_id,
      quantity,
      estimated_return_date,
      billed_through,
      date_rented,
      days_on_rent,
      day_rate,
      week_rate,
      four_week_rate,
      total_billed
    ]
  }
 }
