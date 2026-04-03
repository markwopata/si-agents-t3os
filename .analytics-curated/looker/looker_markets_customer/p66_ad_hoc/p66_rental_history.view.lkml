
view: p66_rental_history {
  derived_table: {
    sql: with all_rentals as (
      Select c.company_id, c.name as company_name, iea.asset_id, iea.rental_id, iea.date_start, iea.date_end, r.rental_status_id, r.start_date, r.end_date
      from analytics.assets.int_equipment_assignments iea
      left join es_warehouse.public.rentals r USING(rental_id)
      left join es_warehouse.public.orders o USING(order_id)
      left join es_warehouse.public.users u ON u.user_id = o.user_id
      left join es_warehouse.public.companies c on u.company_id = c.company_id
      WHERE c.company_id IN (select company_id from analytics.bi_ops.v_parent_company_relationships where parent_company_id = 18750)
      )

      select
          company_id,
          company_name,
          rental_id,
          rental_status_id,
          start_date,
          end_date,
          case when rental_status_id = 5 then 'On Rent'
          when rental_status_id in (2,3) then 'Reservation'
          when rental_status_id in (6,7,9) then 'Off Rent'
          else 'Undefined'
          end as rental_status,
          CASE
          WHEN COUNT(DISTINCT asset_id) > 1 THEN TRUE
          ELSE FALSE
          END AS swap_flag,
          COUNT(distinct asset_id) as assets_used_on_rental
      FROM all_rentals
      where rental_status_id <> 8
      GROUP BY  company_id,
          company_name,
          rental_id,
          rental_status_id,
          start_date,
          end_date ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension_group: start_date {
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: swap_flag {
    type: yesno
    sql: ${TABLE}."SWAP_FLAG" ;;
  }

  dimension: assets_used_on_rental {
    type: number
    sql: ${TABLE}."ASSETS_USED_ON_RENTAL" ;;
  }

  measure: assets_assigned_to_rental {
    type: sum
    sql: ${assets_used_on_rental} ;;
    drill_fields: [p66_rental_asset_assignment.rental_id, p66_rental_asset_assignment.asset_id, p66_rental_asset_assignment.asset_start_date_time, p66_rental_asset_assignment.asset_end_date_time]
  }

  set: detail {
    fields: [
      company_id,
      company_name,
      rental_id,
      start_date_time,
      end_date_time,
      rental_status,
      swap_flag,
      assets_used_on_rental
    ]
  }
}
