view: quanta_on_rent_report {
  derived_table: {
    sql: SELECT
          c.name as quanta_operating_unit,
          'EquipmentShare' as rental_company,
          ea.asset_id,
          cat.name as equipment_category,
          a.description,
          ac.total_days_on_rent as days_on_rent,
          ac.price_per_month,
          round(coalesce(amt.amount,0),2) as total_rental_billed_charges,
          r.rental_id as contract_number,
          coalesce(a.serial_number,a.vin) as serial_number_or_vin,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          coalesce(dl.nickname,' ') as job_name,
          r.start_date::date as start_date,
          coalesce(r.quantity,1) as quantity
      from
          rentals r
          left join equipment_assignments ea on r.rental_id = ea.rental_id
          left join assets a on a.asset_id = ea.asset_id
          left join rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join inventory.parts p on p.part_id = rpa.part_id
          left join inventory.part_types pt on pt.part_type_id = p.part_type_id
          left join admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = ea.asset_id
          left join orders o on r.order_id = o.order_id
          left join users u on u.user_id = o.user_id
          join companies c on c.company_id = u.company_id
          left join deliveries d on d.delivery_id = r.drop_off_delivery_id
          left join locations dl on dl.location_id = d.location_id
          left join categories cat on cat.category_id = a.category_id
          left join
          (
          select
                  r.rental_id,
                  sum(li.amount+li.tax_amount) as amount
              from
                  rentals r
                  join line_items li on r.rental_id = li.rental_id
              group by
                  r.rental_id
          ) amt on amt.rental_id = r.rental_id
      where
          c.company_id in (
          40337,
          9329,
          11903,
          13294,
          21399,
          17080,
          17079,
          30086,
          22095,
          8473,
          5705,
          39738,
          20499,
          31369,
          31914
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

  dimension: quanta_operating_unit {
    type: string
    sql: ${TABLE}."QUANTA_OPERATING_UNIT" ;;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: total_rental_billed_charges {
    type: number
    sql: ${TABLE}."TOTAL_RENTAL_BILLED_CHARGES" ;;
    value_format_name: usd_0
  }

  dimension: contract_number {
    type: number
    sql: ${TABLE}."CONTRACT_NUMBER" ;;
    value_format_name: id
  }

  dimension: serial_number_or_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_OR_VIN" ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  set: detail {
    fields: [
      quanta_operating_unit,
      rental_company,
      asset_id,
      equipment_category,
      description,
      days_on_rent,
      price_per_month,
      total_rental_billed_charges,
      contract_number,
      serial_number_or_vin,
      ordered_by,
      job_name,
      start_date,
      quantity
    ]
  }
}
