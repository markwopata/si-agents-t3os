view: rental_detail_information {
  derived_table: {
    sql: select
          o.order_id,
          r.rental_id,
          coalesce(ea.asset_id, r.asset_id) as asset_id,
          initcap(aty.name) as asset_type,
          a.asset_class,
          m.name as branch,
          rst.name as rental_status,
          c.name as customer,
          l.nickname as jobsite,
          concat(l.street_1, ', ', l.city, ', ', st.abbreviation,', ', coalesce(l.zip_code,0)) as jobsite_location,
          r.start_date as rental_start,
          r.end_date as rental_end,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month,
          ca.name as category
      from
          ES_WAREHOUSE.public.orders o
          join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
          join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
          left join ES_WAREHOUSE.public.equipment_assignments ea on r.rental_id = ea.rental_id and coalesce(ea.end_date, current_timestamp) >= r.end_date
          left join ES_WAREHOUSE.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
          left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
          left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
          left join ES_WAREHOUSE.public.rental_location_assignments rla on r.rental_id = rla.rental_id
          left join ES_WAREHOUSE.public.locations l on l.location_id = rla.location_id
          left join ES_WAREHOUSE.public.states st on l.state_id = st.state_id
          left join ES_WAREHOUSE.PUBLIC.assets a on coalesce(ea.asset_id, r.asset_id) = a.asset_id
          left join ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
          left join ES_WAREHOUSE.PUBLIC.categories ca on a.category_id=ca.category_id
      where
          m.company_id = {{ _user_attributes['company_id'] }}::numeric

          AND
          {% condition asset_type_filter %} aty.name {% endcondition %}
          AND
          {% condition category_filter %} ca.name {% endcondition %}
          AND
          {% condition branch_filter %} m.name {% endcondition %}
          AND
          {% condition asset_class_filter %} a.asset_class {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: jobsite_location {
    type: string
    sql: ${TABLE}."JOBSITE_LOCATION" ;;
  }

  dimension_group: rental_start {
    type: time
    sql: ${TABLE}."RENTAL_START" ;;
  }

  dimension_group: rental_end {
    type: time
    sql: ${TABLE}."RENTAL_END" ;;
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

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  measure: total_cancelled {
    type: count
    filters: [rental_status: "Cancelled"]
  }

  measure: total_completed {
    type: count
    filters: [rental_status: "Completed"]
  }

  measure: total_draft {
    type: count
    filters: [rental_status: "Draft"]
  }

  measure: total_off_rent {
    type: count
    filters: [rental_status: "Off Rent"]
  }

  measure: total_on_rent {
    type: count
    filters: [rental_status: "On Rent"]
  }

  measure: total_pending {
    type: count
    filters: [rental_status: "Pending"]
  }

  dimension: rental_start_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Rental Start Time"
    type: date_time
    sql: ${rental_start_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: entry_end_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Rental End Time"
    type: date_time
    sql: ${rental_end_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  set: detail {
    fields: [
      order_id,
      rental_id,
      asset_id,
      asset_type,
      asset_class,
      branch,
      rental_status,
      customer,
      jobsite,
      jobsite_location,
      rental_start_time_formatted,
      entry_end_time_formatted,
      price_per_day,
      price_per_week,
      price_per_month
    ]
  }

  filter: asset_type_filter {
 #   suggest_explore: rental_detail_information
  #  suggest_dimension: rental_detail_information.asset_type
  }

  filter: category_filter {
  #  suggest_explore: rental_detail_information
  #  suggest_dimension: rental_detail_information.category
  }

  filter: branch_filter {
 #   suggest_explore: rental_detail_information
  #  suggest_dimension: rental_detail_information.branch
  }

  filter: asset_class_filter {
   # suggest_explore: rental_detail_information
    #suggest_dimension: rental_detail_information.asset_class
  }

}
