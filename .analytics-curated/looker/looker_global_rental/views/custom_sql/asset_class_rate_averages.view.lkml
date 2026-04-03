view: asset_class_rate_averages {
  derived_table: {
    sql:
        select ec.equipment_class_id,
            ec.name as asset_class,
            avg(r.price_per_day) as daily_class_avg,
            avg(r.price_per_week) as weekly_class_avg,
            avg(r.price_per_month) as monthly_class_avg,
            avg(r.price_per_hour) as hourly_class_avg
        from ES_WAREHOUSE.public.orders o
            join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
            join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
        --    left join ES_WAREHOUSE.public.equipment_assignments ea on r.rental_id = ea.rental_id and coalesce(ea.end_date, current_timestamp) >= r.end_date
            left join ES_WAREHOUSE.public.equipment_classes ec on ec.equipment_class_id = r.equipment_class_id
        where m.company_id =  {{ _user_attributes['company_id'] }}
        group by ec.equipment_class_id, ec.name
    ;;
  }

  dimension: equipment_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID";;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS";;
  }

  dimension: daily_class_avg {
    type: number
    sql: ${TABLE}."DAILY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: weekly_class_avg {
    type: number
    sql: ${TABLE}."WEEKLY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: monthly_class_avg {
    type: number
    sql: ${TABLE}."MONTHLY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: hourly_class_avg {
    type: number
    sql: ${TABLE}."HOURLY_CLASS_AVG";;
    value_format_name: usd
  }

  }
