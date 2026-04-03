
view: p66_rental_asset_assignment {
  derived_table: {
    sql: Select iea.rental_id, iea.asset_id,  iea.date_start as asset_start_date, iea.date_end as asset_end_date
      from analytics.assets.int_equipment_assignments iea
      left join es_warehouse.public.rentals r USING(rental_id)
      left join es_warehouse.public.orders o USING(order_id)
      left join es_warehouse.public.users u ON u.user_id = o.user_id
      left join es_warehouse.public.companies c on u.company_id = c.company_id
      WHERE c.company_id IN (select company_id from analytics.bi_ops.v_parent_company_relationships where parent_company_id = 18750) ;;
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
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension_group: asset_start_date {
    type: time
    sql: ${TABLE}."ASSET_START_DATE" ;;
  }

  dimension_group: asset_end_date {
    type: time
    sql: ${TABLE}."ASSET_END_DATE" ;;
  }

  set: detail {
    fields: [
        rental_id,
  asset_id,
  asset_start_date_time,
  asset_end_date_time
    ]
  }
}
