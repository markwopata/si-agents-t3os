view: branch_class_pricing {
  derived_table: {
    sql:
          select c.name as company,
              ec.equipment_class_id,
              cat.name as category,
              ec.name as asset_class,
              brr.price_per_hour, brr.price_per_day, brr.price_per_week, brr.price_per_month,
              brr.date_created::date as date_added,
              concat(u.first_name, ' ', u.last_name) as added_by,
              brr.date_voided::date as date_voided,
              m.market_id as branch_id,
              m.name as branch,
              brr.rate_type_id,
              rty.name as rate_type,
              brr.call_for_pricing,
              concat(ubrr.first_name, ' ', ubrr.last_name) as voided_by
          from ES_WAREHOUSE.PUBLIC.branch_rental_rates brr
              join ES_WAREHOUSE.PUBLIC.rate_types rty on brr.rate_type_id = rty.rate_type_id
              join ES_WAREHOUSE.PUBLIC.markets m on brr.branch_id = m.market_id
              join ES_WAREHOUSE.PUBLIC.companies c on m.company_id = c.company_id
              join ES_WAREHOUSE.PUBLIC.equipment_classes ec on brr.equipment_class_id = ec.equipment_class_id
              join ES_WAREHOUSE.PUBLIC.categories cat on ec.category_id = cat.category_id
              left join ES_WAREHOUSE.PUBLIC.users u on brr.created_by_user_id = u.user_id
              left join ES_WAREHOUSE.PUBLIC.users ubrr on brr.voided_by_user_id = ubrr.user_id
          where m.company_id = {{ _user_attributes['company_id'] }}
          order by branch, asset_class
    ;;
  }
  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${company},${equipment_class_id}) ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: date_added {
    type: date
    sql: ${TABLE}."DATE_ADDED" ;;
  }

  dimension: added_by {
    type: string
    sql: ${TABLE}."ADDED_BY" ;;
  }

  dimension: date_voided {
    type: date
    sql: ${TABLE}."DATE_VOIDED" ;;
  }

  dimension: voided_by {
    type: string
    sql: ${TABLE}."VOIDED_BY" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: branch {
    label: "RSP Branch"
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }

  dimension: call_for_pricing {
    type: yesno
    sql: ${TABLE}."CALL_FOR_PRICING" ;;
  }
  }
