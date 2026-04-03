view: inventory_to_onrent_assetclass_counts {
      derived_table: {
        sql:
        with future_day_list as (
        select convert_timezone('{{ _user_attributes['user_timezone'] }}', series)::date as day
        from table(es_warehouse.public.generate_series(
                          (current_timestamp)::timestamp_tz,
                          dateadd('day', 28, current_timestamp::timestamp_tz),
                          'day'))
        )
        , onrent_assets as (
          select convert_timezone('{{ _user_attributes['user_timezone'] }}', fdl.day) as day,
              coalesce(r.equipment_class_id, -1) as equipment_class_id,
              count(r.equipment_class_id) as on_rent_count
          from ES_WAREHOUSE.public.orders o
              join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
              left join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
              JOIN future_day_list fdl
                         ON fdl.day BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}', r.start_date))
                           AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', r.end_date)), '9999-12-31')
        where m.company_id = {{ _user_attributes['company_id'] }}
        group by fdl.day, r.equipment_class_id
        )
        , all_inventory_assets as (
        select  fdl.day,
            coalesce(a.equipment_class_id, -1) as equipment_class_id,
            a.asset_class,
            m.market_id as branch_id,
            m.name as branch,
            count(a.equipment_class_id) as inventory_count
        from ES_WAREHOUSE.SCD.scd_asset_inventory_status ais
              left join ES_WAREHOUSE.PUBLIC.assets a on ais.asset_id = a.asset_id
              join ES_WAREHOUSE.public.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
              JOIN future_day_list fdl
                        ON fdl.day BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}', ais.date_start))
                           AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', ais.date_end)), '9999-12-31')
        where m.company_id = {{ _user_attributes['company_id'] }}
            and ais.asset_inventory_status <> 'Hard Down'
 --           and a.asset_type_id <> 2
            and a.custom_name not ilike '%XHR%'
        group by fdl.day, a.equipment_class_id, a.asset_class, m.market_id, m.name
        )
        select  aia.day,
            coalesce(aia.asset_class, 'No Class Assigned') as asset_class,
            aia.branch_id,
            aia.branch,
            coalesce(ora.on_rent_count, 0) as on_rent_count,
            coalesce(aia.inventory_count, 0) as inventory_count,
            coalesce(aia.inventory_count, 0) - coalesce(ora.on_rent_count, 0) as available_assets_dimension
        from all_inventory_assets aia
            left join onrent_assets ora on aia.day = ora.day and aia.equipment_class_id = ora.equipment_class_id
        ;;
      }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${day},${asset_class}) ;;
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
    convert_tz: yes
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
      sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: inventory_count {
    type: number
    sql: ${TABLE}."INVENTORY_COUNT" ;;
  }

  dimension: on_rent_count {
    type: number
    sql: ${TABLE}."ON_RENT_COUNT" ;;
  }

  dimension: available_assets_dimension {
    type:  number
    sql: ${TABLE}."AVAILABLE_ASSETS_DIMENSION" ;;
    value_format_name: decimal_0
  }

  dimension: inventory_shortage_status {
    case: {
      when: {
        sql: ${TABLE}."AVAILABLE_ASSETS_DIMENSION" <= 0 ;;
        label: "Shortage"
      }
      when: {
        sql: ${TABLE}."AVAILABLE_ASSETS_DIMENSION" >= 1 and ${TABLE}."AVAILABLE_ASSETS_DIMENSION" <= 2 ;;
        label: "Low Inventory"
      }
      when: {
        sql: ${TABLE}."AVAILABLE_ASSETS_DIMENSION" > 2 ;;
        label: "Available"
      }
    }
  }

  measure: Inventory_Total {
    type: sum_distinct
    sql:  ${TABLE}."INVENTORY_COUNT" ;;
    value_format_name: decimal_0
  }

  measure: OnRent_Total {
    type:  sum_distinct
    sql: ${TABLE}."ON_RENT_COUNT" ;;
    value_format_name: decimal_0
  }

  measure: available_assets {
    type:  number
    sql: ${Inventory_Total} - ${OnRent_Total} ;;
    value_format_name: decimal_0
  }




}