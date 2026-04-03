view: company_class_pricing {
  derived_table: {
    sql:
        select distinct c.name as company, c.company_id,
            ec.equipment_class_id,
            cat.name as category,
            ec.name as asset_class,
            case when crr.percent_discount is not null then brr.price_per_hour - (brr.price_per_hour * crr.percent_discount) else crr.price_per_hour end as price_per_hour,
            case when crr.percent_discount is not null then brr.price_per_day - (brr.price_per_day * crr.percent_discount) else crr.price_per_day end as price_per_day,
            case when crr.percent_discount is not null then brr.price_per_week - (brr.price_per_week * crr.percent_discount) else crr.price_per_week end as price_per_week,
            case when crr.percent_discount is not null then brr.price_per_month - (brr.price_per_month * crr.percent_discount) else crr.price_per_month end as price_per_month,
            crr.percent_discount,
            crr.date_created::date as date_added,
            concat(ucrr.first_name, ' ', ucrr.last_name) as added_by,
            crr.date_voided::date as date_voided,
            concat(uv.first_name, ' ', uv.last_name) as voided_by,
            case when crr.percent_discount is not null then crr.rate_type_id else brr.rate_type_id end as rate_type_id,
            case when crr.percent_discount is not null then rtyc.name else rtyb.name end as rate_type
        from ES_WAREHOUSE.PUBLIC.company_rental_rates crr
            join ES_WAREHOUSE.PUBLIC.markets m on crr.rsp_company_id = m.company_id
            join ES_WAREHOUSE.PUBLIC.companies c on crr.company_id = c.company_id
            join ES_WAREHOUSE.PUBLIC.equipment_classes ec on crr.equipment_class_id = ec.equipment_class_id
            left join ES_WAREHOUSE.PUBLIC.branch_rental_rates brr on m.market_id = brr.branch_id
                    and crr.equipment_class_id = brr.equipment_class_id
                    and brr.date_voided is null
            left join ES_WAREHOUSE.PUBLIC.rate_types rtyb on brr.rate_type_id = rtyb.rate_type_id
            left join ES_WAREHOUSE.PUBLIC.rate_types rtyc on crr.rate_type_id = rtyc.rate_type_id
            join ES_WAREHOUSE.PUBLIC.categories cat on ec.category_id = cat.category_id
            left join ES_WAREHOUSE.PUBLIC.users ucrr on crr.created_by_user_id = ucrr.user_id
            left join ES_WAREHOUSE.PUBLIC.users uv on crr.voided_by_user_id = uv.user_id
        where rsp_company_id = {{ _user_attributes['company_id'] }}
            and crr.date_voided is null
            and brr.rate_type_id is not null
            and brr.rate_type_id <> 3
            order by company, asset_class
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

  dimension: percent_discount {
    label: "Discount (%)"
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
    value_format_name: percent_0
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

  }
