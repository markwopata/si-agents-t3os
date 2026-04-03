#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: salesrep_first_quote_location {
  derived_table: {
    sql: select
          min(q.created_date) as first_created_quote,
          m.name as branch,
          l.latitude,
          l.longitude
      from
          quotes.quotes.quote q
          left join es_warehouse.public.markets m on m.market_id = q.branch_id
          left join es_warehouse.public.locations l on l.location_id = m.location_id
      where
          l.latitude is not null OR l.longitude is not null
      group by
          m.name,
          l.latitude,
          l.longitude ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: first_created_quote {
    type: time
    sql: ${TABLE}."FIRST_CREATED_QUOTE" ;;
  }

  # dimension: sales_rep_id {
  #   type: number
  #   sql: ${TABLE}."SALES_REP_ID" ;;
  # }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  measure: testing_sum {
    type: count_distinct
    sql: ${first_created_quote_date} ;;
  }
  set: detail {
    fields: [
        first_created_quote_time,
  branch,
  latitude,
  longitude,
  location
    ]
  }
}
