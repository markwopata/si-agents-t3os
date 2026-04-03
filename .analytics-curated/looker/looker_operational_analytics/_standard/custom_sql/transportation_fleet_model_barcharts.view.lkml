include: "/dashboard/transportation_fleet/transportation_fleet_model.explore.lkml"

view: transportation_fleet_model_barcharts {
  derived_table: {
    explore_source: v_markets {
      column: market_id {
        field: v_markets.market_id
      }
      column: delivery_truck_delta {
        field: company_purchase_order_line_items.delivery_truck_delta
      }
      column: service_truck_delta {
        field: company_purchase_order_line_items.service_truck_delta
      }
      column: premium_pickup_delta {
        field: company_purchase_order_line_items.pickup_overage_shortage
      }
      column: t3_van_delta {
        field: company_purchase_order_line_items.t3_overage_shortage
      }
    }
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }
  dimension: delivery_truck_delta {
    type: number
    sql: ${TABLE}."DELIVERY_TRUCK_DELTA" ;;
  }
  dimension: service_truck_delta {
    type: number
    sql: ${TABLE}."SERVICE_TRUCK_DELTA" ;;
  }
  dimension: premium_pickup_delta {
    type: number
    sql: ${TABLE}."PREMIUM_PICKUP_DELTA" ;;
  }
  dimension: t3_van_delta {
    type: number
    sql: ${TABLE}."T3_VAN_DELTA" ;;
  }
  measure: count_markets {
    type: count_distinct
    sql: ${market_id} ;;
  }
  measure: count_markets_ou_delivery_trucks {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [delivery_truck_delta: "-0"]
  }
  measure: perc_ou_delivery_truck {
    type: number
    sql: ${count_markets_ou_delivery_trucks}/${count_markets} ;;
    value_format_name: percent_2
  }
  measure: count_markets_ou_service_trucks {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [service_truck_delta: "-0"]
  }
  measure: perc_ou_service_trucks {
    type: number
    sql: ${count_markets_ou_service_trucks}/${count_markets} ;;
    value_format_name: percent_2
  }
  measure: count_markets_ou_premium_pickup {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [premium_pickup_delta: "-0"]
  }
  measure: perc_ou_premium_pickup {
    type: number
    sql: ${count_markets_ou_premium_pickup}/${count_markets} ;;
    value_format_name: percent_2
  }
  measure: count_markets_ou_t3_van {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [t3_van_delta: "-0"]
  }
  measure: perc_ou_t3_van {
    type: number
    sql: ${count_markets_ou_t3_van}/${count_markets} ;;
    value_format_name: percent_2
  }
}
