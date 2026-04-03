view: walsh_rental_history_spend {
 derived_table: {
  sql:
    with last_invoice as (
    SELECT
        r.rental_id,
        i.invoice_no,
        i.invoice_date::date as invoice_date
    FROM
        es_warehouse.public.rentals r
    left JOIN es_warehouse.public.orders o ON o.order_id = r.rental_id
    left JOIN es_warehouse.public.invoices i ON o.order_id = i.order_id
    QUALIFY
        ROW_NUMBER() OVER (PARTITION BY r.rental_id ORDER BY i.invoice_date DESC, i.invoice_no DESC) = 1

    )

    SELECT
    c.company_id as account_number,
    c.name as customer_name,
    bl.street_1 as customer_address1,
    bl.city as customer_city,
    bls.abbreviation as customer_state,
    bl.zip_code as customer_zip,
    r.rental_id as contract_number,
    onr.status as rental_status,
    coalesce(li.invoice_no, 'Not Yet Invoiced') as last_invoice_sequence_number,
    o.market_id as branch_number,
    o.purchase_order_id as job_number_walsh,
    concat(dl.city,', ',dls.abbreviation) as job_location,
    coalesce(dl.nickname,' ') as job_name,
    dl.street_1 as job_address1,
    dls.abbreviation as job_state,
    dl.zip_code as job_zip,
    concat(u.first_name,' ',u.last_name) as job_contact,
    concat(u.first_name,' ',u.last_name) as ordered_by,
    concat('JOB - ', po.name) as po_number,
    coalesce(ast.name,'Bulk Item') as equipment_type,
    ec.equipment_class_id as cat_class_id,
    coalesce(cat.name,pc.category_name) as cat_class,
    coalesce(a.asset_class,pt.description) as class_name,
    a.asset_id,
    a.make,
    a.model,
    a.serial_number,
    a.year as model_year,
    coalesce(asset_online_target_price, NULL) as replacement_value,
    coalesce(r.quantity,1) as quantity,
    r.end_date::date as est_return_date,
    r.price_per_day as day_rate,
    r.price_per_week as week_rate,
    r.price_per_month as four_week_rate,
    li.invoice_date as billed_through,
    round(coalesce(amt.amount,0),2) as total_billed,
    r.start_date::date as date_rented,
    datediff('days',IFF(onr.rental_end_date > current_date,current_date,rental_end_date),onr.rental_start_date) as total_days_on_rent,
    bdu.hours as starting_hours_meter
    from
    BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__RENTAL_STATUS_INFO onr
    left join es_warehouse.public.rentals r on onr.rental_id = r.rental_id
    left join es_warehouse.public.equipment_assignments ea on r.rental_id = ea.rental_id AND (ea.end_date >= current_timestamp() or ea.end_date is null)
    left join es_warehouse.public.assets a on a.asset_id = ea.asset_id
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
    left join es_warehouse.public.locations bl on bl.location_id = c.billing_location_id
    left join es_warehouse.public.states bls on bls.state_id = bl.state_id
    left join es_warehouse.public.asset_types ast on ast.asset_type_id = a.asset_type_id
    left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = a.equipment_class_id
    left join es_warehouse.public.categories cat on cat.category_id = ec.category_id
    left join last_invoice li on li.rental_id = r.rental_id
    left join fleet_optimization.gold.dim_assets_fleet_opt rv on rv.asset_id = a.asset_id
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
    (select parent_company_id from analytics.bi_ops.v_parent_company_relationships where company_id = 13089)
    )
    AND onr.rental_start_date >= '2024-01-01'
    ;;
}

dimension: account_number {
  type: number
  sql: ${TABLE}."ACCOUNT_NUMBER" ;;
}

dimension: cat_class_id {
  type: number
  sql: ${TABLE}."CAT_CLASS_ID" ;;
}

dimension: customer_name {
  type: string
  sql: ${TABLE}."CUSTOMER_NAME" ;;
}

dimension: customer_address1 {
  type: string
  sql: ${TABLE}."CUSTOMER_ADDRESS1" ;;
}

dimension: customer_city {
  type: string
  sql: ${TABLE}."CUSTOMER_CITY" ;;
}

dimension: customer_state {
  type: string
  sql: ${TABLE}."CUSTOMER_STATE" ;;
}

dimension: customer_zip {
  type: zipcode
  sql: ${TABLE}."CUSTOMER_ZIP" ;;
}

dimension: contract_number {
  type: number
  sql: ${TABLE}."CONTRACT_NUMBER" ;;
}

dimension: rental_status {
  type: string
  sql: ${TABLE}."RENTAL_STATUS" ;;
}

dimension: last_invoice_sequence_number {
  type: string
  sql: ${TABLE}."LAST_INVOICE_SEQUENCE_NUMBER" ;;
}

dimension: branch_number {
  type: number
  sql: ${TABLE}."BRANCH_NUMBER" ;;
}

dimension: job_number_walsh {
  type: number
  sql: ${TABLE}."JOB_NUMBER_WALSH" ;;
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

dimension: ordered_by {
  type: string
  sql: ${TABLE}."ORDERED_BY" ;;
}

dimension: po_number {
  type: string
  sql: ${TABLE}."PO_NUMBER" ;;
}

dimension: equipment_type {
  type: string
  sql: ${TABLE}."EQUIPMENT_TYPE" ;;
}

dimension: cat_class {
  type: string
  sql: ${TABLE}."CAT_CLASS" ;;
}

dimension: class_name {
  type: string
  sql: ${TABLE}."CLASS_NAME" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension: make {
  type: string
  sql: ${TABLE}."MAKE" ;;
}

dimension: model {
  type: string
  sql: ${TABLE}."MODEL" ;;
}

dimension: serial_number {
  type: string
  sql: ${TABLE}."SERIAL_NUMBER" ;;
}

dimension: model_year {
  type: string
  sql: ${TABLE}."MODEL_YEAR" ;;
}

dimension: replacement_value {
  type: number
  sql: ${TABLE}."REPLACEMENT_VALUE" ;;
}

dimension: quantity {
  type: number
  sql: ${TABLE}."QUANTITY" ;;
}

dimension: est_return_date {
  type: date
  sql: ${TABLE}."EST_RETURN_DATE" ;;
}

dimension: day_rate {
  type: number
  sql: ${TABLE}."DAY_RATE" ;;
}

dimension: week_rate {
  type: number
  sql: ${TABLE}."WEEK_RATE" ;;
}

dimension: four_week_rate {
  type: number
  sql: ${TABLE}."FOUR_WEEK_RATE" ;;
}

dimension: billed_through {
  type: date
  sql: ${TABLE}."BILLED_THROUGH" ;;
}

dimension: total_billed {
  type: number
  sql: ${TABLE}."TOTAL_BILLED" ;;
}

dimension: date_rented {
  type: date
  sql: ${TABLE}."DATE_RENTED" ;;
}

dimension: total_days_on_rent {
  type: number
  sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
}

dimension: starting_hours_meter {
  type: number
  sql: ${TABLE}."STARTING_HOURS_METER" ;;
}
}
