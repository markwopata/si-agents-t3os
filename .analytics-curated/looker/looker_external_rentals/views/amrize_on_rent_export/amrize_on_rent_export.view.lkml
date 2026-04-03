view: amrize_on_rent_export {
  derived_table: {
    sql:
    SELECT
      c.name as customer_name,
      r.rental_id as rental_id,
      o.purchase_order_id as job_number,
      concat(dl.city,', ',dls.abbreviation) as job_location,
      coalesce(dl.nickname,' ') as job_name,
      dl.street_1 as job_address1,
      dls.abbreviation as job_state,
      dl.zip_code as job_zip,
      concat(u.first_name,' ',u.last_name) as job_contact,
      a.asset_id,
      r.asset_id as rental_asset_id,
      coalesce(cat.name,pc.category_name) as cat_class,
      coalesce(a.asset_class,pt.description) as class_name,
      coalesce(r.quantity,1) as quantity,
      r.start_date::date as rental_start_date,
      r.end_date::date as rental_end_date,
      r.price_per_day as day_rate,
      r.price_per_week as week_rate,
      r.price_per_month as four_week_rate,
      round(coalesce(amt.amount,0),2) as total_billed
      from
      BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__RENTAL_STATUS_INFO onr
      left join es_warehouse.public.rentals r on onr.rental_id = r.rental_id
      left join es_warehouse.public.assets a on a.asset_id = r.asset_id
      left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
      left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
      left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
      left join es_warehouse.inventory.product_classes pc on p.product_class_id = pc.product_class_id
      left join es_warehouse.public.orders o on r.order_id = o.order_id
      left join es_warehouse.public.users u on u.user_id = o.user_id
      join es_warehouse.public.companies c on c.company_id = u.company_id
      left join es_warehouse.public.deliveries d on d.delivery_id = r.drop_off_delivery_id
      left join es_warehouse.public.locations dl on dl.location_id = d.location_id
      left join es_warehouse.public.states dls on dls.state_id = dl.state_id
      left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
      left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
      left join es_warehouse.public.equipment_classes_models_xref emx on emx.equipment_model_id = em.equipment_model_id
      left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = emx.equipment_class_id
      left join es_warehouse.public.categories cat on cat.category_id = ec.category_id
      left join business_intelligence.triage.stg_t3__by_day_utilization bdu on a.asset_id = bdu.asset_id and bdu.date = r.start_date::date
      left join
      (
      select
      r.rental_id,
      sum(li.amount+li.tax_amount) as amount
      from
      es_warehouse.public.rentals r
      join es_warehouse.public.line_items li on r.rental_id = li.rental_id
      group by
      r.rental_id
      ) amt on amt.rental_id = r.rental_id
      where
      c.company_id in (select company_id from analytics.bi_ops.v_parent_company_relationships where parent_company_id =
      (select parent_company_id from analytics.bi_ops.v_parent_company_relationships where company_id = 41232)
      )
      and
      r.deleted = false
      AND onr.rental_start_date >= '2024-01-01'
      ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: job_number {
    type: number
    sql: ${TABLE}."JOB_NUMBER" ;;
    value_format_name: id
  }

  dimension: job_location {
    type: string
    sql: ${TABLE}."JOB_LOCATION" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: job_address1 {
    type: string
    sql: ${TABLE}."JOB_ADDRESS1" ;;
  }

  dimension: job_state {
    type: string
    sql: ${TABLE}."JOB_STATE" ;;
  }

  dimension: job_zip {
    type: zipcode
    sql: ${TABLE}."JOB_ZIP" ;;
  }

  dimension: job_contact {
    type: string
    sql: ${TABLE}."JOB_CONTACT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: rental_asset_id {
    type: number
    sql: ${TABLE}."RENTAL_ASSET_ID" ;;
    value_format_name: id
  }

  dimension: cat_class {
    type: string
    sql: ${TABLE}."CAT_CLASS" ;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}."CLASS_NAME" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
    value_format_name: usd_0
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
    value_format_name: usd_0
  }

  dimension: four_week_rate {
    type: number
    sql: ${TABLE}."FOUR_WEEK_RATE" ;;
    value_format_name: usd_0
  }

  dimension: total_billed {
    type: number
    sql: ${TABLE}."TOTAL_BILLED" ;;
    value_format_name: usd
  }

  set: detail {
    fields: [
      customer_name,
      rental_id,
      job_number,
      job_location,
      job_name,
      job_address1,
      job_state,
      job_zip,
      job_contact,
      asset_id,
      rental_asset_id,
      cat_class,
      class_name,
      quantity,
      rental_start_date,
      rental_end_date,
      day_rate,
      week_rate,
      four_week_rate,
      total_billed
    ]
  }

}
