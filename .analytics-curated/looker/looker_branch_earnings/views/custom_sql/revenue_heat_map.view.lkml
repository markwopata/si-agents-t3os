view: revenue_heat_map {
  derived_table: {
    sql:
      SELECT
    m.market_id,
    m.market_name,
    m.region_name,
    m.region_district,
    m.market_type,
    r.ship_to_city,
    r.ship_to_state,
    r.ship_to_zip_code,
    r.ship_to_latitude,
    r.ship_to_longitude,
    SUM(r.amount) AS rental_revenue
FROM analytics.intacct_models.int_revenue r
JOIN analytics.branch_earnings.market m
    ON r.market_id = m.child_market_id
WHERE 1=1
  AND {% condition billing_approved_date_filter %} r.billing_approved_date {% endcondition %}
  and r.ship_to_latitude is not null
  and r.ship_to_longitude is not null
GROUP BY ALL


      ;;
  }

  filter: billing_approved_date_filter {
    type: date
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }


  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_district {
    label: "District"
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: ship_to_city {
    label: "Ship To City"
    type: string
    sql: ${TABLE}.ship_to_city ;;
  }

  dimension: ship_to_state {
    label: "Ship To State"
    type: string
    sql: ${TABLE}.ship_to_state ;;
  }

  dimension: ship_to_zip_code {
    label: "Ship To ZIP Code"
    type: zipcode
    sql: ${TABLE}.ship_to_zip_code ;;
  }

  dimension: ship_to_latitude {
    label: "Ship To Latitude"
    type: number
    sql: ${TABLE}.ship_to_latitude ;;
    value_format_name: decimal_4
  }

  dimension: ship_to_longitude {
    label: "Ship To Longitude"
    type: number
    sql: ${TABLE}.ship_to_longitude ;;
    value_format_name: decimal_4
  }

  dimension: ship_to_location {
    label: "Ship To Location"
    type: location
    sql_latitude: ${ship_to_latitude} ;;
    sql_longitude: ${ship_to_longitude} ;;
  }

  measure: rental_revenue {
    label: "Rental Revenue"
    type: sum
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    value_format_name: usd_0
  }

}
