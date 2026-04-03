view: pump_and_power_assets_past_90_rentals {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: WITH rental_day_list AS
          (
            select
            convert_timezone('America/Chicago',dateadd(
            day,
            '-' || row_number() over (order by null),
            dateadd(day, '+1', current_date())
            )) as rental_day
            from table (generator(rowcount => 90))
          ),
      on_rent as (
      SELECT rdl.rental_day::date
            , o.market_id
            , m.name
            , ea.asset_id
            , cl.name as equipment_class
            , ea.start_date
            , ea.end_date
            , o.salesperson_user_id
            , coalesce(oec.purchase_price
                  , (SELECT avg(purchase_price) as avg_oec
                      FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                      WHERE company_id = 1854
                      AND purchase_history_id in
                          (SELECT max(purchase_history_id)
                              FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                              GROUP BY asset_id))) as oec
       FROM ES_WAREHOUSE.PUBLIC.orders o
                JOIN ES_WAREHOUSE.PUBLIC.rentals r
                     ON o.order_id = r.order_id
                JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea
                     ON r.rental_id = ea.rental_id
                JOIN ES_WAREHOUSE.PUBLIC.assets a
                     ON ea.asset_id = a.asset_id
                LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m
                          ON o.market_id = m.market_id
                LEFT JOIN (SELECT asset_id, purchase_price
                           FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                           WHERE purchase_history_id IN
                                 (SELECT max(purchase_history_id)
                                  FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                                  GROUP BY asset_id)) oec
                          ON a.asset_id = oec.asset_id
                JOIN rental_day_list rdl
                     ON rdl.rental_day BETWEEN (ea.start_date::date)
                                         AND coalesce((ea.end_date::date), '2099-12-31')
              left join ES_WAREHOUSE.public.equipment_classes_models_xref x on a.equipment_model_id = x.equipment_model_id
      inner join ES_WAREHOUSE.PUBLIC.equipment_classes cl on x.equipment_class_id = cl.equipment_class_id
       WHERE m.company_id = 1854
        and cl.company_division_id = 2
        and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
         ),
         total_rentals_by_asset as (
         select
             asset_id,
             count(*) as days_rented
           from
             on_rent
           group by
             asset_id
         ),
         all_pump_and_power_classes as (
         select
          a.asset_id,
          cl.name as equipment_class,
          a.date_created::date as date_created
        from ES_WAREHOUSE.public.assets a
          left join ES_WAREHOUSE.public.equipment_classes_models_xref x on a.equipment_model_id = x.equipment_model_id
          inner join ES_WAREHOUSE.PUBLIC.equipment_classes cl on x.equipment_class_id = cl.equipment_class_id
          left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id,a.inventory_branch_id)=m.market_id
        where
             ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
             and rental_branch_id is not null
             and m.company_id = 1854
           and cl.company_division_id = 2
         )
        select
          pc.asset_id,
          pc.date_created,
          pc.equipment_class,
          case when re.days_rented is null then 0 else re.days_rented end as total_days_rented
        from
          all_pump_and_power_classes pc
          left join total_rentals_by_asset re on pc.asset_id = re.asset_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: total_days_rented {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_RENTED" ;;
  }

  measure: total_rentals_past_90_days {
    type: sum
    sql: ${total_days_rented} ;;
    drill_fields: [detail*]
  }

  measure: assets_unrented {
    type: count
    filters: [total_days_rented: "0"]
    drill_fields: [detail*]
  }

  measure: assets_rented {
    type: count
    filters: [total_days_rented: ">= 1"]
    drill_fields: [detail*]
  }

  measure: total_assets {
    type: number
    sql: ${assets_rented} + ${assets_unrented}  ;;
    drill_fields: [detail*]
  }

  measure: percent_of_unrented_assets {
    type: number
    sql: ${assets_unrented} / ${total_assets} ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [asset_id, date_created, equipment_class, total_days_rented]
  }
}
