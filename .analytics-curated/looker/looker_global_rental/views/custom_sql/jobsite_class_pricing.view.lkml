view: jobsite_class_pricing {
  derived_table: {
    sql:
        select l.nickname as jobsite,
              c.name as company,
              ec.equipment_class_id,
              cat.name as category,
              ec.name as asset_class,
              lrr.price_per_hour, lrr.price_per_day, lrr.price_per_week, lrr.price_per_month,
              lrr.percent_discount,
              lrr.date_created::date as date_added,
              concat(u.first_name, ' ', u.last_name) as added_by,
              lrr.date_voided::date as date_voided,
              m.market_id as branch_id,
              m.name as branch
          from ES_WAREHOUSE.PUBLIC.location_rental_rates lrr
              join ES_WAREHOUSE.PUBLIC.markets m on lrr.rsp_company_id = m.company_id
              join ES_WAREHOUSE.PUBLIC.locations l on lrr.location_id = l.location_id
              join ES_WAREHOUSE.PUBLIC.companies c on lrr.rsp_company_id = c.company_id
              join ES_WAREHOUSE.PUBLIC.equipment_classes ec on lrr.equipment_class_id = ec.equipment_class_id
              join ES_WAREHOUSE.PUBLIC.categories cat on ec.category_id = cat.category_id
              join ES_WAREHOUSE.PUBLIC.users u on lrr.created_by_user_id = u.user_id
          where lrr.rsp_company_id = {{ _user_attributes['company_id'] }}
              and lrr.rate_type_id = 2
          order by jobsite, asset_class, date_added
    ;;
  }
  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${jobsite},${equipment_class_id}) ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
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
  }
