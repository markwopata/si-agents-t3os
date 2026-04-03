view: asset_on_rent_statuses_2021 {
  derived_table: {
    sql:
      select coalesce(ea.asset_id, r.asset_id) as asset_id,
          r.rental_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', ea.start_date) as asset_start,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', coalesce(ea.end_date, '9999-12-31')) as asset_end
 --         r.price_per_day, r.price_per_week, r.price_per_month
      from ES_WAREHOUSE.PUBLIC.rentals r
          join ES_WAREHOUSE.PUBLIC.equipment_assignments ea on ea.rental_id = r.rental_id
          join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
          join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
      where coalesce(ea.end_date, r.end_date) >= '2021-01-01'
      -- Excluded cancelled rentals
          and r.rental_status_id in(1,2,3,4,5,6,7,9)
          and m.company_id = {{ _user_attributes['company_id'] }}
      ;;
  }

  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${rental_id}) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_start {
    type:date_time
    sql: ${TABLE}."ASSET_START" ;;
  }

  dimension: asset_end {
    type: date_time
    sql: ${TABLE}."ASSET_END" ;;
  }

  }