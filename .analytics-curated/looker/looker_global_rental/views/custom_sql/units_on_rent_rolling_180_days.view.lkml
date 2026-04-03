view: units_on_rent_rolling_180_days {
    derived_table: {
      sql: WITH rental_day_list AS
        (
        select
        dateadd(
        day,
        '-' || row_number() over (order by null),
        dateadd(day, '+1', convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp()))
        ) as rental_day
        from table (generator(rowcount => 180))
        )
           SELECT rdl.rental_day::date as rental_day,
             ea.asset_id,
             a.asset_class,
             o.market_id,
             m.name as market_name,
             ea.start_date,
             ea.end_date,
             o.salesperson_user_id,
             aa.oec
           FROM ES_WAREHOUSE.PUBLIC.orders o
              JOIN ES_WAREHOUSE.PUBLIC.rentals r ON o.order_id = r.order_id
              JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON r.rental_id = ea.rental_id
              JOIN ES_WAREHOUSE.PUBLIC.assets a ON ea.asset_id = a.asset_id
              LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m ON o.market_id = m.market_id
              LEFT JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa ON a.asset_id = aa.asset_id
              JOIN rental_day_list rdl
                   ON rdl.rental_day BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}', ea.start_date))
                     AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', ea.end_date)), '2099-12-31')
          WHERE m.company_id = {{ _user_attributes['company_id'] }}
          and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
     ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: primary_key {
      primary_key: yes
      type: string
      sql: concat(${rental_day}, ' ',${asset_id}) ;;
    }

    dimension: rental_day {
      type: date
      sql: ${TABLE}."RENTAL_DAY" ;;
    }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

    dimension: rental_branch_id {
      type: number
      sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: oec {
      type: number
      sql: ${TABLE}."OEC" ;;
    }

    measure: Unit_Total {
      type:  count_distinct
      sql: ${asset_id} ;;
    }

    measure: OEC_Total {
      type:  sum
      sql: ${oec} ;;
      value_format:"0.0,,\" M\""
    }

    set: detail {
      fields: [rental_day, asset_id, assets.asset_class, market_name, oec]
    }

  }